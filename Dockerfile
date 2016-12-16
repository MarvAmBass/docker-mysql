FROM ubuntu:14.04
MAINTAINER MarvAmBass

RUN apt-get -q -y update && \
    apt-get -q -y install mysql-server \
                          mysql-client && \
    apt-get -q -y clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

RUN rm -rf /var/lib/mysql/*; \
    rm -f /etc/mysql/conf.d/mysqld_safe_syslog.cnf; \
    sed -i 's,^log_error,#log_error,g' /etc/mysql/my.cnf

ADD mysql-backuper.sh /usr/local/bin/mysql-backuper.sh

ENV MYSQL_DEFAULTS_FILE /mysql-defaults.cnf

VOLUME ["/var/lib/mysql/", "/var/mysql-backup"]
EXPOSE 3306

ADD ./startup.sh /opt/startup.sh
CMD ["/bin/bash", "/opt/startup.sh"]
