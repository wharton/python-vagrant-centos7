#!/bin/bash
#
# This script will install and enable PostgreSQL 9.6 for CentOS 7 locally
# for development. Must be sudo'd.
#

echo "Adding the PostgreSQL 9.6 CentOS repository..."
rpm -Uvh http://yum.postgresql.org/9.6/redhat/rhel-7-x86_64/pgdg-centos96-9.6-3.noarch.rpm

echo "Installing PostgreSQL..."
yum -y --quiet install postgresql96-server postgresql96 postgresql96-devel postgresql96-contrib
/usr/pgsql-9.6/bin/postgresql96-setup initdb
cp /vagrant/assets/pg_hba.conf /var/lib/pgsql/9.6/data
cp /vagrant/assets/postgresql.conf /var/lib/pgsql/9.6/data
systemctl restart postgresql-9.6
systemctl enable postgresql-9.6

echo "Opening up port 5432 on the firewall..."
firewall-cmd --permanent --add-service postgresql > /dev/null 2>&1
systemctl restart firewalld > /dev/null 2>&1

echo "Making user 'vagrant' a superuser..."
sudo -u postgres createuser -sd vagrant
sudo -u postgres createdb vagrant

echo "PostgreSQL installation complete."
