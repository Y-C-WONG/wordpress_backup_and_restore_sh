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

# Read args "-h" to determine need housekeep or not
# e.g. xxxx.sh  ----> [default] backup wordpress then do the house keeping
# e.g. xxxx.sh -h 1 ----> backup wordpress then do the house keeping
# e.g. xxxx.sh -h 0 ----> backup wordpress without house keeping
HOUSEKEEP="1"
while getopts h: flag
do
    case "${flag}" in
        h) [ ! -z "${OPTARG}" ] && HOUSEKEEP="${OPTARG}";;
    esac
done

. wp_config.sh

# Create database backup
mariadb-dump --add-drop-table -u$DB_USER -p$DB_PASS $DB_NAME > $DB_BACKUP_FILE

# Create Wordpress and database .sql backup file
tar -czvf $BACKUP_DIR$DAILY_FILE --exclude=$UPLOADS_DIR --transform $WP_TRANSFORM $WP_DIR --transform $DB_TRANSFORM $DB_BACKUP_FILE

# Remove the sql files
rm $DB_BACKUP_FILE

# Housekeeping, keep most recent 7 backup file
if [ $HOUSEKEEP = "1" ]
then
ls -tp $BACKUP_DIR | grep -v "/$" | tail -n +8| xargs -I {} rm $BACKUP_DIR/{}
fi
