#!/bin/bash

# This script creates a tar.gz file which is a backup archive of the Wordpress directory and wordpress database.
# Author: Yau Chuen Wobng in September, 2023

# Set the date and the related directory and file name
YYYYMMDD=$(date +"%Y%m%d");    # today date in YYYMMDD format
YYYYMMM=$(date +"%Y%m%b");    #  today date e.g 202310OCT
MONTHLY_FILE="shgh_wp_"$YYYYMMM".tar.gz"    # Monthly backup archive file name
DAILY_FILE="shgh_wp_"$YYYYMMDD".tar.gz"    # Daily backup archive file name 
# Need to update below accordingly
BACKUP_DIR="/home/bak/"    # Backup archive file location
DB_BACKUP_DIR=$BACKUP_DIR    # DB backup .sql location
DB_BACKUP_FILE=$DB_BACKUP_DIR"shgh_wp_$YYYYMMDD.sql"    # DB backup .sql file name and location
WP_DIR="/var/www/html/"    # Wordpress directory
WP_TRANSFORM="s,^var/www/html,html," # change directory structure while tar for Wordpress file
DB_TRANSFORM="s,^home/bak,DB,"    # chage directory structure while append ,sql file into the tar
UPLOADS_DIR="/var/www/html/wp-content/uploads/*"    # skip the file in wordpress uploads directory (for daily backup only)

# WP database credentials
DB_USER="root"    # wordpress database username with backup premmission
DB_PASS="password"    # password of the wordpress database user
DB_NAME="wp_db"    # wordpress database name

. wp_config.sh
HOUSEKEEP="1"

function _usage() 
{
  ###### U S A G E : Help and ERROR ######
  cat <<EOF
   wordpress_backup.sh $Options
  $*
          Usage: wordpress_backup.sh <[options]>
          Options:
                  -a    Backup all wordpress directory (include "wp-content/uploads/*")
                            e.g. xxx.sh : [default] backup without "wp-content/uploads/*")
                            e.g. xxx.sh -a : backup all wordpress directory (include "wp-content/uploads/*")
                  -k    Set to 1 if need housekeeping (keep 3 latest archive copy and delete others)
                            e.g. xxxx.sh : [default] backup wordpress then do the housekeeping
                            e.g. xxxx.sh -k 1 : backup wordpress then do the housekeeping
                            e.g. xxxx.sh -k 0 : backup wordpress without housekeeping
                  -h    Show this message
EOF
}

# Read args "-k" to determine need housekeep or not
# e.g. xxxx.sh  ----> [default] backup wordpress then do the house keeping
# e.g. xxxx.sh -k 1 ----> backup wordpress then do the house keeping
# e.g. xxxx.sh -k 0 ----> backup wordpress without house keeping
#########
# Read args  "-a" to backup all wp-dir (include wp-content/uploads/*)
# e.g. xxx.sh ----> [default] backup without wp-content/uploads/*)
# e.g. xxx.sh -a ------> backup all wp-dir (include wp-content/uploads/*)

while getopts hka flag
do
    case "${flag}" in
        h) 
          _usage
          exit 0
          ;;
        k) 
          [ ! -z "${OPTARG}" ] && HOUSEKEEP="${OPTARG}"
          ;;
        a)
          UPLOADS_DIR=""
          ;;
    esac
done

# Create database backup
mariadb-dump --add-drop-table -u$DB_USER -p$DB_PASS $DB_NAME > $DB_BACKUP_FILE

# Create Wordpress and database .sql backup file
tar -czvf $BACKUP_DIR$DAILY_FILE --exclude=$UPLOADS_DIR --transform $WP_TRANSFORM $WP_DIR --transform $DB_TRANSFORM $DB_BACKUP_FILE

# Remove the sql files
rm $DB_BACKUP_FILE

# Housekeeping, keep most recent 3 backup file
if [ $HOUSEKEEP = "1" ]
then
ls -tp $BACKUP_DIR | grep -v "/$" | tail -n +4| xargs -I {} rm $BACKUP_DIR/{}
fi
