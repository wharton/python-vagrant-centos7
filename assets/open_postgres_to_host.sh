#!/bin/bash
echo 'Opening PostgreSQL port 5432 on the firewall...'
firewall-cmd --permanent --add-service postgresql > /dev/null
systemctl restart firewalld
echo 'Copying PostgreSQL config files allows host machine to connect to the Vagrant VM...'
cp /vagrant/assets/p*.conf /var/lib/pgsql/9.6/data/
echo 'Restarting PostgreSQL...'
su -c 'cd / && /usr/pgsql-9.6/bin/pg_ctl -D /var/lib/pgsql/9.6/data restart' postgres > /dev/null
echo 'Complete!'
