# Setting up a Secondhand development environment on Ubuntu 22.04 LTS

If you want to partcipate in the Secondhand development and contribute code, then you can conduct the following workflow

* Creating a working directory
* Install rbenv
* Setup the ruby build environment
* Install the ruby plug-in *ruby-build*
* Install ruby
* Setup the rails runtime environment
* Install bundler
* Install git
* Pull Secondhand from github
* Install rails with bundler
* Verify the installation

We are working on Ubuntu 22.04 LTS and the Rails version Secondhand is running on is 4.2.11.3 with Ruby 2.7.

## Creating a working directory

My projects all go under '~/Work'.

    cd ~
    mkdir Work

## Install *rbenv*

*rbenv* allows to install (needs a plug-in see below) and manage different ruby versions. You can install *rbenv* from [github](https://github.com/rbenv/rbenv).

    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc

## Setup the ruby build environment 

Before installing ruby we need to set up the build environment. How to set it up can be looked up at [github](https://github.com/rbenv/ruby-build/wiki#suggested-build-environment).

    apt-get install autoconf patch build-essential rustc libssl-dev libyaml-dev libreadline6-dev \
    zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev

If if doesn't work, then look for additional information at above mentioned web-site.

## Install the ruby plug-in *ruby-build*

In order to install ruby with *rbenv* the *ruby-build* plugin is needed which can be found at [github](https://github.com/rbenv/ruby-build#readme). 

    git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

You can update with 

    git -C "$(rbenv root)"/plugins/ruby-build pull

## Install ruby

Ruby can now be installed with *rbenv*

Install ruby version 2.7.2

    rbenv install 2.7.2

List available ruby versions

    rbenv install -l

## Setup the rails runtime environment

To run rails we need a database and a JavaScript interpreter. The secondhand development environment is using *SQLite3*. As JavaScript interpreter we use *node.js*.

    sudo apt-get install sqlite3 libsqlite3-dev nodejs

## Install bundler
With the installation of ruby the *gem* program is installed. This allows to install gems from [rubygems.org](https://rubygems.org/).

To install bundler run

    gem install bundler

## Install git

Secondhand is managed in a Git repository. We install Git with

    sudo apt-get install git

## Clone Secondhand from github

We want to clone Secondhand from Github to the development machine.

    cd ~/Work/
    git clone https://github.com/sugaryourcoffee/secondhand.git

or if we want to clone a specific branch

    git --branch upgrade-to-rails-4.2 https://github.com/sugaryourcoffee/secondhand.git

## Install rails with bundler

We can install rails with the gem, or we can use bundler to install rails based on our *Gemfile*. We need to make sure to install the correct *bundler* version. To find out which version of bundler is requested we can look it up in *Gemfile.lock*.

    cat Gemfile.lock | grep bundle
    bundler (>= 1.3.0, < 2.0)

On another machine we have running *bundler 1.17.3*

    gem install bundler:1.17.3

## Verifying the installation

We can verify the installation with

    rails -v
    4.2.11.3

And if we start the server with

    rails -s

we should be able to access the Secondhand application [Secondhand](localhost:3000).

