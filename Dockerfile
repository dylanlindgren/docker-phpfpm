FROM centos:latest

MAINTAINER "Dylan Lindgren" <dylan.lindgren@gmail.com>

# Install trusted CA's (needed in the environment this was developed for)
ADD build/certs /tmp/certs
RUN cat /tmp/certs >> /etc/pki/tls/certs/ca-bundle.crt

# Install required repos and update
RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-1.noarch.rpm
RUN rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
RUN yum update -y

# Install PHP-FPM
RUN yum --enablerepo=remi install -y php-cli php-fpm php-mysqlnd php-mssql php-pgsql php-gd php-mcrypt php-ldap php-imap

# Configure PHP to UTC timezone.
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php.ini

# Stop PHP-FPM from becoming a daemon.
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php.ini

# Enable PHP-FPM listening
RUN sed -i '/^listen = /clisten = 0.0.0.0:9000' /etc/php-fpm.d/www.conf
RUN sed -i '/^listen.allowed_clients/c;listen.allowed_clients =' /etc/php-fpm.d/www.conf
RUN sed -i '/^;catch_workers_output/ccatch_workers_output = yes' /etc/php-fpm.d/www.conf

# DATA VOLUMES
RUN mkdir /data
RUN mkdir /data/www

# Contains the website's www data.
VOLUME ["/data/www"]

# PORTS
# Port 9000 is how Nginx will communicate with PHP-FPM.
EXPOSE 9000

# Run PHP-FPM on container start.
ENTRYPOINT ["/usr/sbin/php-fpm", "-F"]
