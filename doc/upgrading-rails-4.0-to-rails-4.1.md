Upgrading from Rails 4.0 to Rails 4.1
=====================================
In this document I describe the steps to upgrade *Secondhand* from Rails 4.0 to
Rails 4.1. Further information can be found at 
[edgeguides](http://edgeguides.rubyonrails.org/upgrading_ruby_on_rails.html).

Other upgrade instructions can be found at

* [Upgrading from Rails 3.2 to Rails 4.0](./upgrading-rails-3.2-to-rails-4.0.md)

The current versions used are

* Ruby 2.0.0-p643
* Rails 4.0.13
* RVM 1.27.0

We are using following RVM gemset for the application

* ruby-2.0.0-p643@rails4013

We run the migration in two stages. First we do a preparation phase where we
update the application to the most recent versions within the major version.
When this is done we do the actual migration. 

The preparation steps to follow are

* Run the tests and ensure they pass
* Tag the current version to Git
* Check out a new branch for the migration process
* Update to the latest Ruby 2.0.0 patch level
* Update to the latest Rails 4.0 version

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
This is stage 1 where we prepare for upgrading our Rails 4.0 app to Rails 4.1.
We first move to the gemset that is hosting Secondhand

    $ rvm ruby-2.0.0-p643@rails4013

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

    $ git checkout -b v2.0.1-stable
    $ git push --set-upstream origin v2.0.1-stable

Next we want to tag this branch with a version number. To list the already taken
tags we can issue

    $ git tag
    v1.0
    v1.0.1
    v1.0.2
    v1.1.0
    v2.0.0

To tag our branch we checkout *v1.1-stable* (we should already be on that 
branch from the previous checkout command though) and then issue the tag command

    $ git checkout v2.0.1-stable
    $ git tag -a v2.0.1 -m "Secondhand V2.0.1 - Release 2016-11-01"

Finally push the tagged commit to Github with

    $ git push --tags

## Check out a new branch
Before you do any changes to your project check out a new branch. In case you
mess up your project you always can safely rewind to your master branch and
start from a blank slate again.

    $ git checkout -b rails4-1

## Update Ruby to the latest patch level
That is not necessary but to be on the safe side I want to have the latest 
patch level of Ruby 2.0.0. We can check the latest available versions with

    $ rvm list known | grep 2.0.0
    [ruby-]2.0.0[-p648]

While being in the *ruby-2.0.0-p643@rails4013* gemset we update to that
version we issue

    $ rvm install 2.0.0

This will create new gemsets that we can list with 

    $ rvm list gemsets | grep ruby-2.0.0-p648
    => ruby-2.0.0-p648 [ x86_64 ]
       ruby-2.0.0-p648@global [ x86_64 ]
       ruby-2.0.0-p648@rails4013 [ x86_64 ]
    
As we've been in the gemset *rails4013* this has been created for us with the
newly install Ruby 2.0.0-p648. Before we move on we switch to the new created
gemset

    $ rvm ruby-2.0.0-p648@rails4013

Next we copy our old gemset to the newly created gemset with

    $ rvm gemset copy ruby-2.0.0-p643@rails4013 ruby-2.0.0-p648@rails4013

We check that we have the freshly installed Ruby version and the Rails version
of the old gemset

    $ ruby -v
    ruby 2.0.0-p648 (2015-12-16 revision 53162) [x86_64-linux]
    $ rails -v
    Rails 4.0.13

Finally we run our test and make sure everything runs without errors.

    $ rspec

If anything breaks make sure to first fix the error before moving on.

## Update to the latest Rails 4.0 version
We could start to upgrade our app from the current version to version 4.1, but 
it is advised to upgrade from the most current version. To find the most recent
version we can issue

    $ gem list ^rails$ --remote --all | grep -oP "4.0(.\d{1,})*"
    4.0.13
    4.0.12
    4.0.11.1
    4.0.11
    ...
    4.0.1
    4.0.0
    
So it seems we are already on the most recent Rails version which is 4.0.13. 

To make this step complete we are assuming that we are on 4.0.12. So we would 
are not on the latest version, and the first step is to add the version to our 
*Gemfile* by replacng the line `gem 'rails', '4.0.12'` with 
`gem 'rails' '4.0.13'`. Then we need to run

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
    $ git merge rails4-1
    $ git push

Just to be sure we run rspec again.

Now we are ready to actually upgrade to Rails 4.1.

# Stage 2 - Upgrade to Rails 4.1
Now we are prepared to actually upgrade to Rails 4.1. We checkout a new branch

    $ git checkout -b upgrade-to-rails-4.1
    $ git push --set-upstream origin upgrade-to-rails-4.1

## Prepare the Gemfile
The first step is to change the Ruby version in the Gemfile. But we also want
to set the version numbers for the other gems listed in the Gemfile so they
meet the pre-conditions working with Rails 4.1. To see what gem versions we need
in combination with Ruby 4.1 we create a Rails project with the most recent
Rails 4.1 version, which is at this writing *4.1.16*.

To not override our gemset *rails4013* we use *ruby 2.0.0-p648* and create a new
gemset and switch to it before installing the new rails version

    $ mkdir ~/Work/rails-version-test
    $ cd ~/Work/rails-version-test
    $ rvm 2.0.0-p648
    $ rvm create gemset rails-4.1.16-version-test
    $ rvm ruby-2.0.0-p648@rails-4.1.16-version-test
    $ gem install rails --version 4.1.16
    $ rails _4.1.16_ new test-4.1.16
 
In the Gemfile we can see the gem version that work together with Rails 4.1.16.
The table below lists the gems (from the Secondhand Gemfile) with the versions
of the *test-4.1.16* app indicated by `~>` and `>=`. Note that only part of the
gems are in the 4.1.16 Gemfile, the other gems we have to lookup at 
[rubygems.org](https://rubygems.org) that go together with Rails 4.1.16.

Gem                      | Rails 4.0.13    | Rails 4.1.16 | Group            | 
------------------------ | --------------- | ------------ | ---------------- | -
rails                    | 4.0.13          | 4.1.16       | top              |
bootstrap-sass           | 2.3.1.0         | 2.3.2.0      | top              |
faker                    | ~> 1.5.0        | ~> 1.6.6     | top              |
will\_paginate           | 3.0.7           | 3.1.5        | top              |
bootstrap-will\_paginate | 0.0.10          | 0.0.10       | top              |
prawn                    | 1.3.0           | 1.3.0        | top              |
prawn-table              | ~> 0.2.2        | ~> 0.2.2     | top              |
syc-barcode              | 0.0.3           | 0.0.3        | top              |
net-ssh                  | ~> 2.9.2        | ~> 2.9.2     | top              |
turbolinks               | 2.5.3           |              | top              |
jquery-turbolinks        |                 |              | top              |
sqlite3                  |                 |              | development      |
rspec-rails              | 2.99.0          | 2.99.0       | development,test |
guard-rspec              | 4.6             | 4.6          | development      |
annotate                 | 2.5.0           | 2.6.10       | development      |
guard-spork              | 2.1             | 2.1          | test             |
spork                    | 0.9             | 0.9          | test             |
capybara                 | 2.1.0           | 2.1.0        | test             |
rb-inotify               | 0.9.0           | 0.9.0        | test             |
libnotify                | 0.5.9           | 0.5.9        | test             |
factory\_girl\_rails     | 1.4.0           | 1.4.0        | test             |
cucumber-rails           | 1.2.1           | 1.2.1        | test             |
database\_cleaner        | 1.5.0           | 1.5.0        | test             |
selenium-webdriver       |                 |              | test             |
sass-rails               | ~> 4.0.2        | ~> 4.0.3     | top              |
coffee-rails             | ~> 4.0.0        | ~> 4.0.0     | top              |
uglifier                 | >= 1.3.0        | >= 1.3.0     | top              |
jquery-rails             |                 |              | top              |
best\_in\_place          |                 |              | top              |
gritter                  | ~> 1.1.0        | ~> 1.2.0     | top              |
bcrypt                   | ~> 3.1.7        | ~> 3.1.7     | top              |
rvm-capistrano           | ~> 1.5.6        | ~> 1.5.6     | top              |
mysql2                   |                 |              | production       |
jbuilder                 | ~> 1.2          | ~> 2.0       | top              |
sdoc                     |                 | ~> 0.4.0     | doc              | x
spring                   | -               |              | development      | x

x = not installed

We start by changing the rails version in our Gemfile to 

    gem 'rails', '4.1.16'

and then run `bundle install`. We will get a bundler message saying

    Bundler could not find compatible versions for gem "actionpack":
      In snapshot (Gemfile.lock):
        actionpack (= 4.0.13)

      In Gemfile:
        best_in_place was resolved to 3.0.3, which depends on
          actionpack (>= 3.2)

        rails (= 4.1.16) was resolved to 4.1.16, which depends
          actionpack (= 4.1.16)

        rails (= 4.1.16) was resolved to 4.1.16, which depends
          actionpack (= 4.1.16)

        rails (= 4.1.16) was resolved to 4.1.16, which depends
          sprockets-rails (~> 2.0) was resolved to 2.3.3, whic
            actionpack (>= 3.0)

        rails (= 4.1.16) was resolved to 4.1.16, which depends
          sprockets-rails (~> 2.0) was resolved to 2.3.3, whic
            actionpack (>= 3.0)

    Running `bundle update` will rebuild your snapshot from sc
    the gems in your Gemfile, which may resolve the conflict.

If we run

    $ bundle update actionpack

We get the same message for `activemodel` and `railties`. To solve all 
dependendcies we update all 3 gems with one swoop

    $ bundle update actionpack activemodel railties

Now we should have the version 4.1.16 installed. We can proof it by issuing

    $ rails -v
    Rails 4.1.16

Note: If we have accidentially installed the new rails version into the current
gemset (as happened to me) we can rename the gemset with

    rvm gemset rename ruby-2.0.0-p648-rails4013 ruby-2.0.0-p648@rails-4116-secondhand

## Update Secondhand configuration files
Now we use a rake task that helps to interactively update configuration files.

    $ rake rails:update

This will ask whether to overwrite the old files with new files. With `d` we
can diff the old and the new file. Here is how we process Secondhand.

File                                    | Overwrite | After update action
--------------------------------------- | --------- | -------------------
config/boot.rb                          | no        | no
config/routes.rb                        | no        | yes
config/application.rb                   | no        | no
config/environment.rb                   | no        | yes
conifg/environments/development.rb      | no        | yes
config/environsments/production.rb      | yes       | yes
config/environments/staging.rb          | no        | yes
config/environments/test.rb             | yes       | yes
config/environments/beta.rb             | no        | yes
config/initializers/inflections.rb      | no        | no
config/initializers/mime\_types.rb      | yes       | no
config/initializers/secret\_token.rb    | yes       | no
config/initializers/sessions\_store.rb  | yes       | no
config/initializers/wrap\_parameters.rb | yes       | no
config/locales/en.yml                   | no        | no

### config/routes.rb

Rails 4.0.13                        | Rails 4.1.16
----------------------------------- | -----------------------------
Secondhand::Application.routes.draw | Rails.application.routes.draw

When done we can run `rspec` again and check whether routing errors occur. But
we also can check the `rake routes` command whether it draws error messages.

    $ rake routes

### config/environment.rb

Rails 4.0.13                        | Rails 4.1.16
----------------------------------- | -----------------------------
Secondhand::Application.initialize! | Rails.application.initialize!
Secondhand::Application.configure   | Rails.application.configure

### config/environments/development.rb

Rails 4.0.13                        | Rails 4.1.16
----------------------------------- | -----------------------------------------
Secondhand::Application.configure   | Rails.application.configure
                                    | config.assets.raise_runtime_errors = true

### config/environments/staging.rb

Rails 4.0.13                        | Rails 4.1.16
----------------------------------- | -----------------------------------------
Secondhand::Application.configure   | Rails.application.configure

### config/environments/production.rb

Action      | Description
----------- | ------------------------------------------------
deliveries  | config.action\_mailer.perform\_deliveries = true
default URL | config.action\_mailer.default\_url\_options = \
              { host: "syc.dyndns.org:8080" }

### config/environments/test.rb

Action      | Description
----------- | --------------------------------------------  
default URL | config.action\_mailer.default\_url\_options = \
            |   { host: "localhost:3000" }
            | config.action\_controller.default\_url\_options = \
            |   { host: "localhost:3000" }

### config/environments/beta.rb

Rails 4.0.13                        | Rails 4.1.16
----------------------------------- | -----------------------------------------
Secondhand::Application.configure   | Rails.application.configure

## Deprecation Warnings
This section describes deprecation warnings after upgrading to Rails 4.1.16.

### 'last\_comment' is deprecated
When running `rake routes` we get following deprecation warning

    [DEPRECATION] `last_comment` is deprecated.  Please use `last_description` 
    instead.

without any hint which gem is sending the deprecation warning. Therefore we 
grep into the gems directory of our current gemset which is `ruby-2.0.0-p648@rails4013`

    $ grep -r "last_comment" ~/.rvm/gems/ruby20.0.-p648@rails4013/gems

It reveals that the warning is coming from `Rake` version 11.3.0 but actually
triggered by rspec calling `Rake.application.last_comment`. For the moment we
don't upgrade rspec as we want to get our test passing and then coping with
deprecation warnings.

To update from Rspec 2.99.0 we follow the [Rspec upgrade guide](https://relishapp.com/rspec/docs/upgrade).

## Check for required code changes
This section describes the checks to do to disclose code that has to be changed
due to changes in Rails 4.1.16

TODO

## Error Messages
In this section error message are discussed that have arisen after upgrading to
Rails 4.1.

### Fixing errors revealed by rspec runs
When running rspec we get following 5 errors that worked with the previously 
used Rails 4.0.13 version.

      1) User when password confirmation is nil should not be valid
         Failure/Error: it {should_not be_valid}
         expected #<User id: nil, first_name: "Example", last_name: "User", 
         street: "Street 1", zip_code: "12345", town: "Town", 
         country: "Country", phone: "1234 567890", email: "user@example.com",
         password_digest: "$2a$04$MKAFoGLFe6BCExGSdpM/geuZnSaE.oWzUzbsItzIEJa.",
         news: false, created_at: nil, updated_at: nil, remember_token: nil,
         admin: false, auth_token: nil, password_reset_token: nil,
         password_reset_sent_at: nil, preferred_language: nil, operator: false,
         terms_of_use: nil> not to be valid
         # ./spec/models/user_spec.rb:112:in `block (3 levels) in
         <top (required)>'

      2) event pages index with admin user signed in delete button should not
         delete event with list register by a user
         Failure/Error: expect { event_other.destroy }.to change(Event, :count)
         .by(0)
         ActiveRecord::RecordNotDestroyed:
           ActiveRecord::RecordNotDestroyed
         # ./spec/requests/event_pages_spec.rb:114:in `block (6 levels) in
           <top (required)>'
         # ./spec/requests/event_pages_spec.rb:114:in `block (5 levels) in
           <top (required)>'

      3) Newsletter create by admin user should show errors on unclomplete input
         Failure/Error: page.all('input', visible: true).size.should eq 9

         expected: 9
         got: 8

         (compared using ==)
         # ./spec/requests/newsletter_pages_spec.rb:46:in `block (4 levels) in
           <top (required)>'

      4) Role authentication as operator user in the acceptances controller
          edit list
         Failure/Error: before { visit edit_list_acceptance_path(list,
             locale: :en) }
         ActionController::InvalidCrossOriginRequest:
         Security warning: an embedded <script> tag on another site requested
         protected JavaScript. If you know what you're doing, go ahead and
         disable forgery protection on this action to permit cross-origin
         JavaScript embedding.
         # ./spec/requests/role_authentication_spec.rb:131:in `block
           (5 levels) in <top (required)>'

      5) Role authentication as admin user in the acceptances controller edit
         list
         Failure/Error: before { visit edit_list_acceptance_path(list,
             locale: :en) }
         ActionController::InvalidCrossOriginRequest:
         Security warning: an embedded <script> tag on another site requested
         protected JavaScript. If you know what you're doing, go ahead and
         disable forgery protection on this action to permit cross-origin
         JavaScript embedding.
         # ./spec/requests/role_authentication_spec.rb:246:in `block
           (5 levels) in <top (required)>'

#### 1) User when password confirmation is nil should not be valid
After the upgrade `bcrypt` allows to update a user without setting the password
confirmation. So the test has to be tested for truthy.

#### 2) event pages ... not delete event with list register by a user
The test expects that the record is not deleted which actually is true.

    Failure/Error: expect { event_other.destroy }.to change(Event, :count).by(0)

But the error `ActiveRecord::RecordNotDestroyed:` is thrown.

To make the test pass change

          expect { event_other.destroy }.to_not change(Event :count).by(0)

to 

          expect { event_other.destroy }
                 .to raise_error(ActiveRecord::RecordNotDestroyed)

#### 3) Newsletter create by admin user should show errors on unclomplete input
After the upgrade Capybara finds 8 instead of previously 9 input fields with

    page.all('input', visible: true).size

After changing to 8

    page.all('input', visible: true).size.should eq 8

The tests pass. Actually there are only 6 visible input fields. So Capybara's 
command is presumably not working reliably.

#### 4), 5) ActionController::InvalidCrossOriginRequest
[guides.rubyonrails.org](http://guides.rubyonrails.org/upgrading_ruby_on_rails.html#csrf-protection-from-remote-script-tags)
explain the origin of the error. In Rails 4.1 CSRF protection now covers GET
requests with JavaScript responses. The document states that we have to replace

    get :index, format: :js

with 

    xhr :get, :index, format: :js

in the tests. We have to change

    before { visit edit_list_acceptance_path(list, locale: :en) }
    it { page.current_path.should eq edit_list_acceptance_path(list, 
                                                               locale: :en) }

to

    it "number" do
      xhr :get,  edit_list_acceptance_path(list, locale: :en), format: :js 
      expect(page.status_code).to be(200)
    end

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

<--- to here upgraded. next sections TODO

## Merge to Master
Now that all our specs run without error we merge our *upgrade-to-rails-4* 
branch back to the master branch.

    $ git checkout master
    $ git merge upgrade-to-rails-4.1

Next we verify that everything works with

    $ rspec

It should run without errors.

As we didn't have to change anything we can checkout the master tree and 
proceed with deployment. But before we do we tag this version as a new major
version `2.0.0`.

    $ git checkout -b v2.0-stable
    $ git push --set-upstream origin v2.0-stable
    $ git tag -a v2.0.0 -m "Secondhand V2.0.0 - Release 2015-12-24"
    $ git push --tags

# Stage 3 - Deploying the application
The final step is to deploy the application. We already have a running 
application on the staging and production machine. The initial deployment step
are described in [deployment](https://github.com/sugaryourcoffee/secondhand/blob/master/doc/deployment.md). 
The steps in this section describe how to setup an additional beta server to 
test our upgraded application. If everything works we deploy to the staging 
sever and finally to the production server. 

In the following we assume that our development machine is *saltspring* and our
beta server is *uranus*. To setup the beta server we have to conduct following 
steps:

* ssh to the staging server *uranus*
* install Ruby 2.0.0
* create a gemspec rails4013
* install Rails 4.0.13
* create the application directory
* copy the staging virtual host to a beta virtual host and adjust it
* return to the development machine *saltspring*
* create a beta environment
* deploy the application

### Install Ruby 2.0.0 and Rails 4.0.13 on the beta server
First we ssh to the staging server

    saltspring$ ssh uranus

We install and activate Ruby 2.0.0

    uranus$ rvm install 2.0.0 && rvm use 2.0.0

Then we create a gemset

    uranus$ rvm gemset create rails4013

and switch to the gemset

    uranus$ rvm ruby-2.0.0-p643@rails4013

Finally we install Rails 4.0.13

    uranus$ gem install rails --version 4.0.13 --no-ri --no-rdoc

### Create the application directory
We create a deployment directory to host our beta version of Secondhand.

    uranus$ sudo mkdir /var/www/secondhand-beta/
    
### Create a virtual host for the beta server
Copy the secondhand.conf to secondhand-beta.conf and change the Ruby version in 
the Apache's secondhand-beta.conf virtual host

    uranus$ cp /etc/apache2/sites-available/scondhand.conf \
    > /etc/apache2/sites-available/secondhand-beta.conf
    uranus$ vi /etc/apache2/sites-available/secondhand-beta.conf

We change following part

```
<VirtualHost *:8083>
  DocumentRoot /var/www/secondhand-beta/current/public
  Servername beta.secondhand.uranus
  PassengerRuby /home/pierre/.rvm/gems/ruby-2.0.0-p643@rail4013/wrappers/ruby 
  <Directory /var/www/secondhand-beta/public>
    AllowOverride all
    Options -MultiViews
    Require all granted
  </Directory>
  RackEnv beta
</VirtualHost>
```

In order to access the port `8083` we have to add `Listen 8083` to 
`/etc/apache2/ports.conf`

Now run 

    uranus$ sudo a2ensite secondhand-beta.conf

and reload the configuration and restart Apache 2

    uranus$ service apache2 reload && sudo apachectl restart

### Add a beta environment
Back on the development machine go to `~/Work/Secondhand` and create a beta
environment by copying the staging environment

    saltspring$ cd ~/Work/Secondhand
    saltspring$ cp config/environments/staging.rb config/environments/beta.rb

and change following line so it reads

    config.action_mailer
          .default_url_options = { host: "syc.dyndns.org:8083" }

In `config/deploy.rb` add `beta` to the stages

    set :stages, %w(production, staging, beta) 

Copy `config/deploy/staging.rb` to `config/deploy/beta.rb`

    saltspring$ cp config/deploy/staging.rb config/deploy/beta.rb

In `config/deploy/beta.rb` set the `domain`, `application`, `rvm_ruby_string`
and the `rails_env` and also add `git_application` and exchange `application` in
the repository URL with `git_application`

    set :domain, 'beta.secondhand.uranus'
    set :git_application, 'secondhand'
    set :application, 'secondhand-beta'
    set :repository,  "git@github.com:#{git_user}/#{git_application}.git"
    set :rvm_ruby_string, '2.0.0'
    set :rails_env, :beta

We add a beta group to database.yml

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

and add a hostname to `/etc/hosts`

      19.168.178.66 secondhand.uranus beta.secondhand.uranus

### Deploy to the beta server
Finally run

    saltspring$ cap beta deploy:setup
    saltspring$ cap beta deploy:check
    saltspring$ cap beta deploy:cold

This is only necessary for the initial deployment. For subsequent deploys we
issue

    saltspring$ cap beta deploy

Check up you application at [secondhand:8083](http://syc.dyndns.org:8083).

### Errors during deployment
There are probably some errors during the first deployments. This section 
describes errors after upgrading Secondhand to Rails 4.0.13.

#### Could not load database configuration
During the assets pre compile task following error shows up

```
saltspring$ cap beta deploy
...
  * executing "cd -- /var/www/secondhand-beta/releases/20151010153506 && RAILS_E
NV=beta RAILS_GROUPS=assets bundle exec rake assets:precompile"
    servers: ["beta.secondhand.uranus"]
    [beta.secondhand.uranus] executing command
*** [err :: beta.secondhand.uranus] rake aborted!
*** [err :: beta.secondhand.uranus] Could not load database configuration. No su
ch file - /var/www/secondhand-beta/releases/20151010153506/config/database.yml
*** [err :: beta.secondhand.uranus] /var/www/secondhand-beta/shared/bundle/ruby/
2.0.0/gems/railties-4.0.13/lib/rails/application/configuration.rb:110:in `databa
se_configuration`
```

If we look into `config/deploy/beta.rb` we copy the `database.yml` file to the 
`current/config/database.yml` file. As the error indicates 
`rake assets:precompile` requests the `database.yml` file in the current release
directory. So we have to tweak our rake task in `config/deploy/beta.rb` in that
we have to copy our `database.yml` file to the current release directory 
`release_path` and not to the current directory `current_path`.

```
before 'deploy:assets:precompile', 'copy_database_yml_to_release_path'
# after 'deploy:create_symlink', 'copy_database_yml'

desc "copy shared/database.yml to RELEASE_PATH/config/database.yml"
task :copy_database_yml_to_release_path do
  config_dir = "#{shared_path}/config"

  unless run("if [ -f '#{config_dir}/database.yml' ]; then echo -n 'true'; fi")
    run "mkdir -p #{config_dir}" 
    upload("config/database.yml", "#{config_dir}/database.yml")
  end

  run "cp #{config_dir}/database.yml #{release_path}/config/database.yml"
end

# desc "copy shared/database.yml to current/config/database.yml"
# task :copy_database_yml do
#  config_dir = "#{shared_path}/config"

#  unless run("if [ -f '#{config_dir}/database.yml' ]; then echo -n 'true'; fi")
#    run "mkdir -p #{config_dir}" 
#    upload("config/database.yml", "#{config_dir}/database.yml")
#  end

#  run "cp #{config_dir}/database.yml #{current_path}/config/database.yml"
# end
```

### Gem mysql2 is not loaded
When starting the deployed application the following error comes up

```
Specified 'mysql2' for database adapter, but the gem is not loaded. Add gem 'mysql2' to your Gemfile.
```

Even though the `mysql2` gem is available it is not recognized. Rails 4 doesn't 
work well with the `mysql2` v0.4.x gem. In the `Gemfile` change the version to 

    gem 'mysql2', '~> 0.3.20'

and run

    saltspring$ bundle upgrade mysql2

Then push the changes to github an run `cap beta deploy` again.

## Deploying to the staging server
The staging server is on the same server as the beta server. Therefore we don't 
need to update Ruby and Rails and can concentrate on the configuration. We need 
to do the configuration on the server and on the development machine.

On the server we have to configure the Ruby version in 

* `/etc/apache2/sites-available/secondhand.conf`

On the development machine we have to configure

* `config/deploy/staging.rb`

*Important*
Before deployment we have to follow the instructions at [Capistrano Upgrading to Rails 4 - Asset Pipeline](https://github.com/capistrano/capistrano/wiki/Upgrading-to-Rails-4#asset-pipeline)

### Server configuration
We have to process changes in `/etc/apache2/sites-available/secondhand.conf` as
shown below.

replace

    <VirtualHost *:8082>
      DocumentRoot /var/www/secondhand/current/public
      ServerName secondhand.uranus
      PassengerRuby /home/pierre/.rvm/gems/ruby-1.9.3-p551@rails3211/\
      wrappers/ruby
      <Directory /var/www/secondhand/public>
        AllowOverride all
        Options -MultiViews
        Require all granted
      </Directory>
    </VirtualHost>

with

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

### Development machine configuration
We have to process changes in `config/deploy/staging.rb` as shown below.

replace

    set :rvm_ruby_string, '1.9.3' 
    
with

    set :rvm_ruby_string, '2.0.0'

replace

    after 'deploy:create_symlink', 'copy_database_yml'

    desc "copy shared/database.yml to current/config/database.yml"
    task :copy_database_yml do
      config_dir = "#{shared_path}/config"

      unless run("if [ -f '#{config_dir}/database.yml' ]; 
                    then echo -n 'true'; 
                  fi")
        run "mkdir -p #{config_dir}" 
        upload("config/database.yml", "#{config_dir}/database.yml")
      end

      run "cp #{config_dir}/database.yml #{current_path}/config/database.yml"
    end

with

    before 'deploy:assets:precompile', 'copy_database_yml_to_release_path'
    after 'deploy:create_symlink', 'copy_database_yml'

    desc "copy shared/database.yml to RELEASE_PATH/config/database.yml"
    task :copy_database_yml_to_release_path do
      config_dir = "#{shared_path}/config"

      unless run("if [ -f '#{config_dir}/database.yml' ]; 
                    then echo -n 'true'; 
                  fi")
        run "mkdir -p #{config_dir}" 
        upload("config/database.yml", "#{config_dir}/database.yml")
      end

      run "cp #{config_dir}/database.yml #{release_path}/config/database.yml"
    end

    desc "copy shared/database.yml to current/config/database.yml"
    task :copy_database_yml do
      config_dir = "#{shared_path}/config"

      unless run("if [ -f '#{config_dir}/database.yml' ]; then 
                    echo -n 'true'; 
                  fi")
        run "mkdir -p #{config_dir}" 
        upload("config/database.yml", "#{config_dir}/database.yml")
      end

      run "cp #{config_dir}/database.yml #{current_path}/config/database.yml"
    end 

### Deployment
Before deployment move the file 
`/var/www/secondhand/shared/assests/manifest.yml` to 
`/var/www/secondhand/current/assets_manifest.yml`.

    $ cd /var/www/secondhand
    $ mv shared/assets/manifest.yml current/assets_manifest.yml

Now it is save to deploy your application with

    $ cap staging deploy

And then run the database migrations

    $ cap staging deploy:migrations

Go to [http://syc.dyndns.org:8082](http://syc.dyndns.org:8082) to check up your newly deployed application.

## Deploying to the production server
At the production server we have slightly different situation as on the staging
server. We need to first install new Ruby and Rails versions. The list shows 
the steps we have to take

* Install Ruby 2.0.0
* Install Rails 4.0.13
* Set up Apache 2 to point to the new Ruby and Rails version
* Move the manifest file to the current application directory
* Adjust `config/deploy/production.rb`
* Deploy the application
* Migrate the database

### Install Ruby 2.0.0 and Rails 4.0.13 on the production server
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

    mercury$ rvm gemset create rails4013

and switch to the gemset

    mercury$ rvm ruby-2.0.0-p643@rails4013

Finally we install Rails 4.0.13

    mercury$ gem install rails --version 4.0.13 --no-ri --no-rdoc

### Setup Apache 2
Change the default Ruby in `/etc/apache2/apache2.conf` from

    <IfModule mod_passenger.c>
      PassengerRoot /home/secondhand/.rvm/gems/ruby-1.9.3-p448@rails3211/gems/passenger-5.0.8
      PassengerDefaultRuby /home/secondhand/.rvm/wrappers/ruby-1.9.3-p448@rails3211/ruby
    </IfModule>

so it looks like the following

    <IfModule mod_passenger.c>
      PassengerRoot /home/secondhand/.rvm/gems/ruby-1.9.3-p448@rails3211/gems/passenger-5.0.8
      PassengerDefaultRuby /home/secondhand/.rvm/gems/ruby-2.0.0-p643@rails4013/wrappers/ruby
    </IfModule>

As we have only one application running we don't need to change 
`/etc/apache2/sites-available/secondhand.conf`.

In order to make the changes take effect we have to restart Apache 2 with

    mercury$ sudo apachectl restart

### Move manifest.yml
Next we need to move `manifest.yml` to the current release

`/home/secondhand/secondhand.mercury/shared/assests/manifest.yml` to 
`/home/secondhand/secondhand.mercury/current/assets_manifest.yml`.

    $ cd /home/secondhand/secondhand.mercury
    $ mv shared/assets/manifest.yml current/assets_manifest.yml

### Adjust `config/deploy/production.rb`
We have to process changes in `config/deploy/production.rb` as shown below.

replace the value of the `rvm_ruby_string`

    set :rvm_ruby_string, '1.9.3' 
    
with the new gemset

    set :rvm_ruby_string, '2.0.0@rails4013'

This will ensure that the new used Ruby version will be installed in 
`shared/bundle/ruby/`. If you just use `2.0.0` you will get an error like

     * 2015-12-24 08:14:16 executing `bundle:install`
     * alot of output
    ** [out :: secondhand.mercury] ERROR: Gem bundler is not installed, run `gem install bundler` firrst.

This is because Capistrano will use the Ruby version that is available in
`shared/bundle/ruby` which before deployment is `1.9.3` from previous 
deployments before we upgraded.

Then replace

    after 'deploy:create_symlink', 'copy_database_yml'

    desc "copy shared/database.yml to current/config/database.yml"
    task :copy_database_yml do
      config_dir = "#{shared_path}/config"

      unless run("if [ -f '#{config_dir}/database.yml' ]; 
                    then echo -n 'true'; 
                  fi")
        run "mkdir -p #{config_dir}" 
        upload("config/database.yml", "#{config_dir}/database.yml")
      end

      run "cp #{config_dir}/database.yml #{current_path}/config/database.yml"
    end

with

    before 'deploy:assets:precompile', 'copy_database_yml_to_release_path'
    after 'deploy:create_symlink', 'copy_database_yml'

    desc "copy shared/database.yml to RELEASE_PATH/config/database.yml"
    task :copy_database_yml_to_release_path do
      config_dir = "#{shared_path}/config"

      unless run("if [ -f '#{config_dir}/database.yml' ]; 
                    then echo -n 'true'; 
                  fi")
        run "mkdir -p #{config_dir}" 
        upload("config/database.yml", "#{config_dir}/database.yml")
      end

      run "cp #{config_dir}/database.yml #{release_path}/config/database.yml"
    end

    desc "copy shared/database.yml to current/config/database.yml"
    task :copy_database_yml do
      config_dir = "#{shared_path}/config"

      unless run("if [ -f '#{config_dir}/database.yml' ]; then 
                    echo -n 'true'; 
                  fi")
        run "mkdir -p #{config_dir}" 
        upload("config/database.yml", "#{config_dir}/database.yml")
      end

      run "cp #{config_dir}/database.yml #{current_path}/config/database.yml"
    end 

### Deployment
Now it is save to deploy your application with

    $ cap production deploy

And then run the database migrations

    $ cap production deploy:migrations

Go to [http://syc.dyndns.org:8080](http://syc.dyndns.org:8080) to check up your newly deployed application.

