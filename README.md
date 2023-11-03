# Periodic Automated DB backups via SSH-tunneling

## SSH tunneling

Nodes
- **Host** - your machine / machine you want the backups to be fetched and stored
- **Proxy** - the middle machine through which we connect to Remote
- **Remote** - the target machine in private network which has the DB running

1. In Host, Update .ssh/config
```config
Host proxy
  HostName {proxy_public_ip}
  IdentityFile ~/path/proxy_key.pem
  User ec2-user
  Port 22
  
Host remote
  HostName {target_private_ip}
  IdentityFile ~/path/remote_key.pem
  User ec2-user
  Port 22
  ProxyJump proxy
```
2. In Host, now you should be able to connect to remote
```sh
ssh remote
```
3. Now that you are connected to remote, Try running the command to dump the database into a folder named `~/dump`. Eg command to dump postgres db. If you want to setup an example postgres db in remote follow the instructions in [compose file](/docker-compose.yml).
```sh
pg_dump \
  -U {db_username} \
  -d {db_name} \
  -F c -w \
  -f ~/dump/db-latest.dump
```
4. Exit out to host, now we need to copy ~/dump folder to host machine renamed to `db-dump-{date}`. For this we will use the scp comment in host
```sh
scp -r remote:~/dump ~/db-dump-demo
```

## CRON
In Host, we will use **pm2** to run a script periodically / in cron. But first we need to setup pm2

nodejs18+ should be already installed

1. Install pm2
```sh
npm i -g pm2
```
2. Create .env file from .env.local. Change the variables to your liking and run `start-backup.sh` once to check whether .dump file is created in dump path and log is added to backup.log.
To run the script
```sh
chmod +x ./start-backup.sh
./start-backup.sh
```
3. Now start the `backup-task.json`. which creates a backup with current timestamp every 10 seconds
For starting cron job
```sh
pm2 start backup-task.json
```
For viewing logs
```sh
pm2 logs -f backup-task
```
For removing cron job
```sh
pm2 delete backup-task
```
4. (OPTIONAL) Setup crobtab to run `pm2 flush` every month to clean old pm2 logs.
To set up a cron job to run `pm2 flush` every month, you can use the `crontab` command. Here's how to do it:

   1. Open your terminal.

   2. Type the following command to edit your user's crontab file:

   ```bash
   crontab -e
   ```

   3. This will open your crontab file in the default text editor.

   4. Add the following line to schedule the `pm2 flush` command to run monthly:

   ```bash
   0 0 1 * * pm2 flush
   ```

   This line breaks down as follows:
   - `0` for the minute field (run at the 0th minute of the hour).
   - `0` for the hour field (run at midnight).
   - `1` for the day of the month (1 means the first day).
   - `*` for the month field (any month).
   - `*` for the day of the week (any day of the week).
   - `pm2 flush` is the command you want to run.

   1. Save the file and exit the text editor.

   Your `pm2 flush` command will now run at midnight on the first day of every month.