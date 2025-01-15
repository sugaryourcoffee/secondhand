Install _rbenv_ and _Ruby_
==========================

This document is briefly describing how to install _rbenv_ and _Ruby_ with _rbenv_. We follow the instructions at [rbenv](https://github.com/rbenv/rbenv?tab=readme-ov-file#basic-git-checkout) and What we do is 

* Install _rbenv_
* Install ...
* Install _Ruby_ with a specific version 
* Activate the _Ruby_ version for the application _Secondhand_

Install rbenv
-------------

Before we install _rbenv_ we make sure we have all dependencies install ed

    $ apt-get install autoconf patch build-essential rustc libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libgmp-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev uuid-dev

To install _rbenv_ we can do with `sudo apt install rbenv`. But this will not provide the latest version. We therefore will install from _rbenv_'s git repository by cloning the _rbenv_ into `~/.rbenv`


    $ git clone https://github.com/rbenv/rbenv.git ~/.rbenv

Then to make the shell (in our case Bash) aware of _rbenv_ we call 

    $ ~/.rbenv/bin/rbenv init 

After closing and re-opening the shell we can use _rbenv_.

To install _Ruby_ we need to additionally install the _ruby-build_ plugin.

    git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build

Following updates can be done with `git -C "$(rbenv root)"/plugins/ruby-build pull`.

Install Ruby 
------------

We `cd Secondhand` and install our _Ruby_ we are using with our _Rails_ application. At the time of this writing we are about to update _Secondhand_ to _Rails 4.2.11_.

So the installation is as follow s

    $cd Secondhand 
    $rbenv install 2.7

To make it available we issue the command 

    $ rbenv local 2.7

To verify _Ruby 2.7_ is installed we issue

    $ ruby -v 
    ruby 2.7.2p137 (2020-10-01 revision 5445e04352) [x86_64_linux]
