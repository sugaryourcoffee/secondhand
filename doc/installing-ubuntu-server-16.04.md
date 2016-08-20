# Install Ubuntu Server on a Dell Poweredge T130 server hardware
To install Ubuntu Server there are some easy steps to follow. We are 
using a Dell PowerEdge T130. The manuals can be found at [dell.com/poweredgemanuals](http://www.dell.com/support/home/de/de/debsdt1/product-support/product/poweredge-t130/research)

The current Secondhand application is best hosted on a Ubuntu Server 14.04 LTS
but we will also point out some hints in regard to 16.04 LTS.

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
4. Install Posfix
5. Setup printer
6. Install Nodejs
7. Install RVM
8. Install Rails
9. Install Git
10. Install Passenger
11. Configure Apache 2

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

## Install MySQL
We have to install MySQL and create the database. Make sure not to only install
the _mysql-server_ but also the _libmysqlclient-dev_ otherwise bundler will fail
to install the _mysql2_ gem.

    $ sudo apt-get install mysql-server libmysqlclient-dev

Next we have to create a database

    $ mysql -uroot -p
    mysql> create database secondhand_production default character set utf8;
    mysql> grant all privileges on secondhand_production.* 
        -> to 'pierre'@'localhost' identified by 'secret';
    mysql> exit

## Install Passenger

    $ gem install passenger
    $ passenger-install-apache2-module

There might be missing some modules and the installer will tell which are
missing and have to be installed.

    $ sudo apt-get install libcurl4-openssl-dev apache2-threaded-dev \
    libapr1-dev libaprutil1-dev

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
run `$ sudo a2enconf passenger` and `service apache2 reload`.

## Configure Apache 2
Create a virtual host in `/etc/apache2/sites-available/secondhand.conf`

    <VirtualHost *:8086>
      DocumentRoot /var/www/secondhand/current/public
      Servername backup.secondhand.jupiter
      PassengerRuby /home/pierre/.rvm/gems/ruby-2.0.0-p648@rails4013/wrappers/\
      ruby 
      <Directory /var/www/secondhand/public>
        AllowOverride all
        Options -MultiViews
        Require all granted
      </Directory>
      RackEnv backup
    </VirtualHost>

Then run `$ sudo a2ensite secondhand` and `service apache2 reload`.

# Adjust the development environment
In this step we conduct following ajustments

1. Create a backup environment in `config/environments/backup.rb`
2. Add the _backup_ stage to `config/deploy.rb`
3. Create a backup deployment file in `config/deploy/backup.rb`
4. Add a _backup_ group to `config/database.yml`
5. Add the server hostname _backup.secondhand.jupiter_ to `/etc/hosts`

## Adjust `config/deploy/backup.rb`
Set the `rvm_ruby_string` to the gemset where we have installed rails

    set :rvm_ruby_string, '2.0.0@rails4013'

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

## Errors during deployment
Here are listed some errors that might come up during deployment. Some specific
to Ubunter 16.04 Server LTS.

### No connection to Github
If the deployment is canceled because of an credential issue try 
`ssh-add -l`. If it doesn't return a fingerprint but instead saying 
`The agent has no identities` then redo `ssh-add` but this time with the path to
you key `$ ssh-add .ssh/id_rsa`. Then check on the server wheather you can
connect to github with `$ ssh -T git@github.com`.

### MySQL gem cannot be installed
When capistrano is executing bunlder on the backup server an error might occur
saying

    * 2016-08-18 14:06:30 executing `bundle:install'                            
    * executing "cd /var/www/secondhand/releases/20160818120630 && bundle 
    install --gemfile /var/www/secondhand/releases/20160818120630/Gemfile 
    --path /var/www/secondhand/shared/bundle --deployment --quiet 
    --without development test"         
      servers: ["backup.secondhand.jupiter"]                                    
      [backup.secondhand.jupiter] executing command                             
    ** [out :: backup.secondhand.jupiter] An error occurred while installing 
    mysql2 (0.3.20), and Bundler cannot continue.                               
    ** [out :: backup.secondhand.jupiter] Make sure that 
   `gem install mysql2 -v '0.3.20'` succeeds before bundling.                   
      command finished in 12435ms                                               
    *** [deploy:update_code] rolling back

This most likely is because you are missing `libmysqlclient_dev` on the backup
server. To resolve this issue

    $ sudo apt-get install libmysqlclient-dev

### MySQL access denied
If the deployment is aborted during _deploy:migrate_ with the error 
`MySQL2::Error, Access denied for user` then you probably don't have created
the database.

### Mysql2::Error: All parts of a PRIMARY KEY must be NOT NULL
Ubuntu Server 16.04 LTS ships with MySQL 5.7.13. Since version 5.7 it is not 
allowed to have PRIMARY KEYs to be NULL. Here we are using Rails 4.0.13 and we
have to monkey patch the _Mysql2Adapter_ to fix this. In later versions 4.1 and
above this is fixed.

The error during deployment is showing

    * 2016-08-18 15:22:36 executing `deploy:migrate'                          
    * executing "cd /var/www/secondhand/releases/20160818132225 && bundle exec
    rake RAILS_ENV=backup  db:migrate"                                        
      servers: ["backup.secondhand.jupiter"]
      [backup.secondhand.jupiter] executing command
    *** [err :: backup.secondhand.jupiter] rake aborted!
    *** [err :: backup.secondhand.jupiter] StandardError: An error has occurred,
    all later migrations canceled:
    *** [err :: backup.secondhand.jupiter]
    *** [err :: backup.secondhand.jupiter] Mysql2::Error: All parts of a PRIMARY
    KEY must be NOT NULL; if you need NULL in a key, use UNIQUE 
    instead: CREATE TABLE `events` (`id` int(11) DEFAULT NULL auto_increment 
    PRIMARY KEY, `title` varchar(255), `event_date` datetime, `location` 
    varchar(255), `fee` decimal(2,2), `deduction` decimal(2,2), `provision` 
    decimal(2,2), `max_lists` int(11), `max_items_per_list` int(11), 
    `created_at` datetime, `updated_at` datetime) ENGINE=InnoDB 

The monkey patch is to be saved to `config/initializers/mysql_adapter`

    class ActiveRecord::ConnectionAdapters::Mysql2Adapter
      NATIVE_DATABASE_TYPES[:primary_key] = "int(11) auto_increment PRIMARY KEY"
    end

But this is not reliably working in all cases. If it doesn't consider upgrading 
to Rais 4.1 or using Ubuntu 14.04 Server.

# Configuring Failover
In case our secondhand master server mercury is crashing we want to point to our
secondhand backup server jupiter. We already installed secondhand on jupiter.
Next we need to start replicating the database from mercury. How this can be
accomplished is described in [MySQL-failover](https://github.com/sugaryourcoffee/secondhand/blob/master/doc/MySQL-failover.md).

