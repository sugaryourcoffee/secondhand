Deployment
==========
We already have described how to deploy *Secondhand* with `rvm-capistrano` and `rvm`. The description can be found here:

[deployment](https://github.com/sugaryourcoffee/secondhand/blob/master/doc/deployment.md). 

With the upgrade to Rails 4.2 I have changed from `rvm` to `rbenv`. That is, that this document describes how to do the deployment with `capistrano` without `rvm`, but `rbenv`.

In this document we are deploying *Secondhand* with

* Ruby 2.7.2
* Rails 4.2.11
* Phusion Passenger(R) 6.0.24
* Capistrano 

We have a beta, a staging and a production server. We refer to them as uranus (beta and staging),
mercury (production).

The task now is to 

* Install Ruby 2.7.2
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

No we go the next step towards production. Still with manual interaction. We take it step by step, before we go for automation with _Capistrano_. 

During development we already have managed _Secondhand_ with _git_. We now clone _Secondhand_ into our directory. For that to work we have to define our proction environment. For that we need to 

* install _MySQL_
* migrate our database 
* adopt our _Apache_'s `secondhand.config` file 



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

