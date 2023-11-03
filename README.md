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
  -w {db_password} \
  -d {db_name} \
  -F c \
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
2. Now start the `backup-task.json`. which creates a file with current timestamp every 10 seconds
For starting cron job
```sh
pm2 start backup-task.json
```
For removing cron job
```sh
pm2 delete backup-task
```
3. Change the variables in `start-backup.sh` and run it once to check whether .dump file is created in dump path and log is added to backup.log.
To run the script
```sh
chmod +x ./start-backup.sh
./start-backup.sh
```
4. Change the script to run `start-backup.sh` in *backup-task.json*
```diff
- "script": "touch file-$(date +\\%s)",
+ "script": "./start-backup.sh",
```