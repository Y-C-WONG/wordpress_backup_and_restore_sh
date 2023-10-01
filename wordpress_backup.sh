#!/bin/bash

# This script creates a tar.gz file which is a backup archive of the Wordpress directory and wordpress database.
# Author: Yau Chuen Wobng in September, 2023

# Set the date and the related directory and file name
YYYYMMDD=$(date +"%Y%m%d");
YYYYMMM=$(date +"%Y%m%b");
MONTHLY_FILE="shgh_wp_"$YYYYMMM".tar.gz"
DAILY_FILE="shgh_wp_"$YYYYMMDD".tar.gz"
BACKUP_DIR="/home/ubuntu/"
DB_BACKUP_DIR=$BACKUP_DIR"DB/"
DB_BACKUP_FILE=$DB_BACKUP_DIR"shgh_wp_$YYYYMMDD.sql"
WP_DIR="/home/ubuntu/test/"
WP_TRANSFORM="s,^home/ubuntu/test,test,"
DB_TRANSFORM='s,^home/ubuntu/DB,DB,'
UPLOADS_DIR="/home/username/www/wp_content/uploads/"

# WP database credentials
DB_USER="root"
DB_PASS="password"
DB_NAME="wp_db"


# Read args to determine need housekeep or not
HOUSEKEEP="1"
if [ $1 = "-h" ] && [ $2 = "0" ]
then 
    HOUSEKEEP="0"
fi 

# Create database backup
mariadb-dump --add-drop-table -u$DB_USER -p$DB_PASS $DB_NAME > $DB_BACKUP_FILE

# Create Wordpress backup file
tar -cvf $DAILY_FILE --exclude="/home/ubuntu/test/10.txt" --transform $WP_TRANSFORM $WP_DIR

# Append the database sql file to the archive and remove the sql file
tar --append --file=$DAILY_FILE --transform $DB_TRANSFORM $DB_BACKUP_FILE
rm $DB_BACKUP_FILE

# Housekeeping, keep most recent 7 backup file
if [“$HOUSEKEEP” = “1”]
then
ls -tp $BACKUP_DIR | grep -v "/$" | tail -n +8| xargs -I {} rm $BACKUP_DIR/{}
fi