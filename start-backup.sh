#!/bin/bash
# Load environment variables
source .env

db_backup_command="pg_dump \
  -U ${db_username} \
  -w ${db_password} \
  -d ${db_name} \
  -F c \
  -f ~/dump/db-${db_name}.dump"
# Start the SSH tunnel through the bastion host in the background
ssh remote "${db_backup_command}"
# Copy dump file from remote to local machine
scp remote:~/dump/db-${db_name}.dump ${host_dump_path}/$(date +\%s)-db-${db_name}-$(date +\%Y-\%m-\%d-%H:%M:%S).dump
# Append to backup logs
echo "Backup complete at $(date +\%Y-\%m-\%d-%H:%M:%S)" >> ${host_dump_path}/backup.log