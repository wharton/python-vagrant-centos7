# A CentOS 7.5 Vagrant Box with Python 3.5 & 3.6 via Ansible

* Apache 2.4, with mod_wsgi for running Django
* Microsoft ODBC & FreeTDS drivers for MS SQL Server
* PostgreSQL Drivers & Server
* Node + npm

This repository contains a CentOS 7.5 box for Vagrant. Python 3.5 and 3.6 are installed alongside the system Python (2.7.5). The Vagrant config uses Ansible roles to configure the box for the development environment, that should also be (mostly) suitable for setting up a production server. `Cookiecutter`, `virtualenvwrapper`, and `Pygments` are installed with the system Python.

PostgreSQL 10 server is installed locally and all for full-stack local development. MS SQL is also supported as a Django database backend with either the Microsoft provided ODBC or the FreeTDS ODBC Driver to an external SQL Server.

Django 1.11 or greater is recommended at the time of this writing for new projects. Django 1.11 is an LTS (Long Term Support) release, meaning it will be actively supported with bug fixes and security patches until at least April, 2020 (and probably longer): https://www.djangoproject.com/download/#supported-versions

## Compatibility & Prerequisites to Install

### Windows

* Tested with VirtualBox 5.2.10: https://download.virtualbox.org/virtualbox/5.2.10/VirtualBox-5.2.10-122406-Win.exe
* Tested with Vagrant 2.1.1: https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.msi
* Git Bash is highly recommended, not the Windows Command Prompt (cmd.exe): https://git-for-windows.github.io/
    * In Git Bash, click the diamond shaped multi-colored icon in the upper left of the window, OPTIONS. You may want to go through the option list to increase your default window size, set up copy/paste shortcuts, and set up mouse selection for copy/paste.
* On newer machines, ensure that you have virtualization enabled in BIOS (Google it for your machine's model).
* Tested on: Windows 7, 8, and 10.

### Mac

* Tested with VirtualBox 5.2.10: https://download.virtualbox.org/virtualbox/5.2.10/VirtualBox-5.2.10-122088-OSX.dmg
* Tested with Vagrant 2.1.1: https://releases.hashicorp.com/vagrant/2.1.1/vagrant_2.1.1_x86_64.dmg
* Git is required: http://git-scm.com/downloads
* Tested on: OS/X Yosemite, and El Capitan, and Sierra.

### Linux

* VirtualBox 5.2.10 can be downloaded here: https://www.virtualbox.org/wiki/Linux_Downloads
* Vagrant 2.1.1 can be downloaded here: https://releases.hashicorp.com/vagrant/2.1.1/
* On newer machines, ensure that you have virtualization enabled in BIOS (duckduckgo it for your machine's model).

**Fedora 25, CentOS 7**

These are available via the package manager.

```
$ sudo dnf install vagrant
$ sudo dnf install VirtualBox
```

## Get Started

* Create and add a public SSH key to your git server (GitHub, GitLab, etc).
* Clone the repository and bring up the virtual development environment. The first time you install the box, "vagrant up" will take a little while. Grab a cup of coffee or something!
* You may want to use a host name for your domain; for example, if you're a member of The Wharton School, you may want to use the command `VAGRANT_HOSTNAME="vagrant.wharton.upenn.edu" vagrant up` below instead of `vagrant up`. If you don't provide a hostname, you will be prompted for one. If you don't have one, feel free to use `vagrant.example.com`.
* The Vagrant plugin `vagrant-vbguest` will cause problems with the shared folder in most cases. Please uninstall the plugin first if you have it installed with `vagrant plugin uninstall vagrant-vbguest`.

```bash
git clone https://github.com/wharton/python-vagrant-centos7.git
cd python-vagrant-centos7
vagrant up
vagrant ssh
```

**Fedora 25, CentOS 7**

Check Vagrantfile and make sure the port forwarding settings will work for
your use case. You may wish to forward the guest VM port 80 to something
other than port 80 on the host, e.g. 8888.

``` 
config.vm.network "forwarded_port", guest: 80, host: 8888, auto_correct: false
```

Replace the the VAGRANT_HOSTNAME line from above with the following.

```
$ vagrant up --provider=virtualbox 
```

Sit back, let the installation complete.


* You can also add the host name to your computer's `hosts` file. Your `hosts` file should be located at:

    * Mac / Linux: /etc/hosts
    * Windows: %SystemRoot%\system32\drivers\etc\hosts

Add this line (with the appropriate host name, if you changed it):

```
192.168.99.100  vagrant.my.domain.com
```

### Default installation creates

    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key

```
$ vagrant ssh
```

Another, less desirable, option for SSH'ing into the vagrant box..
(this requires the use of the default password, vagrant)

```
$ ssh vagrant@vagrant.my.domain.com -p 2222
```

At this point, you should change the default password for the vagrant user.
You may also want to add/remove users soon.

## Using PostgreSQL & Creating a New Database for a Django Project

The Vagrant box comes with PostgreSQL 9.6. The `vagrant` user is set up as a PostgreSQL superuser (in addition to the `postgres` user).

```
$ psql
psql (10.0)
Type "help" for help.

vagrant=# \?
...
vagrant=# CREATE USER my_django_user WITH PASSWORD 'my_django_password';
CREATE ROLE
vagrant=# CREATE DATABASE my_django_db WITH OWNER my_django_user;
CREATE DATABASE
vagrant=# \q
```

## Setting Up Django & virtualenv

First, change to the directory set aside to hold user projects.

```
$ cd projects
```

Next, create a new virtual environment for your Django project:

```
$ mkvirtualenv django-project
```

Next, within this virtualenv, install `django`, `django-extensions`, and `pygraphviz`:

```
(django-project) [vagrant@vagrant django-project]$ pip install django django-extensions pygraphviz
```

Now, create a new Django project and enter its directory:

```
(django-project) [vagrant@vagrant django-project]$ django-admin startproject myproject
(django-project) [vagrant@vagrant django-project]$ cd myproject
```

## Creating ERDs of Django Models

The `django-extensions` app can build handy Entity Relationship Diagrams for Django apps, even your entire project. The pre-requisites for the Python packages are included with this Vagrant box.

![An example ERD with three Django apps.](assets/users-faculty-courses.png)

First, within your Django project's virtualenv, install `django-extensions` and `pygraphviz`:

```
 (django-project) [vagrant@vagrant django-project]$ pip install django-extensions pygraphviz
```

Next, add `django_extensions` to your `INSTALLED_APPS`. Then you can create the diagrams; to create a PNG of all models in your Django project.

```
$ ./manage.py graph_models -a -g -o project-erd.png
```

Or, to just do a few Django apps:

```
$ ./manage.py graph_models users faculty courses -g -o users-faculty-courses.png
```

## Windows 10: Forwarding Port 80 for Testing Apache

In Windows 10, the "World Wide Web Publishing Service" automatically starts on port 80. You can disable it so Vagrant can forward port 80.

* Click Start, type "Services" and open Services.
* Scroll down to World Wide Web Publishing Service. Right click and go into Properties.
* Change "Startup type" to be Manual.
* Click the "Stop" button.
* Click "OK".

Maintainer:

* Tim Allen (https://github.com/FlipperPA)

Contributors:

* Jane Eisenstein (https://github.com/janeeisenstein)
* Gavin Burris (https://github.com/00gavin)
* Dave Roller (https://github.com/rollerwhrtn)
* Shawn Zamechek (https://github.com/shawnzam/)
* Todd Seidelmann (https://github.com/seidelma/)
* Brian Jopling
* Clay Wells

