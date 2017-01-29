#!/bin/bash
#
# This script will install and enable PostgreSQL 9.5 for CentOS 7 locally
# for development. Must be sudo'd.
#

echo "Adding the PostgreSQL 9.5 CentOS repository..."
rpm -Uvh http://yum.postgresql.org/9.5/redhat/rhel-7-x86_64/pgdg-centos95-9.5-2.noarch.rpm

echo "Installing PostgreSQL..."
yum -y --quiet install postgresql95-server postgresql95 postgresql95-devel postgresql95-contrib
/usr/pgsql-9.5/bin/postgresql95-setup initdb
cp /vagrant/examples/pg_hba.conf /var/lib/pgsql/9.5/data
cp /vagrant/examples/postgresql.conf /var/lib/pgsql/9.5/data
systemctl restart postgresql-9.5
systemctl enable postgresql-9.5

echo "Opening up port 5432 on the firewall..."
firewall-cmd --permanent --add-service postgresql > /dev/null 2>&1
systemctl restart firewalld > /dev/null 2>&1

echo "Making user 'vagrant' a superuser..."
sudo -u postgres createuser -sd vagrant
sudo -u postgres createdb vagrant

echo "PostgreSQL installation complete."
