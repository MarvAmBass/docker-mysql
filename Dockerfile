FROM ubuntu:14.04
MAINTAINER MarvAmBass

RUN apt-get update; apt-get install -y \
    mysql-server \
    mysql-client

RUN rm -rf /var/lib/mysql/*

ADD mysql-backuper.sh /usr/local/bin/mysql-backuper.sh
RUN chmod a+x /usr/local/bin/mysql-backuper.sh

ENV MYSQL_DEFAULTS_FILE /mysql-defaults.cnf

EXPOSE 3306
VOLUME ["/var/lib/mysql/"]
VOLUME ["/var/mysql-backup"]

ADD ./startup.sh /opt/startup.sh
RUN chmod a+x /opt/startup.sh
CMD ["/bin/bash", "/opt/startup.sh"]
