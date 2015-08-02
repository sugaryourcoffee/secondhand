Deployment
==========
This is the description of deploying secondhand with

* Ruby 1.9.3p547
* Rails 3.2.11
* Capistrano 2.15.5

Secondhand has a production server at 
[syc.dyndns.org:8080](http://syc.dyndns.org:8080) and a staging server at 
[syc.dyndns.org:8081](http://syc.dyndns.org:8081). The staging server is 
hosting multiple rails applications. We will refer to the production server 
with `mercury` and to the staging server with `uranus`.

What we want to accomplish is 

* Set up capistrano for multi staging
* Copy the production database from the production to the staging application
* Deploy the new version to the staging server
* Test the new version
* Deplay to production after testing the new application on the staging server

Setup the Client machine
========================
We have to do some configuration on the client machine

* Setup Capistrano
* Assign a URI to the production and staging server
* Add a staging group to the database.yml file

## Install Capistrano
As we are using RVM add `rvm-capistrano` to the [Gemfile](https://github/sugaryourcoffee/secondhand/blob/master/Gemfile)

    gem 'rvm-capistrano'

the run bundle install

    $ bundle install

## Set up capistrano
To setup Capistrano we issue `capify .` which will create the configuration
files

    $ capify .

This will create the 
[Capfile](https://github/sugaryourcoffee/secondhand/blob/master/Capfile) that 
loads the Capistrano tasks. The other file that is created is the 
[config/deploy.rb](https://github/sugaryourcoffee/secondhand/blob/master/config/deploy.rb)
where we describe our deployment tasks and the deployment configuration.

## Set up Capistrano for multi staging
The multi staging Wiki for Capistrano 2.x can be found at 
[2.x Multistage Extension](https://github.com/capistrano/capistrano/wiki/2.x-Multistage-Extension). Another source can be found in the outstand but 
unfortunately out dated book 
[Deploying Rails](https://pragprog.com/book/cbdepra/deploying-rails).

We want to have two stages, namely staging and production. We have to provide 
the configuration for each stage. The default place for such configuration 
files is the `config/deploy/` directory.

We create the `config/deploy/` directory

    $ mkdir config/deploy

As we have already the production deployment configuration in `config/deploy.rb`
we copy that to `config/deploy/production.rb`

    $ cp config/deploy.rb config/deploy/production.rb

We again copy `config/deploy.rb` to `config/deplay/staging.rb`

    $ cp config/deploy.rb config/deploy/staging.rb

The only difference between production and staging is that we have a different
server. So we change the server configuration in `config/deploy/staging.rb`

    set :domain, 'secondhand.uranus'

And we also set the rails environment to staging

    set :rails_env, :staging

In config/deploy/production.rb we set the rails environment to :production

    set :rails_env, :production

To configure for multi staging we replace the content in 
[config/deploy.rb](https://github/sugaryourcoffee/secondhand/blob/master/config/deploy.rb) with

    set :stages %w(staging production)
    set :default_stage, "staging"
    require 'capistrano/ext/multistage'

    set :application, 'secondhand'

## Add a staging group to database.yml
We want to use a different database for staging. To do so we add staging 
group to `config/database.yml`

    staging:
      adapter: mysql2
      encoding: utf8
      reconnect: false
      database: secondhand_staging
      pool: 5
      timeout: 5000
      username: user
      password: password
      host: localhost

## Assign a hostname to the staging server
In the Capistrano configuration files we refer to the servers with 
`secondhand.uranus` and `secondhand.mercury`. To make that work we have to
assign the IP-address of the servers to the respective name. We do that in
`/etc/hosts`

    192.168.178.61 secondhand.mercury
    192.186.178.66 secondhand.uranus

Setup the Staging Server
========================
We assume that we have already setup the server's basic configuration. That is
we have Ruby and Rails as well as Phusion Passenger installed and Apache 2 is
configured with Phusion passenger. How to set up a complete deployment server 
you can find at [Apptrack](https://github.com/sugaryourcoffee/apptrack/blob/master/doc/deployment.md)

## Create the application directory
We want to host our staging server under `/var/www/` which is Apache's default
web directory. We create a directory where we want to host our application

    $ mkdir /var/www/secondhand
    $ cd secondhand

## Install Ruby and Rails
Secondhand is using Ruby 1.9.3p547 and Rails 3.2.11 so we install it with RVM

### Install Ruby
To install Ruby we invoke

    $ rvm install 1.9.3
   
We activate Ruby 1.9.3 with

    $ rvm use 1.9.3

And check whether it is installed and active

    $ ruby -v

### Install Rails
Next we create a Gemset to install Rails to

    $ rvm gemset create rails3211
    $ rvm ruby-1.9.3-p547@rails3211
    $ gem install rails --version 3.2.11 --no-ri --no-rdoc

Now we check the rails version installed

    $ rails -v

## Setup Apache 2
We already have setup Apache 2 and all the Phusion Passenger configuration. On
how to do it refer to [Apptrack](https://github.com/sugaryourcoffee/apptrack/blob/master/doc/deployment.md).

### Configure the port to listen on
We want to access secondhand through port 8082. We add to 
`/etc/apache2/ports.conf`

    Listen 8082

### Configure a virtual host for secondhand
To enable Apache 2 to host secondhand we add a virtual host to
`/etc/apache2/sites-available/secondhand.conf`

```
   <VirtualHost *:8082>
      ServerName secondhand
      DocumentRoot /var/www/secondhand/current/public    
      PassengerRuby /home/pierre/.rvm/gems/ruby-1.9.3p547@rails3211/wrappers/ruby
      <Directory /var/www/secondhand/current/public>
         # This relaxes Apache security settings.
         AllowOverride all
         # MultiViews must be turned off.
         Options -MultiViews
         # Uncomment this if you're on Apache >= 2.4:
         Require all granted
         # apptrack is using the Ruby version in the gemset
      </Directory>
   </VirtualHost>
```

In the virtual host we indicate with `PassengerRuby` that we want to use
Ruby 1.9.3. Other applications might use different Rubies and can indicate with
that directive which Ruby to use.

Now we restart Apache 2 with the new configuration

    $ sudo apachectl restart

