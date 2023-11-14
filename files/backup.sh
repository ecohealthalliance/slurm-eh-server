#!/bin/bash

PASSPHRASE=""
GPG_KEY="{{ gpg_key }}"
BK_FULL_FREQ="1M" # create a new full backup every...
BK_FULL_LIFE="2M" # delete any backup older than this
BK_KEEP_FULL="1"  # How many full+inc cycle to keep

export AWS_ACCESS_KEY_ID="{{ your_access_key_id }}"
export AWS_SECRET_ACCESS_KEY="{{ your_secret_access_key }}"

# If the backup file was modified more than 7 days ago it is ignored,
# since it was probably not deleted due to an error.
if [ $(find /root/.backup_in_progress -mtime -7 -type f) ] ;
then
   echo -e "Prior backup is still in progress. Exiting..."
   exit 1
fi
touch /root/.backup_in_progress

IFS=$'\n'

for i in $(find /home/ -maxdepth 1 -type d -regextype sed -regex '.*/[a-zA-Z0-9\_]\+$' ! -name 'git');
do
        echo "$i"
        dest="s3://s3.amazonaws.com/prospero-bckp/backupof$(basename $i)"
        # The regular expression excludes all .rstudio and .Rproj.user folders, and temp folders in the user's home directory.
        BACKUP_OUTPUT=$(PASSPHRASE=$PASSPHRASE duplicity --encrypt-key=$GPG_KEY --sign-key=$GPG_KEY --exclude-regexp="\/(\.rstudio|\.Rproj\.user|home\/$(basename $i)\/te?mp)$" --full-if-older-than $BK_FULL_FREQ "$i" "$dest")
        BACKUP_EXIT="$?"
        if [[ "$BACKUP_EXIT" != "0" ]]
        then
                echo "CloudWatchError: $i Non-zero exit code on backup: $BACKUP_EXIT!"
        fi
        duplicity remove-older-than $BK_FULL_LIFE --force "$dest"
        duplicity remove-all-inc-of-but-n-full $BK_KEEP_FULL --force "$dest"

        ERROR_LINE_EXISTS=0
        FB_LINE_EXISTS=0
        while IFS= read -r line; do
                if [[ "$line" == "Errors"* ]]
                then
                        ERROR_LINE_EXISTS=1
                        LINE_ERRORS=$(echo $line | cut -d' ' -f2)
                        if [[ "${LINE_ERRORS}" != "0" ]]
                        then
                                echo "CloudWatchError: $i $LINE_ERRORS"
                        fi
                fi
                if [[ "$line" == "Last full backup date:"* ]]
                then
                        FB_LINE_EXISTS=1
                        IFS=':' read -r garbage FULL_BACKUP_DATE <<< "$line"
                        FB_YEAR_MONTH_DAY_PLUS_60_DAYS=$(date -d "$FULL_BACKUP_DATE+60 days" +%F)
                        CURRENT_YEAR_MONTH_DAY=$(date +%F)
                        # check if last full backup is more than 2 months old
                        if [[ "$CURRENT_YEAR_MONTH_DAY" > "$FB_YEAR_MONTH_DAY_PLUS_60_DAYS" ]]
                        then
                                echo "CloudWatchError: $i Full backup is older than 60 days!"
                        fi
                fi
        done <<< "$BACKUP_OUTPUT"
        echo "$BACKUP_OUTPUT"

        if [[ "$ERROR_LINE_EXISTS" == "0" ]]
        then
                echo "CloudWatchError: $i Error line doesn't exist!"
        fi
        if [[ "$FB_LINE_EXISTS" == "0" ]]
        then
                echo "CloudWatchError: $i Full Backup
