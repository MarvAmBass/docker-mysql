# Docker MySQL-Server Container
_maintained by MarvAmBass_

## What is it

This Dockerfile (available as ___marvambass/mysql___) gives you a completly running SQL-Server. It is also possible to configure a auto mysqldump mechanism.

For Configuration of the Server you use environment Variables.

It's based on the [ubuntu:14.04](https://registry.hub.docker.com/_/ubuntu/) Image

View in Docker Registry [marvambass/mysql](https://registry.hub.docker.com/u/marvambass/mysql/)

View in GitHub [MarvAmBass/docker-mysql](https://github.com/MarvAmBass/docker-mysql)

## Environment variables and defaults

### MySQL Daemon

The daemon stores the database data beneath: __/var/lib/mysql__

* __ADMIN\_USER__
 * no default - needed only when _backup enabled_ or for _mysql initialisation_
* __ADMIN\_PASSWORD__
 * no default - needed only when _backup enabled_ or for _mysql initialisation_
* __BIND\_ADDRESS__
 * default: _0.0.0.0_

### Backup

This is totaly optional - backup is disabled by default!  
In default it stores it's dumps beneath: __/var/mysql-backup__

* __BACKUP_ENABLED__
 * default null, needs 'yes' to be enabled
* __BACKUP\_CRON\_TIME__
 * default: _0 \* \* \* \*_ (hourly mysqldumps) - uses normal cron syntax
* __BACKUP_PATH__
 * default: _/var/mysql-backup_ - the place to store the mysqldumps

## Using the marvambass/mysql Container 

### Running MySQL

For the first start you'll need to provide the __ADMIN\_USER__ and __ADMIN\_PASSWORD__ variables

    docker run -d --name mysql \
    -e 'ADMIN_USER=dbadmin' -e 'ADMIN_PASSWORD=pa55worD!' \
    -e 'BIND_ADDRESS=192.0.3.33'
    -e 'BACKUP_ENABLED=yes' -e 'BACKUP_CRON_TIME=0 * * * *'
    -p 3306:3306 \
    -v /tmp/mysqldata:/var/lib/mysql \
    -v /tmp/mysqlbackup:/var/mysql-backup \
    marvambass/mysql
_you need to provide the credentials only if you start the container for the first time (so it can initialize a new Database) or if you use the internal mysqldump backup mechanism_

### Connection

Now you can connect to the MySQL Server via the normal mysql-client cli:

    mysql -u $ADMIN_USER -p -h $(docker inspect --format='{{.NetworkSettings.IPAddress}}' $CONTAINER_ID)
    
You could also use my __marvambass/phpmyadmin__ container and link them together.  
_You only link __phpmyadmin__ to __mysql__ container if you want to use phpmyadmin!_
