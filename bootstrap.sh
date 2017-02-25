#!/usr/bin/bash
echo 'This whole process can take a little while if this is your first time installing; grab a cup of coffee!'

# Silently set the password for vagrant to be vagrant
echo -e 'vagrant\nvagrant' | passwd vagrant > /dev/null 2>&1

# Enable the Firewall - add Django runserver as a firewall service
echo 'Configuring the firewall, allowing Django `runserver`... (Step 1/12)'
cp /vagrant/examples/firewalld-django-runserver.xml /etc/firewalld/services/django-runserver.xml
systemctl start firewalld > /dev/null 2>&1
systemctl enable firewalld > /dev/null 2>&1
firewall-cmd --add-interface enp0s8 > /dev/null 2>&1
firewall-cmd --permanent --add-service http > /dev/null 2>&1
firewall-cmd --permanent --add-service https > /dev/null 2>&1
firewall-cmd --permanent --add-service django-runserver > /dev/null 2>&1
systemctl restart firewalld > /dev/null 2>&1

# EPEL
echo 'Enabling Extra Packages for Enterprise Linux (EPEL) repository... (Step 2/12)'
yum -y -q install http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7

# Apache
echo 'Installing Apache... (Step 2/12)'
yum -y -q install httpd mod_ssl httpd-devel > /dev/null 2>&1
systemctl start httpd > /dev/null 2>&1
systemctl enable httpd > /dev/null 2>&1

# Install some useful pre-reqs
echo 'Installing extra packages for Python... (Step 4/12)'
yum -y -q install graphviz-devel zlib-devel openssl-devel sqlite-devel bzip2-devel python-devel openssl-devel libffi-devel openssl-perl libjpeg-turbo-devel zlib-devel giflib ncurses-devel gdbm-devel xz-devel tkinter readline-devel tk tk-devel unixODBC-devel freetds-devel memcached dos2unix libxslt-devel libxml2-devel

# Check to see if Python 3.5.3 is installed
echo "Checking for Python 3.5.3 installation..."
/usr/local/bin/python3.5 --version | grep '3.5.3' &> /dev/null 2>&1
if [ $? == 0 ];
then
    echo "Python 3.5.3 already installed, skipping to step 8..."
else
	# Python 3.5.3 not installed, let's install it.
	echo "You can ignore the error on the previous line. Python 3.5.3 is not installed, installing Python 3 pre-requisites... (Step 5/12)"
	yum -y -q groupinstall development > /dev/null 2>&1

	echo 'Installing Python 3.5.3... (Step 6/12)'
	wget -q 'https://www.python.org/ftp/python/3.5.3/Python-3.5.3.tgz'
	tar -xzf 'Python-3.5.3.tgz'
	cd ./Python-3.5.3
	CXX=g++ ./configure --enable-shared --quiet
	make > /dev/null 2>&1

	echo 'Moving to alternate location to keep system Python version intact... (Step 7/12)'
	make altinstall > /dev/null 2>&1
	cd ..
	rm Python-3.5.3.tgz
	rm -rf ./Python-3.5.3
	ln -fs /usr/local/bin/python3.5 /usr/bin/python3.5
	echo "/usr/local/lib/python3.5" > /etc/ld.so.conf.d/python35.conf
	echo "/usr/local/lib" >> /etc/ld.so.conf.d/python35.conf
	ldconfig
fi

# virtualenvwrapper
echo "Checking for virtualenvwrapper 4.7.0 installation... (Step 8/12)"
if [ -f /usr/lib/python2.7/site-packages/virtualenvwrapper-4.7.0.dist-info/METADATA ];
then
	echo "virtualenvwrapper 4.7.0 already installed..."
else
	echo "Installing virtualenvwrapper 4.7.0..."
	python /vagrant/examples/get-pip.py > /dev/null 2>&1
	pip install --upgrade ndg-httpsclient > /dev/null 2>&1
	pip install virtualenvwrapper==4.7.0 --quiet > /dev/null 2>&1
	pip install Pygments==2.1 --quiet > /dev/null 2>&1
	# Hack for wheel bdist until new version of virtualenv is release
	rm -f /usr/lib/python2.7/site-packages/virtualenv_support/wheel-0.24.0*
	cp /vagrant/examples/wheel-0.26.0-py2.py3-none-any.whl /usr/lib/python2.7/site-packages/virtualenv_support
	chmod 664 /usr/lib/python2.7/site-packages/virtualenv_support/*
fi

# mod_wsgi
echo "Checking for mod_wsgi 4.5.14 installation... (Step 9/12)"
if [ -f /usr/lib64/httpd/modules/mod_wsgi_4.5.14.txt ]
then
	echo "mod_wsgi 4.5.14 already installed..."
else
	echo "Compiling and installing mod_wsgi 4.5.14..."
	wget -q "https://github.com/GrahamDumpleton/mod_wsgi/archive/4.5.14.tar.gz"
	tar -xzf '4.5.14.tar.gz'
	cd ./mod_wsgi-4.5.14
	./configure --with-python=/usr/local/bin/python3.5 --quiet
	make > /dev/null 2>&1
	make install > /dev/null 2>&1
	touch /usr/lib64/httpd/modules/mod_wsgi_4.5.14.txt
	cd ..
	rm '4.5.14.tar.gz'
	rm -rf ./mod_wsgi-4.5.14
fi

# memcached
echo "Installing memcached... (Step 10/12)"
cp /vagrant/examples/memcached /etc/sysconfig/
dos2unix -q /etc/sysconfig/memcached
systemctl enable memcached > /dev/null 2>&1
systemctl start memcached > /dev/null 2>&1

# virtualenvwrapper - enum34 causes conflicts.
echo "Configuring virtualenv and virtualenvwrapper settings... (Step 11/12)"
pip uninstall -y enum34 --quiet > /dev/null 2>&1
export WORKON_HOME=/home/vagrant/.virtualenvs
source /usr/bin/virtualenvwrapper.sh
cp /vagrant/examples/bashrc.sh /home/vagrant/.bashrc

# Copy in login message
cp /vagrant/examples/motd.txt /etc/motd

# symlink /vagrant/html to /var/www/html
ln -fs /vagrant/html /var/www/html

# Fix for slow networking due to dns proxy
echo "options single-request-reopen" >>/etc/resolv.conf
echo "RES_OPTIONS=single-request-reopen" >>/etc/sysconfig/network

# Disable unnecessary conf files
mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.old > /dev/null 2>&1
mv /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/welcome.conf.old > /dev/null 2>&1

# Restart apache
systemctl restart httpd > /dev/null 2>&1

# SQL Server ODBC
cp /vagrant/examples/odbc*.ini /etc
cp /vagrant/examples/freetds.conf /etc

# NODE AND NPM
echo "Installing Node, NPM, Gulp and Bower... (Step 12/12)"
yum -y -q remove nodejs npm > /dev/null 2>&1
curl --silent --location https://rpm.nodesource.com/setup_6.x | bash - > /dev/null 2>&1
yum -y -q install nodejs > /dev/null 2>&1

mkdir -p /home/vagrant/npm-global
npm config set prefix '/home/vagrant/npm-global'
npm install --global gulp bower > /dev/null 2>&1

# Fix permissions...
chown -R vagrant.apache /home/vagrant
chmod g+x /home/vagrant
chmod g+x /home/vagrant/.virtualenvs
chmod g+s /home/vagrant/.virtualenvs

# Increasing `max_user_watches` for processes watching files in development,
# such as webpack
if [[ $(cat /proc/sys/fs/inotify/max_user_watches) = 8192 ]]; then
	echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p 2>&1
fi

# DONE
echo "ALL FINISHED..."
echo "Now try logging in:"
echo "    $ vagrant ssh"
