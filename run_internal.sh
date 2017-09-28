#!/bin/bash

# Setup data directory
find /srv/example -exec chown www-data:www-data {} +

# Setup permissions
useradd external-user -u $uid
useradd external-docker -u $(ls -n /var/run/docker.sock | awk '{print $4}')
usermod -a -G external-user www-data
usermod -a -G external-docker www-data

# Start mysql
find /var/lib/mysql -type f -exec touch {} \;
service mysql start

# Revive atd
service atd restart

# Run migrations
chown external-user:external-user /var/www/configuration.php
su - external-user -c "\
cp /var/www/configuration.php /var/www/example/; \
cd /var/www/example/core; \
php bin/composer install; \
cd /var/www/example; \
php muse migration -i -f"
cd /var/www/example
echo plg_projects_docker | php muse extension add

# Start apache
apachectl -DFOREGROUND
