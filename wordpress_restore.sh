#!/bin/bash

#####
# This script restore wordpress site with a archive tar.gz file which is backup by wordpress_backup.sh
# It is suggest to run the following step by step (step order mark in the comment) rather then run at once.
# 
# Author: Yau Chuen Wong in October, 2023
#####

YYYYMMDD=$(date +"%Y%m%d");    # today date in YYYMMDD format
DAILY_FILE="shgh_wp_"$YYYYMMDD"_bak.tar.gz"    # Daily backup archive file name 
# Need to update below accordingly
RESTORE_FILE="shgh_WP_YYYYMMDD.tar.gz"
BACKUP_DIR="/home/bak/"    # Backup archive file location
DB_BACKUP_DIR=$BACKUP_DIR    # DB backup .sql location
DB_BACKUP_FILE=$DB_BACKUP_DIR"shgh_wp_"$YYYYMMDD"_bak.sql"    # DB backup .sql file name and location
WP_DIR="/var/www/html/"    # Wordpress directory
WP_TRANSFORM="s,^var/www/html,html," # change directory structure while tar for Wordpress file
DB_TRANSFORM="s,^home/bak,DB,"    # chage directory structure while append ,sql file into the tar
UPLOADS_DIR="/var/www/html/wp-content/uploads/*"    # skip the file in wordpress uploads directory (for daily backup only)

# WP database credentials
DB_USER="root"    # wordpress database username with backup premmission
DB_PASS="password"    # password of the wordpress database user
DB_NAME="wp_db"    # wordpress database name

. wp_config.sh

# STEP 1 : Create database backup
mariadb-dump --add-drop-table -u$DB_USER -p$DB_PASS $DB_NAME > $DB_BACKUP_FILE

# STEP 2 : Create Wordpress backup file
tar -czvf $BACKUP_DIR$DAILY_FILE --transform $WP_TRANSFORM $WP_DIR --transform $DB_TRANSFORM $DB_BACKUP_FILE
rm $DB_BACKUP_FILE

# STEP 3 : Extract the file from the restore achrive
tar -xzvf $BACKUP_DIR$RESTORE_FILE

# STEP 4 : Remove all the file in the WP_DIR
rm -rf $WP_DIR

# STEP 5 : Move all the wordpress files extracted from the tar into the wordpress directory
# {.[!.],}* = all files include files name start with "." and ignore  "." and ".." directories
mv $BACKUP_DIR/html/{.[!.],}* $WP_DIR

# STEP 6 :  Import the sql file into the wordpress database
mariadb -u$DB_USER -p$DB_PASS $DB_NAME < $BACKUP_DIR/DB/*.sql

# STEP 7 :  Import the sql file into the wordpress database
# Please chnage the table name of 'wp_options' and option_value according to your environment setting 
mariadb -u$DB_USER -p$DB_PASS -e 'update wp_options set option_value = 'localhost:8080' where option_id in (1,2);'  $DB_NAME
