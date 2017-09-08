FROM debian:8.9

# Skipping: hostname, hosts, networking, dns
# Already configured: localusers, 

RUN \
echo "================================================================================"; \
echo "Configuring APT"; \
echo "================================================================================"; \
export DEBIAN_FRONTEND=noninteractive; \
sed -i -e 's/exit 101/exit 0/' /usr/sbin/policy-rc.d; \
apt-get update; \
apt-get install -y wget apt-utils; \
echo "deb http://packages.hubzero.org/deb ellie-deb8 main" >> /etc/apt/sources.list; \
echo "deb http://download.openvz.org/debian jessie main" >> /etc/apt/sources.list; \
apt-key adv --keyserver pgp.mit.edu --recv-keys 143C99EF; \
wget http://ftp.openvz.org/debian/archive.key -q -O - | apt-key add -; \
apt-get update

RUN \
echo "================================================================================"; \
echo "Installing mysql"; \
echo "================================================================================"; \
export DEBIAN_FRONTEND=noninteractive; \
apt-get install -y hubzero-mysql

RUN \
echo "================================================================================"; \
echo "Installing Hubzero-cms"; \
echo "================================================================================"; \
export DEBIAN_FRONTEND=noninteractive; \
apt-get install -y hubzero-cms-2.1.0;

ADD databasedump.sql /var/www/databasedump.sql
ADD example-ssl-m4.patch /var/www/example-ssl-m4.patch
ADD example-ssl-conf.patch /var/www/example-ssl-conf.patch

RUN \
echo "================================================================================"; \
echo "Configuring Hubzero-cms"; \
echo "================================================================================"; \
find /var/lib/mysql -type f -exec touch {} \; ; \
service mysql start; \
sed -i -e "s/elif version.startswith('7.')[^:]/elif version.startswith('7.'):/" /usr/bin/hzcms; \
hzcms install example; \
hzcms update; \
cd /etc/apache2/sites-m4; \
patch < /var/www/example-ssl-m4.patch; \
cd /etc/apache2/sites-available; \
patch < /var/www/example-ssl-conf.patch; \
a2dissite 000-default.conf; \
a2ensite example.conf example-ssl.conf; \
mysql -u root -e "drop database example"; \
mysql -u root -e "create database example"; \
mysql -u root example < /var/www/databasedump.sql; \
service apache2 restart; \
service mysql stop; \
service apache2 stop; \
cp /var/www/example/configuration.php /var/www/; \
rm -rf /var/www/example/*; \
apt-get install -y vim

ADD ./run_internal.sh /run.sh
CMD /run.sh
