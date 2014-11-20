#!/bin/bash

## MAIN

if [ -z ${BACKUP_PATH+x} ]
then
  BACKUP_PATH="/var/mysql-backup"
  echo ">> no \$BACKUP_PATH specified - using default value"
fi

echo ">> using \$BACKUP_PATH: $BACKUP_PATH"
mkdir -p "$BACKUP_PATH" &> /dev/null

DB_LIST=`echo "show databases;" | mysql --defaults-extra-file="$MYSQL_DEFAULTS_FILE" | tail -n +2`

echo ">> backup of every single db"
for DB in $DB_LIST
do
	echo -n "  >> backing up '$DB'... "
	mysqldump --defaults-extra-file="$MYSQL_DEFAULTS_FILE" $DB > "$BACKUP_PATH/mysql-backup_$DB.sql"
	echo "  >> '$DB' finished"
	echo ""
done

echo ">> backup of complete sql server"
mysqldump --defaults-extra-file="$MYSQL_DEFAULTS_FILE" --all-databases > "$BACKUP_PATH/all-databases.sql"
