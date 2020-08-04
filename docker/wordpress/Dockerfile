FROM wordpress:5.4.2-apache

COPY remoteip.conf /etc/apache2/conf-enabled/
COPY status.conf /etc/apache2/mods-available/
COPY .htaccess /var/www/html/