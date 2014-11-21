#/bin/bash

## FUNCTIONS

function exit_if_no_credentials_provided {
  if [ "yes" != "$CREDENTIALS_PROVIDED" ]
  then
    >&2 echo ">> you need credentials for this action but no credentials were provided!";
    exit 1
  fi
}

function init_db {
  mysql_install_db

  /usr/bin/mysqld_safe &
  sleep 10s

  echo "GRANT ALL ON *.* TO $ADMIN_USER@'%' IDENTIFIED BY '$ADMIN_PASSWORD' WITH GRANT OPTION; FLUSH PRIVILEGES" | mysql

  killall mysqld
  sleep 10s
}

function enable_backups {
  if [ -z ${BACKUP_CRON_TIME+x} ]
  then
    echo ">> no \$BACKUP_CRON_TIME set, using default value"
    BACKUP_CRON_TIME="0 * * * *"
  fi

  echo ">> using '$BACKUP_CRON_TIME' as \$BACKUP_CRON_TIME"
  echo "$BACKUP_CRON_TIME root /usr/local/bin/mysql-backuper.sh" >> /etc/crontab

  echo ">> creating $MYSQL_DEFAULTS_FILE file"
  create_mysql_defaults_file
  
  echo ">> starting cron daemon"
  cron -f &
}

function create_mysql_defaults_file {
cat <<EOF > "$MYSQL_DEFAULTS_FILE"
[client]
user="$ADMIN_USER"
password="$ADMIN_PASSWORD"
EOF
}


## MAIN

# variables stuff
MY_IP=`ip a s eth0 | grep inet | awk '{print $2}' | sed 's/\/.*//g' | head -n1`

CREDENTIALS_PROVIDED="yes"
if [ -z ${ADMIN_USER+x} ]
then
  >&2 echo ">> no \$ADMIN_USER specified" 
  ADMIN_USER="\$ADMIN_USER"
  CREDENTIALS_PROVIDED="no"
fi
if [ -z ${ADMIN_PASSWORD+x} ]
then
  >&2 echo ">> no \$ADMIN_PASSWORD specified"
  CREDENTIALS_PROVIDED="no"
fi

# backup stuff
if [ "yes" != "$BACKUP_ENABLED" ]
then
  echo ">> disable auto-backups (mysqldump)"
else
  echo ">> enable auto-backups (mysqldump)"
  echo ">> backups will be stored at default path"
  echo ">> !! link or overwrite it to gain access !!"
  exit_if_no_credentials_provided
  enable_backups
fi

# mysql daemon stuff
if [ -z ${BIND_ADDRESS+x} ]
then
  BIND_ADDRESS="0.0.0.0"
fi
echo ">> bind mysql daemon to $BIND_ADDRESS"
sed -i -e "s/^bind-address\s*=\s*127.0.0.1/bind-address = $BIND_ADDRESS/" /etc/mysql/my.cnf

if [ ! -f /var/lib/mysql/ibdata1 ]; then
  echo ">> init db"
  exit_if_no_credentials_provided
  init_db
fi
echo ">> db installed"

echo ">> starting mysql daemon"
echo ">> you can connect via mysql cli with the following command:"
echo "   mysql -u $ADMIN_USER -p -h $MY_IP"
/usr/bin/mysqld_safe
