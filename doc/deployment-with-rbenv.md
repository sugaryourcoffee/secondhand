Deployment
==========
We already have described how to deploy *Secondhand* with `rvm-capistrano` and `rvm`. The
description can be found here:

[deployment](https://github.com/sugaryourcoffee/secondhand/blob/master/doc/deployment.md). 

With the upgrade to Rails 4.2 I have changed from `rvm` to `rbenv`. That is, that this 
document describes how to do the deployment with `capistrano` without `rvm`, but `rbenv`.

In this document we are deploying *Secondhand* with

* Ruby 2.7.2
* Rails 4.2.11
* Capistrano 

We have a beta, a staging and a production server. We rever to them as uranus (beta and staging),
mercury (production).

The task now is to 

* Set up capistrano for multi staging
* Copy the production database from the production to the staging application
* Deploy the new version to the staging server
* Test the new version
* Deploy to production after testing the new application on the staging server

Setting up the client machine
=============================
On the client machine (saltspring) we do following configuration

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




