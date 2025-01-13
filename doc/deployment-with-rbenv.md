Deployment
==========
We already have described how to deploy *Secondhand* with `rvm-capistrano` and `rvm`. The description can be found here:

[deployment](https://github.com/sugaryourcoffee/secondhand/blob/master/doc/deployment.md). 

With the upgrade to Rails 4.2 I have changed from `rvm` to `rbenv`. That is, that this document describes how to do the deployment with `capistrano` without `rvm`, but `rbenv`.

In this document we are deploying *Secondhand* with

* Ruby 2.7.8
* Rails 4.2.11
* Phusion Passenger(R) 6.0.24
* Capistrano 

We have a beta, a staging and a production server. We refer to them as uranus (beta and staging),
mercury (production).

The task now is to 

* Install Ruby 2.7.8
* Copy secondhand to the staging server uranus
* Install gems and rails 4.2.11.3
* Test secondhand is working
* Install Passenger
* Configure the Apache webserver
* Install and configure MySQL as the production database
* Set up capistrano for multi staging
* Deploy the new version to the staging server
* Test the new version
* Deploy to production after testing the new application on the staging server

Prepare the server machine
==========================

We `ssh` to the server machine uranus and copy secondhand to the machine to `~/Secondhand`. We `cd Secondhand` and install _rbenv_ and _Ruby 2.7_. How this is done can be found at [install-rbenv-and-ruby](install-rbenv-and-ruby.md).

On the server machine in `~/Secondhand` we install bundler with `gem install bundler`. With `bundle install` we are installing rails and the gems, necessary for the _Secondhand_ application.

Now we check whether our application is runing with `rails -s -b 0.0.0.0`. From our client machine we start the browser and open address `uranus:3000`. Port 3000 is the default port rails is starting up the application.

If everthing runs we stop the server and go to the step of installing passenger.

Installing passenger
--------------------
Passenger can be installed with `gem install passenger` or as a package from _Phusion Passenger_'s _apt_-repostitory. We will go with the latter and follow the instructions at [Ubuntu 24.04 LTS (with APT)](https://www.phusionpassenger.com/docs/advanced_guides/install_and_upgrade/standalone/install/oss/noble.html). At the time of this writing, the instructions are following

First we install the PGP key and add HTTPS support for APT

    sudo apt-get install -y dirmngr gnupg apt-transport-https ca-certificates curl

    curl https://oss-binaries.phusionpassenger.com/auto-software-signing-gpg-key.txt | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/phusion.gpg >/dev/null

Then we add the _passenger_ APT repository

    sudo sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger noble main > /etc/apt/sources.list.d/passenger.list'

Now we run `sudo apt-get update` and install install the _passenger_ and _Apache_ module with

    sudo apt-get install -y libapache2-mod-passenger

With installation a _.conf_ and _.load_ file is provided and stored to _Apaches_'s module directory located at `/etc/apache2/mods-available`.

Next we have to make _Apache_ aware of the _passenger_ configuration files with `sudo a2enmod passenger` and then restart _Apache_ with `sudo apache2ctl restart`.

We can check whether the installation is correct with the helper tool provided by _passenger_ 

    $ sudo passenger-config validate-install
    What would you like to validate?
    Use <space> to select.
    If the menu doesn't display correctly, press '!'
    
       ⬢  Passenger itself
     ‣ ⬢  Apache
    
    -------------------------------------------------------------------------
    
    Checking whether there are multiple Apache installations...
    Only a single installation detected. This is good.
    
    -------------------------------------------------------------------------
    
     * Checking whether this Passenger install is in PATH... ✓
     * Checking whether there are no other Passenger installations... ✓
     * Checking whether Apache is installed... ✓
     * Checking whether the Passenger module is correctly configured in Apache... ✓
    
    Everything looks good. :-)

In the validation we validated both, _Passenger_ and _Apache_. The output of the command finally states that _everything looks good :-)_.

Note: Some of _Passenger_'s assistance applications like _passenger-status_ created some weired errors liker

### Phusion Passenger(R) seems to be running

    $ passenger-status
    ERROR: Phusion Passenger(R) doesn't seem to be running. If you are sure that it is running, then the causes of this problem could be:
    
    1. You customized the instance registry directory using Apache's PassengerInstanceRegistryDir option, Nginx's passenger_instance_registry_dir option, or Phusion Passenger(R) Standalone's --instance-registry-dir command line argument. If so, please set the environment variable PASSENGER_INSTANCE_REGISTRY_DIR to that directory and run passenger-status again.
    2. The instance directory has been removed by an operating system background service. Please set a different instance registry directory using Apache's PassengerInstanceRegistryDir option, Nginx's passenger_instance_registry_dir option, or Phusion Passenger(R) Standalone's --instance-registry-dir command line argument.

I had an installation of _Passenger_ via `gem install passenger`. When invoking _Passenger_ without `sudo` the call to `passenger-status` was reffering to the local passenger and assuming a standalone passenger instance. As it couldn't find the application it failed. `cd ~/Secondhand` into the projects directory made it run. But I didn't want to run it standalone mode, but integrated in _Apache_. 

I de-installed the _Passenger_ gem and ran `sudo passenger-status` which gave me a new error.

### too long unix socket path

    $ sudo passenger-status
    Version : 6.0.17
    Date    : 2025-01-09 12:42:44 +0000
    Instance: VCq0uTrH (Apache/2.4.58 (Ubuntu) Phusion_Passenger/6.0.17)
    
    DEBUG: agents.s/core_api, #<Net::HTTP::Get:0x000073f823086418>
    /usr/lib/ruby/vendor_ruby/phusion_passenger/admin_tools/instance.rb:95:in `initialize': too long unix socket path (116bytes given but 108bytes max) (ArgumentError)
    
The path which was too long was `/tmp/systemd-private-33a08d6f92bb4d2fa073e34ff2c174d9-apache2.service-5wOIrF/tmp/passenger.9P3DcDu/agents.s/core_api`

_Passenger_ saves instances in the `/tmp` directory. The reason for the error was that it was privatized (see the _-private_ in the path). In order to get shorter pathes we have to set in `/etc/systemd/system/multi-user.target.wants/apache2.service` the variable `PrivateTmp=false`. If it doesnt't exist then just add it.

After that change we must run `sudo systemctl daemon-reload` and then `sudo systemctl restart apache2` to make the change effective.

Configure Apache 2 to deploy secondhand (development)
-----------------------------------------------------

To deploy _secondhand_ we need to create the configuration, so _Apache_ can expose it to the world. We add to `/etc/apache2/sites-available/secondhand.conf` following code:

    <VirtualHost *:8082>                                        # 8082 is the port over which we can reach secondhand 
      ServerName secondhand.uranus                              # this is the address where we can access secondhand: http://secondhand.uranus:8082
      PassengerRuby /home/pierre/.rbenv/versions/2.7.2/bin/ruby # This can be obtained with the "passenger-config about ruby-command" see below
      DocumentRoot /home/pierre/Secondhand/public/              # This is where the application can be found. We need to point to ../public
      <Directory /home/pierre/Secondhand/public>                # The same URL as with DocumentRoot root 
        AllowOverride all                                       # ...
        Options -MultiViews                                     # Don't allow multi-views
        Order allow,deny                                        # ...
        Allow from all                                          # ...
        Require all granted                                     # ...
      </Directory>
      RackEnv development                                       # We will use the development environment to test that everything works in the combination
    </VirtualHost>                                              # with Apache2 and Phusion Passenger

We started the deployment with copying the development environment of _Secondhand_ to the server _uranus_. We started to test the application with `rails -s -b 0.0.0.0`, to see whether it is runing as on our development machine. In this step now we use the very same installation to test if it runs with _Apache_ and _Passenger_. This is indicated by `RackEnv development`. We go in really small steps.

To obtain the _Ruby_ version for _Secondhand_ we can do so with. Important: don't run it with `sudo`, if so the _APT_ installed _Ruby_ will be listed, if available.

    $ passenger-config about ruby-command
    passenger-config was invoked through the following Ruby interpreter:
      Command: /home/pierre/.rbenv/versions/2.7.2/bin/ruby
      Version: ruby 2.7.2p137 (2020-10-01 revision 5445e04352) [x86_64-linux]
      To use in Apache: PassengerRuby /home/pierre/.rbenv/versions/2.7.2/bin/ruby
      To use in Nginx : passenger_ruby /home/pierre/.rbenv/versions/2.7.2/bin/ruby
      To use with Standalone: /home/pierre/.rbenv/versions/2.7.2/bin/ruby /usr/bin/passenger start
    
    The following Ruby interpreter was found first in $PATH:
      Command: /home/pierre/.rbenv/versions/2.7.2/bin/ruby
      Version: ruby 2.7.2p137 (2020-10-01 revision 5445e04352) [x86_64-linux]
      To use in Apache: PassengerRuby /home/pierre/.rbenv/versions/2.7.2/bin/ruby
      To use in Nginx : passenger_ruby /home/pierre/.rbenv/versions/2.7.2/bin/ruby
      To use with Standalone: /home/pierre/.rbenv/versions/2.7.2/bin/ruby /usr/bin/passenger start

The important part is `To use in Apache: PassengerRuby /home/pierre/.rbenv/versions/2.7.2/bin/ruby`. This is what we add in our `/etc/apache2/sites-available.conf` as `PassengerRuby /home/pierre/.rbenv/versions/2.7.2/bin/ruby`.

Next we have to enable the site with `sudo a2ensite secondhand`. As we have set the port to 8082, we need to add this port in `/etc/apache2/ports.conf`, so that _Apache_ is listening on this port. We add to `/etc/apache2/ports.conf`

    Listen 8082

Finally to make this all active we have to restart _Apache_ with `sudo apache2ctl restart`.

Testing Secondhand together with Apache and Passenger 
-----------------------------------------------------

Now we should be able to access _Secondhand_ in combination with _Apache2_ and _Passenger_:

    http://uranus:8082

When we have accessed _Secondhand_ we can check up the functionality of _Passenger_ and _Apache_ with 

    $ sudo passenger-memory-stats
    [sudo] password for pierre:
    Sorry, try again.
    [sudo] password for pierre:
    Version: 6.0.24
    Date   : 2025-01-09 19:53:45 +0000
    
    ----------- Apache processes ------------
    PID     PPID    VMSize     Private  Name
    -----------------------------------------
    534659  1       76.3 MB    0.7 MB   /usr/sbin/apache2 -k start
    534693  534659  1957.2 MB  4.0 MB   /usr/sbin/apache2 -k start
    534695  534659  1957.2 MB  3.8 MB   /usr/sbin/apache2 -k start
    ### Processes: 3
    ### Total private dirty RSS: 8.57 MB
    
    
    -------- Nginx processes --------
    
    ### Processes: 0
    ### Total private dirty RSS: 0.00 MB
    
    
    ------ Passenger processes -------
    PID     VMSize     Private   Name
    ----------------------------------
    534662  360.8 MB   2.7 MB    Passenger watchdog
    534666  2057.6 MB  7.8 MB    Passenger core
    535706  269.7 MB   102.1 MB  Passenger RubyApp: /home/pierre/Secondhand (development)
    ### Processes: 3
    ### Total private dirty RSS: 112.67 MB

This shows us that _Apache_ is running and _Secondhand_ is managed by _Passenger_.

If it is not working _Passenger_ might show a website hinting to the error. Or we can look into _Apache_'s error log-file, located at `/var/log/apache2/error.log`. We can also look into _Secondhand_'s log files at `~/Secondhand/log/development.log`. Remembere we are running the _development_ environment. Therefore we have to look into the `development.log` file.

Mapping the secondehand's host name 
-----------------------------------

(TODO: ^^^^ I don't think this is necessary on the server. This is rather necessary on the clients accessing Secondhand)

Now we want to map the IP address von the server _uranus_ to the `ServerName secondhand.uranus`. On the server machine _uranus_ we can list the interfaces with:

    $ ip link
    1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
        link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    2: enp4s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP mode DEFAULT group default qlen 1000
        link/ether c8:60:00:ce:65:fb brd ff:ff:ff:ff:ff:ff

The second entry is our Ethernet interface. We can determine the IP address with:

    $ ip -4 address show dev enp4s0
    2: enp4s0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
        inet 192.168.178.164/24 metric 100 brd 192.168.178.255 scope global dynamic enp4s0
           valid_lft 786657sec preferred_lft 786657sec

In `/etc/hosts` on the server machine _uranus_ we map the IP-address to the host name 

    127.0.0.1	    localhost secondhand.uranus
    127.0.1.1	    uranus
    192.168.178.164 uranus.fritz.box uranus

What's next?
------------

As a next step we create our production development. _Apache_ applications live usually in `/var/www/`. Therefore we create the directory `/var/www/secondhand`.

Configure Apache 2 to deploy secondhand (production)
-----------------------------------------------------

Now we go the next step towards production. Still with manual interaction and we don't have the actual production ready software. We are in the branch _upgrade-to-rails-4.2_. We take it step by step, before we go for automation with _Capistrano_. 

During development we already have managed _Secondhand_ with _git_. We now clone _Secondhand_ into our directory. For that to work we have to define our web directory. The default location for that is at `/var/www/secondhand`.

What we do in this section is 

* create our web directory `/var/www/secondhand`
* clone our _Secondhand_ branch _upgrade-to-rails-4.2_ into `/var/www/seconhand`
* install the gems required by _Secondhand_
* prepare the production environment
* install _MySQL_
* migrate our database 
* adopt our _Apache_'s `secondhand.config` file 
* test the web application

### Create the web directory 

The default place to host websites is at `/var/www`, this is where we also host _Secondhand_. We create the directory with 

    $ sudo mkdir -p /var/www/secondhand 

This directory is owned by `root`, in order to deploy we need to change the owner, so no `root`-rights are necessary.

    $ sudo chown pierre: /var/www/secondhand


### Clone _Secondhand_ to the web directory 

Next we `cd /var/www/secondhand` and clone the application under `secondhand` into `code`

    $ git clone https://github.com/sugaryourcoffee/secondhand/ code

We still want to test the upgraded _Secondhand_, that is why we have to checkout the branch `upgrade-to-rails-4.2` first 

    $ git checkout upgrade-to-rails-4.2

### Install gems for _Secondhand_

In the newly created project directory `/var/www/secondhand/code/` we now have install the gems required by _secondhand_ and have to set the _Ruby_ version. The _Ruby_ version required by _secondhand_ is in the file `/var/www/secondhand/code/.ruby_version`. If we don't have the _Ruby_ version available in this directory we get an error like 

    rbenv: version `2.7.8' is not installed (set by /var/www/secondhand/code/.ruby-version)

_secondhand_ we have just cloned requires version 2.7.8. As this is not available. Therefore we need to install the requested _Ruby_ version with `rbenv install 2.7.8`. 

Next we check if `bundler` is available with `bundler -v`. This presents us with the informations

    Could not find 'bundler' (1.17.3) required by your /var/www/secondhand/code/Gemfile.lock. (Gem::GemNotFoundException)
    To update to the latest version installed on your system, run `bundle update --bundler`.
    To install the missing version, run `gem install bundler:1.17.3`

We want to install the version that is requested, which is stated as _1.17.3_. We install bundler with `gem install bundler -v 1.17.3`. If we run now `bundler -v` we get the information `Bundler version 1.17.3`. Now we should be good to install. 

    $ bundle install

After the gems have been installed we get following post install messages 

    Bundle complete! 37 Gemfile dependencies, 149 gems now installed.
    Use `bundle info [gemname]` to see where a bundled gem is installed.
    Post-install message from prawn:
    
      ********************************************
    
    
      A lot has changed recently in Prawn.
    
      Please read the changelog for details:
    
      https://github.com/prawnpdf/prawn/wiki/CHANGELOG
    
    
      ********************************************
    
    Post-install message from rubyzip:
    RubyZip 3.0 is coming!
    **********************
    
    The public API of some Rubyzip classes has been modernized to use named
    parameters for optional arguments. Please check your usage of the
    following classes:
      * `Zip::File`
      * `Zip::Entry`
      * `Zip::InputStream`
      * `Zip::OutputStream`
    
    Please ensure that your Gemfiles and .gemspecs are suitably restrictive
    to avoid an unexpected breakage when 3.0 is released (e.g. ~> 2.3.0).
    See https://github.com/rubyzip/rubyzip for details. The Changelog also
    lists other enhancements and bugfixes that have been implemented since
    version 2.3.0.

Finally check if _Secondhand_ starts up with `rails server`.

### Install _MySQL_

In production we want to use the _MySQL_ database. For that we need the _mysql2_ gem, which we have previously installed with `bundle install`. Additionally we need to install the _MySQL_ database through _APT_ and create our production database.

_MySQL_ is usually installed during the installation of the server operating system. If not then we can install it with 

    $sudo apt-get install mysql-server libmysqlclient-dev

`libmysqlclient-dev` is required by the `mysql2` gem.

### Create the database 

We need to login to _MySQL_ to create the database. If we lost the password then there is an article how to recover the password at [TheLinuxCode](https://thelinuxcode.com/change-mysql-password-ubuntu-22-04/) and a summary [here](reset-the-mysql-root-password.md).

Now we create the database for our staging server. 

    $ sudo mysql -uroot -p 
    Enter password
    mysql> create database secondhand_staging default character set utf8;
    Query OK, 1 row affected, 1 warning (0.12 sec)

Why the warning? _MySQL_ has changed the character sets. `utf8` is automatically converted to `utf8mb3` with a collation of `utf8mb3_general_ci`. And this is not what we want. The _utf8mb3_ stores character with maximum 3 bytes, whereas `UTF8` stores up to 4 bytes. So the substitute for `UTF8` is `utf8mb4` with the collation of `utf8mb4_0900_ai_ci`. We alter the table to use `utf8mb4`

    mysql>  alter database secondhand_staging character set utf8mb4 collate utf8mb4_0900_ai_ci;
    Query OK, 1 row affected (0.10 sec)

To see that it has been set correctly we can look at the character set with 
    
    mysql> select default_character_set_name, default_collation_name from information_schema.schemata where schema_name = 'secondhand_staging';
    +----------------------------+------------------------+
    | DEFAULT_CHARACTER_SET_NAME | DEFAULT_COLLATION_NAME |
    +----------------------------+------------------------+
    | utf8mb4                    | utf8mb4_0900_ai_ci     |
    +----------------------------+------------------------+
    1 row in set (0.00 sec)

Next we create the user that is accessing the database from the _Secondhand_ application and the grant the privileges to that user

    mysql> create user 'pierre'@'localhost' identified by 'password';
    Query OK, 0 rows affected (0.11 sec)
    mysql> grant all privileges on secondhand_staging.* to 'pierre'@'localhost';
    Query OK, 0 rows affected (0.08 sec)

Now we are done 

    mysql> exit 
    Bye 

*For future reference*
    
    $ sudo mysql -uroot -p 
    Enter password
    mysql> create database secondhand_staging default character set utf8mb4 collate utf8mb4_0900_ai_ci;
    Query OK, 1 row affected (0.12 sec)
    mysql> create user 'pierre'@'localhost' identified by 'password';
    Query OK, 0 rows affected (0.11 sec)
    mysql> grant all privileges on secondhand_staging.* to 'pierre'@'localhost';
    Query OK, 0 rows affected (0.08 sec)
    mysql> exit 
    Bye 

Now that the database is created we want to create the tables based on our database migrations. Our `config/database.yml` is the information that is used to create the database. The part that is interesting for the next step is this:

    staging:                          # staging is the environment we want to use with following settings
      adapter: mysql2                 # the mysql2 gem that is bridging between Secondhand and the MySQL database
      encoding: utf8                  
      reconnect: false
      database: secondhand_staging    # the database we have created in MySQL
      pool: 5
      timeout: 5000
      username: pierre                # the user that we have granted all rights to access the database
      password: password              # the password we have given the user
      host: localhost

So we have the database `secondhand_staging` created, we have the environment for `staging` set. Now we can create the tables for our database.

    $ rake db:setup RAILS_ENV="staging"
    secondhand_staging already exists
    -- create_table("carts", {:force=>true})
       -> 0.3473s
    -- add_index("carts", ["user_id"], {:name=>"index_carts_on_user_id"})
       -> 0.7274s
    -- create_table("conditions", {:force=>true})
       -> 0.5916s
    -- create_table("events", {:force=>true})
       -> 0.4591s
    -- create_table("items", {:force=>true})
       -> 0.4591s
    -- create_table("line_items", {:force=>true})
       -> 0.4842s
    -- create_table("lists", {:force=>true})
       -> 0.4507s
    -- create_table("news", {:force=>true})
       -> 0.3340s
    -- create_table("news_translations", {:force=>true})
       -> 0.4104s
    -- create_table("pages", {:force=>true})
       -> 0.4009s
    -- add_index("pages", ["terms_of_use_id"], {:name=>"index_pages_on_terms_of_use_id"})
       -> 0.8017s
    -- create_table("reversals", {:force=>true})
       -> 0.8330s
    -- create_table("sellings", {:force=>true})
       -> 0.7507s
    -- create_table("terms_of_uses", {:force=>true})
       -> 0.5008s
    -- create_table("users", {:force=>true})
       -> 0.5926s
    -- add_index("users", ["email"], {:name=>"index_users_on_email", :unique=>true})
       -> 0.3608s
    -- add_index("users", ["remember_token"], {:name=>"index_users_on_remember_token"})
       -> 0.4090s
    -- initialize_schema_migrations_table()
       -> 1.5028s
    
*Note:*

If it happens that the password in the `config/database.yml` file doesn't match with the one we have given when we created the user, then you get a error message like this 

    $ rake db:setup RAILS_ENV="staging"
    WARNING: MYSQL_OPT_RECONNECT is deprecated and will be removed in a future version.
    Access denied for user 'pierre'@'localhost' (using password: YES)Please provide the root password for your MySQL installation
    >

Check that the user and password match with the one you have given access to the `secondhand_staging` database.

Just our of interest we want to look into _MySQL_ and look at our database.

    $ mysql -upierre -p 
    Enter password:
    mysql> show databases;
    +--------------------+
    | Database           |
    +--------------------+
    | information_schema |
    | performance_schema |
    | secondhand_staging |
    +--------------------+
    3 rows in set (0.00 sec)
    
    mysql> use secondhand_staging;
    Reading table information for completion of table and column names
    You can turn off this feature to get a quicker startup with -A
    
    Database changed
    mysql> show tables;
    +------------------------------+
    | Tables_in_secondhand_staging |
    +------------------------------+
    | carts                        |
    | conditions                   |
    | events                       |
    | items                        |
    | line_items                   |
    | lists                        |
    | news                         |
    | news_translations            |
    | pages                        |
    | reversals                    |
    | schema_migrations            |
    | sellings                     |
    | terms_of_uses                |
    | users                        |
    +------------------------------+
    14 rows in set (0.00 sec)
    
    mysql> desc carts;
    +------------+--------------+------+-----+---------+----------------+
    | Field      | Type         | Null | Key | Default | Extra          |
    +------------+--------------+------+-----+---------+----------------+
    | id         | int          | NO   | PRI | NULL    | auto_increment |
    | created_at | datetime     | NO   |     | NULL    |                |
    | updated_at | datetime     | NO   |     | NULL    |                |
    | cart_type  | varchar(255) | YES  |     | SALES   |                |
    | user_id    | int          | YES  | MUL | NULL    |                |
    +------------+--------------+------+-----+---------+----------------+
    5 rows in set (0.00 sec)
    
    mysql> desc lists;
    +-------------------+--------------+------+-----+---------+----------------+
    | Field             | Type         | Null | Key | Default | Extra          |
    +-------------------+--------------+------+-----+---------+----------------+
    | id                | int          | NO   | PRI | NULL    | auto_increment |
    | list_number       | int          | YES  |     | NULL    |                |
    | registration_code | varchar(255) | YES  |     | NULL    |                |
    | container         | varchar(255) | YES  |     | NULL    |                |
    | event_id          | int          | YES  |     | NULL    |                |
    | user_id           | int          | YES  |     | NULL    |                |
    | created_at        | datetime     | NO   |     | NULL    |                |
    | updated_at        | datetime     | NO   |     | NULL    |                |
    | sent_on           | datetime     | YES  |     | NULL    |                |
    | accepted_on       | datetime     | YES  |     | NULL    |                |
    | labels_printed_on | datetime     | YES  |     | NULL    |                |
    +-------------------+--------------+------+-----+---------+----------------+
    11 rows in set (0.00 sec)
    
    mysql> exit 
    Bye 

So everything seems in order. Good!

### Make _Secondhand_ staging ready
    
Now we basically repeat what we have done in the first deployment scenario, running in the development environment. We now change the `virtual host` from _Apache_ that currently is serving the development environment, so it's serving the _staging_ environment. We change the `/etc/apache2/sites_available/secondhand.conf` to `etc/apache2/sites-available/secondhand-staging.conf`

    $ cd /etc/apache2/
    $ cp sites-enabled/{secondhand.conf, secondhand-staging.conf}
    $ vim sites-enabled/secondhand{,-staging}.conf 

we change the content so it looks like this 

    <VirtualHost *:8083>
      ServerName staging.secondhand.uranus
    
      DocumentRoot /var/www/secondhand/code/
    
      PassengerRuby /home/pierre/.rbenv/versions/2.7.8/bin/ruby
    
      <Directory /var/www/secondhand/code/>
        AllowOverride all
        Options -MultiViews
        Order allow,deny
        Allow from all
        Require all granted
      </Directory>
      RackEnv staging
    </VirtualHost>

The procedure is as previously. We have to enable the new virtual host and then re-start _Apache_.

    $ sudo a2ensite secondhand-staging

What we also need to do is to pre-compile our assets 

    $ bundle exec rake assets:precompile RAILS_ENV=staging 

And now we are ready to restart _Apache_

    $ sudo apache2ctl restart 

### Test _Secondhand_

The test with the staging server revealed an error when a user is signing up for _Secondhand_. The mail delivery raised an error.

    NoMethodError (undefined method `disable_starttls_auto' for #<Net::SMTP localhost:25 started=false>
    Did you mean?  disable_starttls
                   enable_starttls_auto):
      app/controllers/users_controller.rb:33:in `create'

Regarding this [post](https://github.com/mikel/mail/issues/1550) the error is in the gem `mail 2.8.0`. The development environment didn't raise this error, neither on the development machine nor hosted by _Apache_. Finally it turned out that the development machine had set `config.action_mailer.delivery_method = :test` in `config/environments/development.rb`. This doesn't send e-mails using the `mail` gem. Coming back to the hint in the above mentioned post I have upgraded `mail` to 2.8.1 and it worked. On the development machine I upgraded as well and checked that the tests pass, what they did.

Now we should be ready to deploy remotely with _Capistrano_.

Setting up the client machine
=============================
On the client machine (ellesmere) we do following configuration

* Setup Capistrano
* Assign an URI to the beta, staging and production server
* Add a rails beta and staging environment
* Add a beta and staging group to the database.yml file

Install Capistrano
------------------
We add Capistrano to the Gemfile [Gemfile](https://github/sugaryourcoffee/secondhand/blob/master/Gemfile)

    gem 'capistrano'

and we remove `rvm-capistrano` from the Gemfile.

    # gem 'rvm-capistrano'

