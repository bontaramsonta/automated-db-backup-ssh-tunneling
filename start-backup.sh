#!/bin/bash
# Load environment variables
source .env
# correcting max_backups
max_backups=$((max_backups-1))

db_backup_command="pg_dump \
  -U ${db_username} \
  -d ${db_name} \
  -F c -w \
  -f /dump/db-${db_name}.dump"

# docker exec wrapper command
docker_exec="docker exec ${docker_container_name} sh -c \"${db_backup_command}\""
echo ${host_dump_path}
echo "Create dump directory if it doesn't exist"
mkdir -p ${host_dump_path}
echo "run docker command if docker"
if [ "${is_db_in_docker}" == true ]; then
  echo "Run docker exec command"
  ssh remote "${docker_exec}" >> /dev/null
else
  echo "Run pg_dump command"
  ssh remote "${db_backup_command}" >> /dev/null
fi
echo "Copy dump file from remote to local machine"
timestamp=$(date +\%Y-\%m-\%d-%H:%M:%S)
scp remote:/dump/db-${db_name}.dump ${host_dump_path}/$(date +\%s)-db-${db_name}-${timestamp}.dump
# create backup.log if it doesn't exist
touch ${host_dump_path}/backup.log
# Get the total number of lines in the file
total_lines=$(wc -l < "${host_dump_path}/backup.log")
# Calculate the number of lines to process
lines_to_process=$((total_lines - max_backups))
echo $lines_to_process
if [ $lines_to_process -gt 0 ]; then
  echo "Removing $lines_to_process old backups"
  # Get the lines to process
  lines=$(head -n $lines_to_process "${host_dump_path}/backup.log")

  # Loop through each line
  while IFS= read -r line
  do
    # Split the line to get the filename
    filename=$(echo $line | awk '{print $4}')

    # Find the file in the backup directory
    file=$(ls $host_dump_path/*$filename*)
    echo "removing $file"
    # Delete the file
    rm -f $file
    # Remove the line from the log file
    sed -i '' "/$filename/d" "${host_dump_path}/backup.log"
  done <<< "$lines"
else
  echo "No backups to remove"
fi
echo "Append to backup logs"
echo "Backup complete at ${timestamp}" >> ${host_dump_path}/backup.log
