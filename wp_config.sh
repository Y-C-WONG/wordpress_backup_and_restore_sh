#!/bin/bash

# Author: Yau Chuen Wobng in September, 2023

# Set the date and the related directory and file name
YYYYMMDD=$(date +"%Y%m%d");    # today date in YYYMMDD format
YYYYMMM=$(date +"%Y%m%b");    #  today date e.g 202310OCT
MONTHLY_FILE="shgh_wp_"$YYYYMMM".tar.gz"    # Monthly backup archive file name
DAILY_FILE="shgh_wp_"$YYYYMMDD".tar.gz"    # Daily backup archive file name 
# Need to update below accordingly
BACKUP_DIR="/home/bak/"    # Backup archive file location
MONTHLY_BAK_DIR="/home/bak/monthly/"
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
