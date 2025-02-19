# Setting up a Secondhand development environment on Ubuntu 22.04 LTS

If you want to partcipate in the Secondhand development and contribute code, then you can conduct the following workflow

* Creating a working directory
* Install git
* Install rbenv
* Setup the ruby build environment
* Install the ruby plug-in *ruby-build*
* Install ruby
* Setup the rails runtime environment
* Clone Secondhand from github
* Install rails with bundler
* Verify the installation
* Create a ssh key for git

We are working on Ubuntu 22.04 LTS and the Rails version Secondhand is running on is 4.2.11.3 with Ruby 2.7.

## Creating a working directory

My projects all go under '~/Work'.

    cd ~
    mkdir Work

## Install git

Secondhand is managed in a Git repository. We install Git with

    sudo apt-get install git

## Install *rbenv*

*rbenv* allows to install (needs a plug-in see below) and manage different ruby versions. You can install *rbenv* from [github](https://github.com/rbenv/rbenv).

    git clone https://github.com/rbenv/rbenv.git ~/.rbenv

Add *rbenv* to *bashrc*

    echo 'eval "$(~/.rbenv/bin/rbenv init - bash)"' >> ~/.bashrc

Now ether restart bash, or issue `source ~/.bashrc` so the new added entry to *.bashrc* takes effect.

## Setup the ruby build environment 

Before installing ruby we need to set up the build environment. How to set it up can be looked up at [github](https://github.com/rbenv/ruby-build/wiki#suggested-build-environment).

    sudo apt-get install autoconf patch build-essential rustc libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev

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

Make ruby 2.7.2 the default version with

    rbenv global 2.7.2

List available ruby versions, that are still supported

    rbenv install -l

To also show all ruby versions, including unsupported run

    rbenv install -L

## Setup the rails runtime environment

To run rails we need a database and a JavaScript interpreter. The secondhand development environment is using *SQLite3*. In the production we use *MySQL*. As JavaScript interpreter we use *node.js*.

    sudo apt-get install sqlite3 libsqlite3-dev libmysqlclient-dev mysql-server nodejs

## Clone Secondhand from github

We want to clone Secondhand from Github to the development machine. We change into the *Work* directory

    cd ~/Work/

then we clone Secondhand into the *Work* directory

    git clone https://github.com/sugaryourcoffee/secondhand.git

or if we want to clone a specific branch

    git clone --branch upgrade-to-rails-4.2 https://github.com/sugaryourcoffee/secondhand.git

## Install rails with bundler

With the installation of ruby the *gem* program is installed. This allows to install gems from [rubygems.org](https://rubygems.org/).

We can install rails with the gem, or we can use bundler to install rails based on our *Gemfile*. We need to make sure to install the correct *bundler* version. To find out which version of bundler is requested we can look it up in *Gemfile.lock* with

    $ cat Gemfile.lock | grep bundle

we should get output like

    bundler (>= 1.3.0, < 2.0)

On another machine we have running *bundler 1.17.3*

    $ gem install bundler:1.17.3

To list the installed gems call

    $ gem list

or to list specific gems, like bundler

    $ gem list bundler

Now we are ready to install rails with 

    $ bundle install

## Verifying the installation

We can verify the installation with

    $ rails -v

it should show 

    4.2.11.3

## Create the test database and run tests

Before we run the tests we have to create the test database with `$ bundle exec rake db:schema:load RAILS_ENV=test`

Then we can run the tests with

    $ bundle exec rspec

## Run the application

Same as with tests we first need to create the development database with

    $ bundle exec rake db:schema:load RAILS_ENV=development

And if we start the server with

    $ rails -s

we should be able to access the Secondhand application at [localhost:3000](http://localhost:3000/).

## Create ssh key for git

In order to push changes of our application to git we need to create and provide a ssh key to git. A more detailed description can be found on github at [Connecting to GitHub with SSH](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).

    $:~/Work/secondhand$ ssh-keygen -t ed25519 -C "pierre@sugaryourcoffee.de"
    Generating public/private ed25519 key pair.

Next we hit return to chose the default location

    Enter file in which to save the key (/home/pierre/.ssh/id_ed25519): 

We use a passphrase to secure the key

    Enter passphrase (empty for no passphrase): 
    Enter same passphrase again: 

    Your identification has been saved in /home/pierre/.ssh/id_ed25519
    Your public key has been saved in /home/pierre/.ssh/id_ed25519.pub
    The key fingerprint is:
    SHA256:4xC+plC0HSOYbqyG/YXO6nWu9D91s2uYBHR994yIezc pierre@sugaryourcoffee.de
    The key's randomart image is:
    +--[ED25519 256]--+
    |           .     |
    |        . . . . .|
    |      .. . . i +.|
    |     = .. . R . o|
    |    + = S. . .   |
    |   + . A.-= . .  |
    | o. * *.ox * .   |
    |. oX *.   + .    |
    | .=+Bzo.  .o     |
    +----[SHA256]-----+

Now add the ssh key to the ssh-agent

    $:eval "$(ssh-agent -s)"
    Agent pid 440559
    $:~/Work/secondhand$ ssh-add ~/.ssh/id_ed25519
    Enter passphrase for /home/pierre/.ssh/id_ed25519: 
    Identity added: /home/pierre/.ssh/id_ed25519 (pierre@sugaryourcoffee.de)

Finally add the key to the github account

The description how to add the ssh-key to the github account is nicely described here [adding a new SSH key to your account](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account#adding-a-new-ssh-key-to-your-account).

Note: I have encountered a problem by issuing the command `git push`, that I was asked to provide username and password. This was because for what reason ever the `.git/config` file contained the URL *https://github.com/sugaryourcoffee/secondhand.git* instead of *git@github.com:sugaryourcoffee/secondhand.git*
