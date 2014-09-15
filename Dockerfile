FROM centos:centos7

MAINTAINER "Dylan Lindgren" <dylan.lindgren@gmail.com>

# Install required repos, update, and then install PHP-FPM
RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-1.noarch.rpm && \ 
    rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm && \
    yum update -y && \
    yum install --enablerepo=remi -y \
        php-cli \
        php-fpm \
        php-mysqlnd \
        php-mssql \
        php-xml \
        php-pgsql \
        php-gd \
        php-mcrypt \
        php-ldap \
        php-imap

# Configure and secure PHP
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php.ini && \
    sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php-fpm.conf && \
    sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php.ini && \
    sed -i '/^listen = /clisten = 0.0.0.0:9000' /etc/php-fpm.d/www.conf && \
    sed -i '/^listen.allowed_clients/c;listen.allowed_clients =' /etc/php-fpm.d/www.conf && \
    sed -i '/^;catch_workers_output/ccatch_workers_output = yes' /etc/php-fpm.d/www.conf

# DATA VOLUMES
RUN mkdir -p /data/nginx/www
VOLUME ["/data/nginx/www"]

# PORTS
# Port 9000 is how Nginx will communicate with PHP-FPM.
EXPOSE 9000

# Run PHP-FPM on container start.
ENTRYPOINT ["/usr/sbin/php-fpm", "-F"]
