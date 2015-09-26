Upgrading from Rails 3.2 to Rails 4.0
=====================================
In this document I describe the steps to upgrade *Secondhand* from Rails 3.2 to
Rails 4.0. The current versions used are

* Ruby 1.9.3-p547
* Rails 3.2.11
* RVM 1.26.11

We are using following RVM gemset for the application

* ruby-1.9.3-p547@rails3211

We run the migration in two phases. First we do a preparation phase where we
update the application to the most recent versions within the major version.
When this is done we do the actual migration. 

The preparation steps to follow are

* Run the tests and ensure they pass
* Check out a new branch for the migration process
* Update to the lates Ruby 1.9.3 patch level
* Update to the lates Rails 3.2 version

## Run the tests first
First make sure all your tests pass by running *rspec*.

    $ rspec

If you encounter errors first fix them before you move on.

## Check out a new branch
Before you do any changes to your project check out a new branch. In case you
mess up your project you always can safely rewind to your master branch and
start from a blank slade again.

    $ git checkout -b rails4-0

## Update Ruby to the latest patch level
That is not neccessary but to be on the safe side I want to have the latest 
patch level of Ruby 1.9.3. We can check the versions with

    $ rvm list known | grep 1.9.3
    [ruby-]1.9.3[-p551]

To update to that version we issue

    $ rvm install 1.9.3

Now we copy the current gemset to a new gemset with the freshly installed Ruby 
version

    $ rvm gemset copy ruby-1.9.3-p547@rails3211 ruby-1.9.3-p551@rails3211
    $ rvm ruby-1.9.3-p551@rails3211

We check that we have the Ruby version available and the Rails version of the
old gemset

    $ ruby -v
    ruby 1.9.3p551 (2014-11-13 revision 48407) [x86_64-linux]
    $ rails -v
    Rails 3.2.11

Finally we run our test and make sure everything runs without errors.

    $ rspec

If anything breaks make sure to first fix the error before moving on.

## Update to the latest Rails 3.2 version
We could start to upgrade our app from the current version to version 4.0, but 
it is adviced to upgrade from the most current version. To find the most recent
version we can issue

    $ gem list ^rails$ --remote --all | grep -oP "3.2.\d{1,}"
    3.2.22
    3.2.21
    3.2.20
    ...
    3.2.0

So the most recent Rails version is 3.2.22 that we want to update our 
application to. The first step is to add the version to our *Gemfile*. We 
replace the line `gem 'rails', '3.2.11'` with `gem 'rails' '3.2.22'`. Then we
need to run

    $ bundle update rails

Next run your tests with

    $ rspec

If the update issues any errors, fix them and then run your tests. If you get 
errors than try `$ rake db:test:prepare` and *rspec* again.

Only move on if all your tests pass without errors.


