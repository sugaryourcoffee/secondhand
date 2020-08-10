Upgrading from Rails 4.1 to Rails 4.2
=====================================
In this document I describe the steps to upgrade *Secondhand* from Rails 4.1 to
Rails 4.2. Further information can be found at 
[railsguides](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-4-1-to-rails-4-2)
Other upgrade instructions can be found at

* [Upgrading from Rails 3.2 to Rails 4.0](./upgrading-rails-3.2-to-rails-4.0.md)

* [Upgrading from Rails 4.0 to Rails 4.1](./upgrading-rails-4.0-to-rails-4.1.md)

The current versions used are

* Ruby 2.0.0-p648
* Rails 4.1.16
* RVM 1.29.3

We are using following RVM gemset for the application

* ruby-2.0.0-p648@rails-4116-secondhand

We run the migration in two stages. First we do a preparation phase where we
update the application to the most recent versions within the major version.
When this is done we do the actual migration. 

The preparation steps to follow are

* Run the tests and ensure they pass
* Tag the current version to Git
* Check out a new branch for the migration process
* Update to the latest Ruby 2.0.0 patch level
* Update to the latest Rails 4.1 version

The actual migration is as follows

* Check out a new branch for the upgrade process
* Prepare the Gemfile
* Run `bundle install`
* Update the configuration files
* Upgrade the bin/ directory
* Update `config/routes`
* Remove errors disclosed by rspec runs
* Remove deprecation warnings disclosed by rspec runs
* Merge back to the master branch

# Stage 1 - Prepare for Upgrade
This is stage 1 where we prepare for upgrading our Rails 4.1 app to Rails 4.2.
We first move to the gemset that is hosting Secondhand

    $ rvm ruby-2.0.0-p648@rails-4116-secondhand

## Run the tests first
First make sure all your tests pass by running *rspec*.

    $ rspec

If you encounter errors first fix them before you move on.

Note: Test for JavaScript might not work due to incompatibility between Silenium
Webdriver and the Firefox versions. If there is an error during the JavaScript 
Capybara tests check if the description in the 
[Devlopment Notes](development_notes.md) document helps.

## Tag the current application version
Before we move on we want to make sure that we can come back to the currently
working and released version. To do that we create a branch and tag this 
branch with a version number.

We first want to create a branch with the released version in order to be able
to make changes especially bug fixes to this version. This is necessary if 
users won't immediately upgrade to the new version.

    $ git checkout -b v3.0.0-stable
    $ git push --set-upstream origin v3.0.0-stable

Next we want to tag this branch with a version number. To list the already taken
tags we can issue

    $ git tag
    v1.0
    v1.0.1
    v1.0.2
    v1.1.0
    v2.0.0
    v2.0.1
    v3.0.0

To tag our branch we checkout *v3.0.0-stable* (we should already be on that 
branch from the previous checkout command though) and then issue the tag command

    $ git checkout v3.0.0-stable
    $ git tag -a v3.0.0 -m "Secondhand V3.0.0 - Release 2020-08-03"

Finally push the tagged commit to Github with

    $ git push --tags

## Check out a new branch
Before you do any changes to your project check out a new branch. In case you
mess up your project you always can safely rewind to your master branch and
start from a blank slate again.

    $ git checkout -b rails4-2

## Update Ruby to the latest patch level
That is not necessary but to be on the safe side I want to have the latest 
patch level of Ruby 2.0.0. We can check the latest available versions with

    $ rvm list known | grep 2.0.0
    [ruby-]2.0.0[-p648]

    It happens that we are already on the lates Ruby v2.0.0 version. But asuming we wouldn't be the process how to install and create new gemsets is shown in the document [upgrading-rails-4.0-to-rails-4.1.md](https://github.com/sugaryourcoffee/secondhand/blob/master/doc/upgrading-rails-4.0-to-rails-4.1.md#update-ruby-to-the-latest-patch-level).

## Update to the latest Rails 4.1 version
We could start to upgrade our app from the current version to version 4.1, but 
it is advised to upgrade from the most current version. To find the most recent
version we can issue

    $ gem list ^rails$ --remote --all | grep -oP "4.1(.\d{1,})*"
    4.1.16
    4.1.15
    4.1.14.2
    ..
    4.1.0
    4.1
    
So it seems we are already on the most recent Rails version which is 4.1.16. 

To make this step complete we are assuming that we are on 4.1.15. So we would 
be not on the latest version, and the first step is to add the version to our 
*Gemfile* by replacing the line `gem 'rails', '4.1.15'` with 
`gem 'rails' '4.1.16'`. Then we need to run

    $ bundle update rails

and run your tests with

    $ rspec

If the update issues any errors, we have to fix them and then run the tests
again. If you get errors than try `$ rake db:test:prepare` and *rspec* again.

Only move on if all your tests pass without errors.

## Merge the updated app to the master branch
Now that we have updated our Secondhand app to the most current Ruby and Rails 
versions we want to merge the changes back to the master branch. We first 
checkout the master branch and then push them to github.

    $ git checkout master
    $ git merge rails4-2
    $ git push

Just to be sure we run rspec again.

Now we are ready to actually upgrade to Rails 4.2.

# Stage 2 - Upgrade to Rails 4.2
Now we are prepared to actually upgrade to Rails 4.1. We checkout a new branch

    $ git checkout -b upgrade-to-rails-4.2
    $ git push --set-upstream origin upgrade-to-rails-4.2

## Prepare the Gemfile
The first step is to change the Ruby version in the Gemfile. But we also want
to set the version numbers for the other gems listed in the Gemfile so they
meet the pre-conditions working with Rails 4.2. To see what gem versions we need
in combination with Ruby 4.2 we create a Rails project with the most recent
Rails 4.2 version, which is at this writing *4.2.11.3*.

To not override our gemset *rails-4116-secondhand* we use *ruby 2.0.0-p648* and
create a new gemset and switch to it before installing the new rails version

    $ mkdir ~/Work/rails-version-test
    $ cd ~/Work/rails-version-test
    $ rvm 2.0.0-p648
    $ rvm gemset create rails-4.2.11.3-version-test
    $ rvm ruby-2.0.0-p648@rails-4.2.11.3-version-test
    $ gem install rails --version 4.2.11.3

Surprisingly the rails installation stops with an error even though Rails 4.2
should be compatible with Ruby 2.0.0. This is because rails uses Sprockets 
which requires Ruby 2.5.0 at least. Allright then, we try it with Ruby 2.5.7

    $ rvm install 2.5

Now let's repeat the process from before

    $ rvm 2.5.7
    $ rvm gemset create rails-4.2.11.3-version-test
    $ rvm ruby-2.5.7@rails-4.2.11.3-version-test
    $ gem install rails --version 4.2.11.3
    $ rails _4.2.11.3_ new test-4.2.11.3
 
By the way, we don't need the gemset rails-4.2.11.3-version-test so let's delete
it with

    $ rvm 2.0.0-p648 do rvm gemset delete rails-4.2.11.3-version-test

In the Gemfile we can see the gem version that work together with Rails 4.2.11.3
The table below lists the gems (from the Secondhand Gemfile) with the versions
of the *test-4.2.11.3* app indicated by `~>` and `>=`. Note that only part of
the gems are in the 4.2.11.3 Gemfile, the other gems we have to lookup at 
[rubygems.org](https://rubygems.org) that go together with Rails 4.2.11.3.

Gem                      | Rails 4.1.16 | Rails 4.2.11.3   | Group
------------------------ | ------------ | ---------------- | -----------------
rails                    | 4.1.16       | 4.2.11.3         | top              
bootstrap-sass           | 2.3.2.0      |                  | top              
faker                    | ~> 1.6.6     |                  | top              
will\_paginate           | 3.1.5        |                  | top              
bootstrap-will\_paginate | 0.0.10       |                  | top              
prawn                    | 1.3.0        |                  | top              
prawn-table              | ~> 0.2.2     |                  | top              
syc-barcode              | 0.0.3        |                  | top              
net-ssh                  | ~> 2.9.2     |                  | top              
turbolinks               |              |                  | top              
jquery-turbolinks        |              |                  | top              
sqlite3                  |              |                  | development      
rspec-rails              | 2.99.0       |                  | development,test 
guard-rspec              | 4.6          |                  | development      
annotate                 | 2.6.10       |                  | development      
guard-spork              | 2.1          |                  | test             
spork                    | 0.9          |                  | test             
capybara                 | 2.1.0        |                  | test             
rb-inotify               | 0.9.0        |                  | test             
libnotify                | 0.5.9        |                  | test             
factory\_girl\_rails     | 1.4.0        |                  | test             
cucumber-rails           | 1.2.1        |                  | test             
database\_cleaner        | 1.5.0        |                  | test             
selenium-webdriver       |              |                  | test             
sass-rails               | ~> 4.0.3     | ~> 5.0           | top              
coffee-rails             | ~> 4.0.0     | ~> 4.1.0         | top              
uglifier                 | >= 1.3.0     | >= 1.3.0         | top              
jquery-rails             |              |                  | top              
best\_in\_place          |              |                  | top              
gritter                  | ~> 1.2.0     |                  | top              
bcrypt                   | ~> 3.1.7     | ~> 3.1.7         | top              
rvm-capistrano           | ~> 1.5.6     |                  | top              
mysql2                   |              |                  | production       
jbuilder                 | ~> 2.0       | ~> 2.0           | top              
sdoc                     | ~> 0.4.0     | ~> 0.4.0         | doc               
spring                   | x            |                  | development       
byebug                   | x            |                  | development,test 
web-console              | x            | ~> 2.0           | development      

x = not installed

We start by changing the rails version in our Gemfile to 

    gem 'rails', '4.2.11.3'

and then run `bundle install`. We will get a bundler message saying

    Your Gemfile lists the gem rspec-rails (~> 2.99.0) more than once.
    You should probably keep only one of them.
    While it's not a problem now, it could cause errors if you change the 
    version of one of them later.
    Fetching gem metadata from https://rubygems.org/................
    Fetching version metadata from https://rubygems.org/...
    Fetching dependency metadata from https://rubygems.org/..
    Resolving dependencies........
    Bundler could not find compatible versions for gem "railties":
      In snapshot (Gemfile.lock):
          railties (= 4.1.16)
          
      In Gemfile:
        best_in_place was resolved to 3.0.3, which depends on
          railties (>= 3.2)
                      
        coffee-rails (~> 4.0.0) was resolved to 4.0.1, which depends on
          railties (< 5.0, >= 4.0.0)
                                
        coffee-rails (~> 4.0.0) was resolved to 4.0.1, which depends on
          railties (< 5.0, >= 4.0.0)
                                          
        factory_girl_rails (= 1.4.0) was resolved to 1.4.0, which depends on
          railties (>= 3.0.0)
                                                    
        jquery-rails was resolved to 3.1.4, which depends on
          railties (< 5.0, >= 3.0)
                                                              
        jquery-turbolinks was resolved to 2.1.0, which depends on
          railties (>= 3.1.0)
                                                                        
        rails (= 4.2.11.3) was resolved to 4.2.11.3, which depends on
          railties (= 4.2.11.3)

        rspec-rails (~> 2.99.0) was resolved to 2.99.0, which depends on
          railties (>= 3.0)

      Running `bundle update` will rebuild your snapshot from scratch, using 
      only the gems in your Gemfile, which may resolve the conflict.
  
If we run

    $ bundle update 
    
    Gem::InstallError: rake requires Ruby version >= 2.2.
    An error occurred while installing rake (13.0.1), and Bundler
    cannot continue.
    Make sure that `gem install rake -v '13.0.1'` succeeds before bundling.

Now we get the information in order to install rake we need to upgrade our 
Ruby version to '>= 2.2`. Let's try that by using Ruby 2.5.7 as we have been
notified to use Ruby 2.5 when we experimentally installed Rails 4.2.

    $ rvm ruby-2.5.7

    IMPORTANT! Some of the defaults have changed in Capybara 2.1. 
    If you're experiencing failures, please revert to the old behaviour by 
    setting:

        Capybara.configure do |config|
          config.match = :one
          config.exact_options = true
          config.ignore_hidden_elements = true
          config.visible_text_only = true
        end

    If you're migrating from Capybara 1.x, try:

        Capybara.configure do |config|
          config.match = :prefer_exact
          config.ignore_hidden_elements = false
        end

    Details here: http://www.elabs.se/blog/60-introducing-capybara-2-1

    Post-install message from prawn:

      ********************************************


      A lot has changed recently in Prawn.

      Please read the changelog for details:

      https://github.com/prawnpdf/prawn/wiki/CHANGELOG


      ********************************************

Now we should have the version 4.2.11.3 installed. We can proof it by issuing

    $ rails -v
    Rails 4.2.11.3

Note: We have installed the new rails version into the current
gemset 'ruby-2.5.7'. We want to rename the gemset so it reflects the ruby 
version, the rails version and the application we are using it for.

    $ rvm gemset copy ruby-2.5.7 ruby-2.5.7@rails-4.2.11.3-secondhand-upgrade

## Update Secondhand configuration files
Now we use a rake task that helps to interactively update configuration files.

    $ rake rails:update

We get an error running the update tast. It is caused by rspec-rails 2.99 which is using an obsolete method 'last_comment' that has been replace in Rake.
To fix this we add to the Rakefile (source stackoverflow)

    # Fix no method error 'last_comment'
    module FixRakeLastComment
    def last_comment
      last_description
    end
    end
    Rake::Application.send :include, FixRakeLastComment
    # Fix end

A description on how to update from Rspec 2.99.0 can be found at [Rspec upgrade guide](https://relishapp.com/rspec/docs/upgrade).

Now the update task runs and will ask whether to overwrite the old files with
new files. With `d` we can diff the old and the new file. Here is how we process Secondhand.

File                                    | Overwrite | After update action
--------------------------------------- | --------- | -------------------
config/boot.rb                          | no        | no *
config/routes.rb                        | no        | yes *
config/application.rb                   | no        | no *
config/environment.rb                   | no        | no *
config/secrets.yml                      | yes       | no *
conifg/environments/development.rb      | no        | yes *
config/environsments/production.rb      | no        | yes *
config/environments/staging.rb          | no        | no
config/environments/test.rb             | no        | yes *
config/environments/beta.rb             | no        | no
config/initializers/assets.rb           | no        | no *
config/initializers/cookies\_serializer.rb | yes       | no * 
config/initializers/inflections.rb      | no        | no *
config/initializers/mime\_types.rb      | no        | no *
config/initializers/secret\_token.rb    | yes       | no -
config/locales/en.yml                   | no        | no *
bin/rails                               | yes       | no *
bin/setup                               | create    | no *

### config/secrets.yml

Change of the scret\_key\_base by rake rails:update

### config/environments/development.rb

Rails 4.1.16                        | Rails 4.2.11.3
----------------------------------- | ---------------------------------------
                                    | config.assets.digest = true

### config/environments/production.rb

Rails 4.1.16                          | Rails 4.2.11.3
------------------------------------- | ------------------------------------------------
config\_serve\_static\_assets = false | config.serve_static_files = ENV['RAILS_SERVE_STATIC_FILES'].present?

### config/environments/test.rb

Action      | Description
----------- | --------------------------------------------  
test\_order | # Randomize the order test cases are executed.
            | config.active_support.test_order = :random


Rails 4.1.16                        | Rails 4.2.11.3
----------------------------------- | ------------------------------------
config.serve\_static\_assets = true | config.serve\_static\_files   = true

## Run the specs
When running the specs we get the information that we should add SQLITE3 into
our Gemfile. Actually it is there. A duckduckgo search reports on an issue of
Rails in combination with SQLITE3. What works ist SQLITE 1.3.6.

We clean up the gem SQLITE3 1.4. Then we add 'gem 'sqlite3', '~>1.3.6' and
run 'bundle install'.

Another run of 'rspec' shows that the issue is fixed but we get deprecation 
warnings, failures and a problem with 'Selenium::WebDriver'. But first we 
have a look at the deprecation warnings.

## Deprecation Warnings
This section describes deprecation warnings revealed by rspec after upgrading
to Rails 4.2.11.3

### 'named\_routes.helpers'
`named\_routes.helpers` is deprecated, please use 
`route\_defined?(route\_name)` to see if a named route was defined.

This is caused in combination with rails 4.2 and rspec 2.99.0 which doesn't 
go together. 

Action is to upgrade to rspec 3 as described in [Project: RSpec Rails 3.9](https://relishapp.com/rspec/rspec-rails/v/3-9/docs/upgrade)

After the upgrade to rspec-rails 3.9 the deprecation warning is gone.

### '#deliver'
`#deliver` is deprecated and will be removed in Rails 5. Use `#deliver\_now`

### URL Helpers
Calling URL helpers with string keys controller, action is deprecated. Use 
symbols instead.

There is one usage in the 'user\_show' view. For what ever reason I put 'params' in the 'register\_list\_user\_path(@user, params)' but it works just fine
without 'params' as far as I can tell. Let's keep the change and observe it.

### ActiveRecord::Base.find
You are passing an instance of ActiveRecord::Base to `find`. Please pass the id of the object by calling `.id`.

## Check for required code changes
This section describes the checks to do to disclose code that has to be 
changed due to changes in Rails 4.2 according to 
[rails guides](https://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-4-1-to-rails-4-2)

File         | Action
------------ | ----------------------------------------
Gemfile      | add web-console and run 'bundle install'
ActionMailer | replace 'deliver' with 'deliver_now'

There are more upgrade topics but not relevant for the Secondhand
application.

## Error Messages
In this section error message are discussed that have arisen after upgrading 
to Rails 4.2.

### Fixing errors revealed by rspec runs
When running rspec we get following 19 errors that worked with the previously
used Rails 4.1.16 version.

    1) List export to CSV should not have ';' in any field
       Failure/Error: list.as_csv.split(';').size.should eq 16
       ArgumentError:
         unknown encoding name - u
    2) User when password is not present should not be valid
       Failure/Error: it {should_not be_valid}
         expected #<User id: nil .....> not to be valid

    17) Newsletter create by admin user should show errors on unclomplete 
        input
        Failure/Error: page.all('input', visible: true).size.should eq 8

           expected: 8
                got: 9

           (compared using ==)
    x1) Unable to find Mozilla geckodriver. Please download the server from 
        [https://github.com/mozilla/geckodriver/releases](https://github.com/mozilla/geckodriver/releases) 
        and place it somewhere on your PATH. More info at 
        [https://developer.mozilla.org/en-US/docs/Mozilla/QA/Marionette/WebDriver](https://developer.mozilla.org/en-US/docs/Mozilla/QA/Marionette/WebDriver).

#### 1) List export to CSV should not have ';' in any field
The CSV module changed the UTF-8 encoding name from 'u' to 'UTF-8'.

#### 2) User when password is not present should not be valid
With Rails 4.2 the validation of 'allow\_blank' now also includes empty
strings, therefore the validation fails and hence the test. Changed the code
from 'allow\_blank' to 'unless: -> { password.nil? || password.empty? }'

#### 17) Newsletter create by admin user should show errors on unclomplete input

#### x1) Selenium::WebDriver::Error::WebDriverError:
RSpec comes up with following error message

    Unable to find Mozilla geckodriver. Please download the server from
    [https://github.com/mozilla/geckodriver/releases](https://github.com/mozilla/geckodriver/releases) 
    and place it somewhere on your PATH. More info at 
    [https://developer.mozilla.org/en-US/docs/Mozilla/QA/Marionette/WebDriver](https://developer.mozilla.org/en-US/docs/Mozilla/QA/Marionette/WebDriver).

A step by step process is described in the [development-notes](development-notes.md]). A short summary follows.

* download as described the geckodriver for Firefox
* copy the geckodriver to a directory
* add the directory to the PATH environment variable

After having the geckodriver installed RSpec runs and starts the Selenium 
webdriver. But the RSpec run reveals a deprecation warning of the Selenium
webdriver and has two new error messages, in total now 3 with number 17) from
above.

    3) Acceptances JavaScript with unsold items should delete an item
        Failure/Error: page.should_not have_text item.description
          expected #has_text?("Item of the list") to return false, got true
        # ./spec/requests/acceptances_edit_spec.rb:202:in `block (4 levels) 
        in <top (required)>'
 
    4) Acceptances index page with active event with no sold items should 
       show acceptance diaglog when scanning label
        Failure/Error: page.current_path.should eq 
        edit_acceptance_path(locale: :en, id: list)
 
          expected: "/en/acceptances/1/edit"
               got: "/en/acceptances"
 
          (compared using ==)
        # ./spec/requests/acceptances_index_spec.rb:114:in `block (4 levels)
        in <top (required)>'
 
    5) Newsletter create by admin user should show errors on unclomplete 
       input
        Failure/Error: page.all('input', visible: true).size.should eq 8
 
          expected: 8
               got: 9
 
          (compared using ==)
        # ./spec/requests/newsletter_pages_spec.rb:46:in `block (4 levels) in
        <top (required)>

    x2) WARN Selenium [DEPRECATION] 
        Selenium::WebDriver::Error::UnhandledError is deprecated. Use 
        Selenium::WebDriver::Error::UnknownError (ensure the driver supports
        W3C WebDriver specification) instead.                                
    x3) WARN Selenium [DEPRECATION] 
        Selenium::WebDriver::Error::ElementNotVisibleError is deprecated. Use
        Selenium::WebDriver::Error::ElementNotInteractableError (ensure the 
        driver supports W3C WebDriver specification) instead. 


### 3) Acceptances JavaScript with unsold items should delete an item
Running the spec individually it passes. Persumably previous tests have
set a condition that interferes with the spec or maybe a timing issue.

### x2)/x3) WARN Selenium [DEPRECATION]
The deprecation warning is probably from the RSpec version. Let's update
RSpec first before we proceede. The upgrade process can be found 
[Rspec upgrade guide](https://relishapp.com/rspec/docs/upgrade)
 
    > gem install transpec

Running transpec will replace all deprecated code from the specs. After that 
update RSpec by adding the new version to the Gemfile

    > gem 'rspec-rails', '~> 3.9'
    > bundle update

Running specs again will reveal that we need a higher capybara version

    > rspec
    RuntimeError:
      You are using capybara 2.1.0 RSpec requires >= 2.2.0.

We update to the newest version of capybara wich is 3.33.0 and add the 
respective directive to the Gemfile

    > gem 'capybara', '~> 3.33'
    > bundle update

We also require 'capybara/rspec' in 'spec/spec\_helper'.

Another run of rspec brings up a load of errors, in total 145, and 1 
deprecation warning. Let's fix them one by one with the help of the [Capybara Readme 3.33.0](https://github.com/teamcapybara/capybara/blob/3.33_stable/README.md#using-capybara-with-rspec).

#### Decprecated 'rspec/autorun'

    Requiring `rspec/autorun` when running RSpec via the `rspec` command is
    deprecated. Called from 
    /home/pierre/.rvm/gems/ruby-2.5.7@rails-4.2.11.3-secondhand-u
    pgrade/gems/activesupport-4.2.11.3/lib/active_support/dependencies.rb:274
    :in `require'.

We remove the directive from 'spec/spec\_helper.rb' and run rspec again to 
see if the deprecation warning is gone. Yep, it's gone.

#### Capybara LoadError of puma server

    Failure/Error: raise LoadError, 'Capybara is unable to load `puma` for 
    its server, please add `puma` to your project or specify a different 
    server via something like `Capybara.server = :webrick`.'

We are using webrick an add to spec/spec\_helper.rb

    Capybara.server = :webrick

Running rspec again we reduced with this small change the from 145 to 27,
that I call progress.

#### WARNING: Using the `raise_error` matcher 

    WARNING: Using the `raise_error` matcher without providing a specific
    error or message risks false positives, since `raise_error` will match
    when Ruby raises a `NoMethodError`, `NameError` or `ArgumentError`,
    potentially allowing the expectation to pass without even executing the
    method you are intending to call. Actual error raised was
    #<ActiveRecord::RecordNotFound: Couldn't find Event with 'id'=32>.
    Instead consider providing a specific error class or message. This
    message can be suppressed by setting:
    `RSpec::Expectations.configuration
                        .on_potential_false_positives = :nothing`.
                 
The result was actually what we are testing for 

    '#<ActiveRecord::RecordNotFound: Couldn't find Event with 'id'=32>'.

Now test explicitly on 'ActiveRecord::RecordNotFound:'.
    expect { Event.find(event.id) }.to raise_error(ActiveRecord::RecordNotFound) { |error| expect(error.data).to eq Couldn't find Event with 'id'=#{event.id} }

------------------old stuff-------------
## Runtime Errors
Runtime errors after upgrading to Rails 4.1.16.

### Asset filtered out and will not be served
The error message in caused by Gritter. First update to the latest version with

    gem "gritter", "1.2.0"

Then run `bundle install`

When starting the server with `rails s` and going to `localhost:3000` following
error is thrown

    Asset filtered out and will not be served: 
    add `Rails.application.config.assets.precompile += 
    %w( glyphicons-halflings.png )` to 
    `config/initializers/assets.rb` and restart your server

After adding the code and restarting the server, `localhost:3000` will show the
next entry we have to add, go on until the application starts without error.

# Stage 3 - Deploying the Beta Application
The next step is to deploy the application to the beta server. We already have 
a running application on the beta, staging and production machine. The initial 
deployment steps are described in 
[deployment](https://github.com/sugaryourcoffee/secondhand/blob/master/doc/deployment.md). 
The steps in this section describe how to update the beta server to 
test our upgraded application. If everything works on the beta server we deploy
to the staging sever and finally to the production server. 

In the following we assume that our development machine is *saltspring* and our
beta server is *uranus*. To upgrade the beta server we have to conduct following
steps:

* ssh to the beta server *uranus*
* install Ruby 2.0.0p648
* create a gemspec rails-4116-secondhand
* install Rails 4.1.16
* adjust the Apache's beta virtual host 
* return to the development machine *saltspring*
* update the beta environment
* deploy the beta application

### Install Ruby 2.0.0 and Rails 4.0.13 on the beta server
First we ssh to the beta server

    saltspring$ ssh uranus

To make sure we have the latest RVM installed we upgrade with

    uranus$ rvm get stable

Now we install and activate Ruby 2.0.0p648

    uranus$ rvm install 2.0.0 && rvm use 2.0.0

Then we create a gemset

    uranus$ rvm gemset create rails-4116-secondhand

and switch to the gemset

    uranus$ rvm ruby-2.0.0-p648@rails-4116-secondhand

Finally we install Rails 4.1.16

    uranus$ gem install rails --version 4.1.16 --no-ri --no-rdoc

### Adjust the virtual host for the beta server
Open up secondhand-beta.conf and change the Ruby version in 
the Apache's secondhand-beta.conf virtual host

    uranus$ vi /etc/apache2/sites-available/secondhand-beta.conf

We change following part

```
<VirtualHost *:8083>
  DocumentRoot /var/www/secondhand-beta/current/public
  Servername beta.secondhand.uranus
  PassengerRuby /home/pierre/.rvm/gems/ruby-2.0.0-p648@rails-4116-secondhand/wrappers/ruby 
  <Directory /var/www/secondhand-beta/public>
    AllowOverride all
    Options -MultiViews
    Require all granted
  </Directory>
  RackEnv beta
</VirtualHost>
```

Now run 

    uranus$ sudo a2ensite secondhand-beta.conf

and reload the configuration and restart Apache 2

    uranus$ service apache2 reload && sudo apachectl restart

### Update the beta environment
Back on the development machine go to `~/Work/Secondhand` and update the beta
environment 

    saltspring$ cd ~/Work/Secondhand
    saltspring$ vi config/environments/beta.rb

and check that following line reads

    config.action_mailer
          .default_url_options = { host: "syc.dyndns.org:8083" }

In `config/deploy.rb` check that `beta` is part of the stages

    set :stages, %w(production staging beta backup) 

In `config/deploy/beta.rb` check the `domain`, `application`, `rvm_ruby_string`
and the `rails_env` and also change `git_application` to `upgrade-to-rails-4.1`.

    set :domain, 'beta.secondhand.uranus'
    set :git_application, 'secondhand'
    set :application, 'secondhand-beta'
    set :repository,  "git@github.com:#{git_user}/#{git_application}.git"
    set :rvm_ruby_string, '2.0.0-p648@rails-4116-secondhand'
    set :rails_env, :beta

    set :branch, fetch(:branch, "master")

Check that there is a beta group in database.yml. The database is the same as 
with the staging version as they live on the same machine.

    beta:
      adapter: mysql2
      encoding: utf8
      reconnect: false
      database: secondhand_staging
      pool: 5
      timeout: 5000
      username: user
      password: password
      host: localhost

check that we have the hostname in `/etc/hosts`

      192.168.178.66 secondhand.uranus beta.secondhand.uranus

### Deploy to the beta server
We deploy our branch `upgrade-to-rails-4.1` with following command

    saltspring$ cap -S branch=upgrade-to-rails-4.1 beta deploy

If we would ommit the branch directive we would deploy the master branch.

Check up your application at [secondhand:8083](http://syc.dyndns.org:8083).

## Deploying to the staging server
The staging server is on the same server as the beta server. Therefore we don't 
need to update Ruby and Rails and can concentrate on the configuration. We need 
to do the configuration on the server and on the development machine.

On the server we have to configure the Ruby version in 

* `/etc/apache2/sites-available/secondhand.conf`

On the development machine we have to configure

* `config/deploy/staging.rb`

### Server configuration
We have to process changes in `/etc/apache2/sites-available/secondhand.conf` as
shown below.

replace

    <VirtualHost *:8082>
      DocumentRoot /var/www/secondhand/current/public
      ServerName secondhand.uranus
      PassengerRuby /home/pierre/.rvm/gems/ruby-2.0.0-p643@rails4013/\
      wrappers/ruby
      <Directory /var/www/secondhand/public>
        AllowOverride all
        Options -MultiViews
        Require all granted
      </Directory>
      RackEnv staging
    </VirtualHost>

with

    <VirtualHost *:8082>
      DocumentRoot /var/www/secondhand/current/public
      ServerName secondhand.uranus
      PassengerRuby /home/pierre/.rvm/gems/\
      ruby-2.0.0-p648@rails-4116-secondhand/wrappers/ruby
      <Directory /var/www/secondhand/public>
        AllowOverride all
        Options -MultiViews
        Require all granted
      </Directory>
      RackEnv staging
    </VirtualHost>

## Development machine configuration
We have to process changes in `config/deploy/staging.rb` as shown below.

replace

    set :rvm_ruby_string, '1.9.3' 
    set :branch, 'master'
    
with

    set :rvm_ruby_string, '2.0.0-p648@rails-4116-secondhand'
    set :branch, fetch(:branch, "master")

The `fetch(:branch, "master")` command allows to provide a different deployment
branch while invoking the `cap` command as shown in the Deployment section.

### Deployment
Now it is save to deploy your application with

    $ cap -S branch=upgrade-to-rails-4.1 staging deploy

And then run the database migrations

    $ cap -S branch=upgrade-to-rails-4.1 staging deploy:migrations

Go to [http://syc.dyndns.org:8082](http://syc.dyndns.org:8082) to check up your newly deployed application.

## Deploying to the production server
At the production server we have slightly different situation as on the staging
server. We need to first install new Ruby and Rails versions. The list shows 
the steps we have to take

* Install Ruby 2.0.0-p648
* Install Rails 4.1.16
* Set up Apache 2 to point to the new Ruby and Rails version
* Adjust `config/deploy/production.rb`
* Deploy the application
* Migrate the database

### Install Ruby 2.0.0 and Rails 4.1.16 on the production server
First we ssh to the production server

    saltspring$ ssh secondhand@mercury

Before installation we check whether we have the latest RVM installed. If not
it would potentially not find the latest Ruby version. To upgrade to the latest
RVM version do

    mercury$ rvm get head

If you get an error about the key just follow the instructions RVM gives you.

After having installed the newest RVM version we proceed with installing and 
activating Ruby 2.0.0

    mercury$ rvm install 2.0.0 && rvm use 2.0.0

Then we create a gemset

    mercury$ rvm gemset create rails-4116-secondhand

and switch to the gemset

    mercury$ rvm ruby-2.0.0-p648@rails-4116-secondhand

Finally we install Rails 4.1.16

    mercury$ gem install rails --version 4.1.16 --no-ri --no-rdoc

### Setup Apache 2
Change the default Ruby in `/etc/apache2/apache2.conf` from

    <IfModule mod_passenger.c>
      PassengerRoot /home/secondhand/.rvm/gems/ruby-1.9.3-p448@rails3211/gems/passenger-5.0.8
      PassengerDefaultRuby /home/secondhand/.rvm/wrappers/ruby-2.0.0@rails3211/ruby
    </IfModule>

so it looks like the following

    <IfModule mod_passenger.c>
      PassengerRoot /home/secondhand/.rvm/gems/ruby-1.9.3-p448@rails3211/gems/passenger-5.0.8
      PassengerDefaultRuby /home/secondhand/.rvm/gems/ruby-2.0.0-p648@rails-4116-secondhand/wrappers/ruby
    </IfModule>

As we have only one application running we don't need to change 
`/etc/apache2/sites-available/secondhand.conf`.

In order to make the changes take effect we have to restart Apache 2 with

    mercury$ sudo apachectl restart

### Adjust `config/deploy/production.rb`
We have to process changes in `config/deploy/production.rb` as shown below.

replace the value of the `rvm_ruby_string`

    set :rvm_ruby_string, '2.0.0@rails4013' 
    
with the new gemset

    set :rvm_ruby_string, '2.0.0-p648@@rails-4116-secondhand'

For testing the deployment we will first deploy the branch 
`upgrade-to-rails-4.1`. If it works we will merge the branch to the master
branch and do the final deployment. In order to provide a specific branch we
change in `config/deploy/production.rb`

    set :branch, 'master'

to

    set :branch, fetch(:branch, 'master')

### Test Deployment
To test the deployment we issue

    $ cap -S branch=upgrade-to-rails-4.1 production deploy
    
If this works we merge the `upgrade-to-rails-4.1` branch to the `master` branch

### Merge upgrade-to-rails-4.1 to master
We checkout the master branch

    $ git checkout master

and merge the upgrade-to-rails-4.1 branch to the master branch

    $ git merge upgrade-to-rails-4.1

### Deploy
Now it is save to deploy your application with

    $ cap production deploy

And then run the database migrations

    $ cap production deploy:migrations

Go to [http://syc.dyndns.org:8080](http://syc.dyndns.org:8080) to check up your newly deployed application.

### Tag the version
The final step is to tag our version. We do tag this version as a new major 
version `3.0.0`.

    $ git checkout -b v3.0.0-stable
    $ git push --set-upstream origin v3.0.0
    $ git tag -a v3.0.0 -m "Secondhand V3.0.0 - Release 2018-04-01"
    $ git push --tags

## Upgrade the Backup Server
The final step is to upgrade the back server. We process the same steps as with
the production server.

* Install Ruby 2.0.0-p648
* Install Rails 4.1.16
* Set up Apache 2 to point to the new Ruby and Rails version
* Adjust `config/deploy/backup.rb`
* Deploy the application

### Install Ruby 2.0.0 and Rails 4.1.16 on the backup server
First we ssh to the backup server

    saltspring$ ssh jupiter

We first update the RVM version

    mercury$ rvm get head

If you get an error about the key just follow the instructions RVM gives you.

After having installed the newest RVM version we proceed with installing and 
activating Ruby 2.0.0

    mercury$ rvm install 2.0.0 && rvm use 2.0.0

Then we create a gemset

    mercury$ rvm gemset create rails-4116-secondhand

and switch to the gemset

    mercury$ rvm ruby-2.0.0-p648@rails-4116-secondhand

Finally we install Rails 4.1.16

    mercury$ gem install rails --version 4.1.16 --no-ri --no-rdoc

### Setup Apache 2
Change the default Ruby in `/etc/apache2/conf-available/passenger.conf` from

    <IfModule mod_passenger.c>
      PassengerRoot /home/pierre/.rvm/gems/ruby-2.0.0-p648@rails4013/gems/passenger-5.0.30
      PassengerDefaultRuby /home/pierre/.rvm/gems/ruby-2.0.0-p648@rails4013/wrappers/ruby
    </IfModule>

so it looks like the following

    <IfModule mod_passenger.c>
      PassengerRoot /home/pierre/.rvm/gems/ruby-2.0.0-p648@rails4013/gems/passenger-5.0.30
      PassengerDefaultRuby /home/pierre/.rvm/gems/ruby-2.0.0-p648@rails-4116-secondhand/wrappers/ruby
    </IfModule>

In order to make the changes take effect we have to restart Apache 2 with

    jupiter$ sudo apachectl restart

### Adjust `config/deploy/backup.rb`
We have to process changes in `config/deploy/backup.rb` as shown below.

replace the value of the `rvm_ruby_string`

    set :rvm_ruby_string, '2.0.0@rails4013' 
    
with the new gemset

    set :rvm_ruby_string, '2.0.0-p648@@rails-4116-secondhand'

### Deploy
Now it is save to deploy your application with

    $ cap backup deploy

Details about backing up the database can be found in [Fail over MySQL and Rails](Fail over MySQL and Rails)  
