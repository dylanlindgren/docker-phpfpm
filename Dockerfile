FROM centos:latest

MAINTAINER "Dylan Lindgren" <dylan.lindgren@gmail.com>

# Set home environment variable, as Docker does not look this up in /etc/passwd
ENV HOME /root

# Install certificates
ADD build/certs /tmp/certs
RUN cat /tmp/certs >> /etc/pki/tls/certs/ca-bundle.crt

# Install required repos and update
RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-1.noarch.rpm
RUN rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
RUN yum update -y

# Install PHP-FPM
RUN yum --enablerepo=remi install -y php-cli php-fpm php-mysqlnd php-mssql php-pgsql php-gd php-mcrypt php-ldap php-imap

# Configure PHP to UTC timezone
RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php.ini

# Stop PHP-FPM from becoming a daemon
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php-fpm.conf
RUN sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php.ini

RUN mkdir /data
RUN mkdir /data/www

# Data volumes
VOLUME ["/data/www"]

# Port 9000 is where PHP-FPM will listen on
EXPOSE 9000

# Default entrypoint when using "docker run" command
ENTRYPOINT ["/usr/sbin/php-fpm", "-F"]
