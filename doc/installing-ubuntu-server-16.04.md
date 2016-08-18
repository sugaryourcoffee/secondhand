# Install Ubuntu Server 16.04 on a Dell Poweredge T130 server hardware
To install Ubuntu Server 16.04 there are some easy steps to follow. We are 
using a Dell PowerEdge T130. The manuals can be found at [dell.com/poweredgemanuals](http://www.dell.com/support/home/de/de/debsdt1/product-support/product/poweredge-t130/research)

1. Download ISO file from [ubuntu.com](http://www.ubuntu.com/download/server/install-ubuntu-server)
2. Burn CD with the downloaded ISO file
3. Start the server hardware from CD
4. Follow the instructions prompted by the installation guide

When prompted for _Software selection_ select 

* Mail server
* Standard system utilities
* OpenSSH server

# Install Ruby on Rails server environment

1. Install Apache 2
2. Create the application directory
3. Install MySQL
4. Install Nodejs
5. Install RVM
6. Install Rails
7. Install Passenger
8. Configure Apache 2

## Create an application directory
Apache 2's default application directory is at `/var/www`. There we add the 
directory for our secondhand backup application. But before we do this we have
to change the owner.

This directory is owned by _root_. When we deploy our application we need to 
have it owned by the user deploying which is in our case the deployment user.
In order to enable the deployment user to deploy we change the owner and give it
write access

    $ sudo chgrp deployers /var/www
    $ sudo chmod g+w /var/www

Now we can create the directory which will be owned by the user

    $ sudo mkdir /var/www/secondhand

## Install Passenger

    $ gem install passenger
    $ passenger-install-apache2-module

There might be missing some modules and the installer will tell which are
missing and have to be installed.

    $ sudo apt-get install libcurl4-openssl-dev apache2-dev libapr1-dev\
    libaprutil1-dev

Even though the installer might tell you to install `apache2-threaded-dev` in
Ubuntu 16.04 you have to use `apache2-dev`.

After `passenger-install-apache2-module` has run you will be prompted with
following message:

    Please edit your Apache configuration file, and add these lines:
    LoadModule passenger_module \
    /home/pierre/.rvm/gems/ruby-2.0.0-p648@rails4013/gems/passenger-5.0.30\
    /buildout/apache2/mod_passenger.so
    <IfModule mod_passenger.c>
      PassengerRoot /home/pierre/.rvm/gems/ruby-2.0.0-p648@rails4013/gems\
      /passenger-5.0.30
      PassengerDefaultRuby /home/pierre/.rvm/gems/ruby-2.0.0-p648@rails4013\
      /wrappers/ruby
    </IfModule>
    
    After you restart Apache, you are ready to deploy any number of web
    applications on Apache, with a minimum amount of configuration!
    
    Press ENTER when you are done editing.

Add the above code snippet to `/etc/apache2/conf-available/passenger.conf` and 
run `$ apache2 a2enconf`.

## Configure Apache 2
Create a virtual host in `/etc/apache2/sites-available/secondhand.conf

    <VirtualHost *:8083>
      DocumentRoot /var/www/secondhand/current/public
      Servername backup.secondhand.jupiter
      PassengerRuby /home/pierre/.rvm/gems/ruby-2.0.0-p648@rails4013/wrappers/ruby 
      <Directory /var/www/secondhand/public>
        AllowOverride all
        Options -MultiViews
        Require all granted
      </Directory>
      RackEnv backup
    </VirtualHost>

# Adjust development environment
In this step we conduct following ajustments

1. Create a backup environment in `config/environments/backup.rb`
2. Add the _backup_ stage to `config/deploy.rb`
3. Create a backup deployment file in `config/deploy/backup.rb`
4. Add a _backup_ group to `config/database.yml`
5. Add the server hostname _backup.secondhand.jupiter_ to `/etc/hosts`

# Deploy to the backup server
During deployment the application is downloaded from Github. To download from
Github a rsa key is required that is known to Github. We use the key from our
development machine by copying it to the backup server

    $ scp ~/.ssh/id_rsa me@jupiter:key
    $ ssh jupiter
    $ mv key ~/.ssh/id_rsa

Next we start the ssh agent with `$ eval $(ssh-agent)` and issue `$ ssh-add`.
After entering the passphrase we should be good to deploy.

One final tweak is to ommit entering a passphrase when we deploy. To do that we
copy the public key from our development machine to our backup server

    $ scp ~/.ssh/id_rsa.pub me@jupiter:key
    $ ssh jupiter
    $ cat key >> ~/.ssh/authorized_keys

Back on the development resp. deployment machine we initially issue following 
commands to prepare deployment

    $ cap backup deploy:setup
    $ cap backup deploy:check
    $ cap backup deploy:cold

If the deployment is canceled because of an credential issue try 
`ssh-add -l`. If it doesn't return a fingerprint but instead saying 
`The agent has no identities` then redo `ssh-add` but this time with the path to
you key `$ ssh-add .ssh/id_rsa`.

