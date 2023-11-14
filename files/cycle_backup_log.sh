#!/bin/bash

# move current log to backup folder and add date to filename
# create CloudWatch error if file not found

LOG_FILE=/root/cron.log
if [[ -f "$LOG_FILE" ]]
then
	mv "$LOG_FILE" log_backups/cron_$(date +%Y%m%d%H%M%S).log
else
	echo "CloudWatchError: cron backup log does not exist!" >> cron.log
fi
