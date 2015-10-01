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
* Tag the current version to Git
* Check out a new branch for the migration process
* Update to the lates Ruby 1.9.3 patch level
* Update to the lates Rails 3.2 version

## Run the tests first
First make sure all your tests pass by running *rspec*.

    $ rspec

If you encounter errors first fix them before you move on.

## Tag the current application version
Before we move on we want to make sure that we can come back to the currently
working and released version. To do that we create a branch and tag this 
branch with a version number.

We first want to create a branch with the released version in order to be able
to make changes especially bug fixes to this version. This is necessary if 
users won't immediately upgrade to the the new version.

    $ git checkout --branch v1.1-stable
    $ git push --set-upstream origin v1.1-stable

Next we want to tag this branch with a version number. To list the tags we can 
issue

    $ git tag
    v1.0
    v1.0.1
    v1.0.2

To tag our branch we checkout *v1.1-stable* and then issue the tag command

    $ git checkout v1.1-stable
    $ git tag -a v1.1.0 -m "Secondhand V1.1.0 - Release 2015-09-18"

Finally push the tagged commit to Github with

    $ git push --tags

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

## Merge the updated app to the master branch
Now that we have updated our Secondhand app to the most current Ruby and Rails 
versions we want to merge the changes back to the master branch. We first 
checkout the master branch and then push them to github.

    $ git checkout master
    $ git merge rails4-0
    $ git push

Now we are ready to actually upgrade to Rails 4.0.

## Prepare the Gemfile
The first step is to change the Ruby version in the Gemfile. But we also want
to set the version numbers for the other gems listed in the Gemfile so they
meet the pre-conditions working with Rails 4.0. To see what gem versions we need
in combination with Ruby 4.0 we create a Rails project with the most recent
Rails 4.0 version, which is at this writing *4.0.13*.

    $ mkdir ~/Work/rails-version-test
    $ cd ~/Work/rails-version-test
    $ gem install rails --version 4.0.13
    $ rails _4.0.13_ new test-4.0.13
 
In the Gemfile we can see the gem version that work together with Rails 4.0.13.
The table below lists the gems (from the Secondhand Gemfile) with the versions
of the *test-4.0.13* app indicated by `~>` and `>=`.

Gem                      | Rails 3.2.22 | Rails 4.0.13    | Group
------------------------ | ------------ | --------------- | -----
rails                    | 3.2.22       | 4.0.13          | top
bootstrap-sass           | 2.3.1.0      | 2.3.1.0         | top
faker                    | 1.0.1        | ~> 1.5.0        | top
will\_paginate           | 3.0.3        | 3.0.7           | top
bootstrap-will\_paginate | 0.0.6        | 0.0.10          | top
prawn                    | 0.12.0       | 1.3.0           | top
syc-barcode              | 0.0.3        | 0.0.3           | top
net-ssh                  | 2.9.2        | -               | top
sqlite3                  |              |                 | development
rspec-rails              | 2.99.0       | 2.99.0          | development, test
guard-rspec              | 4.6          | 4.6             | development
annotate                 | 2.5.0        | 2.6.10          | development
guard-spork              | 2.1          | 2.1             | test
spork                    | 0.9          | 0.9             | test
capybara                 | 2.1.0        | 2.1.0           | test
rb-inotify               | 0.9.0        | 0.9.0           | test
libnotify                | 0.5.9        | 0.5.9           | test
factory\_girl\_rails     | 1.4.0        | 1.4.0           | test
cucumber-rails           | 1.2.1        | 1.2.1           | test
database\_cleaner        | 0.7.0        | 0.7.0           | test
selenium-webdriver       |              |                 | test
sass-rails               | 3.2.3        | ~> 4.0.2        | assets -> top
coffee-rails             | 3.2.1        | ~> 4.0.0        | assets -> top
uglifier                 | 1.0.3        | >= 1.3.0        | assets -> top
jquery-rails             |              |                 | top
best\_in\_place          |              |                 | top
gritter                  | 1.1.0        | 1.1.0           | top
bcrypt-ruby              | 3.0.1        | ~> bcrypt 3.1.7 | top
rvm-capistrano           | 1.5.6        | 1.5.6           | top
mysql2                   |              |                 | production
turbolinks               | -            |                 | top
jbuilder                 | -            | ~> 1.2          | top
sdoc                     | -            |                 | doc

We start by changing the rails version in our Gemfile to 

    gem 'rails', '4.0.13'

and then run bundle install. After the installation we get following post
install messages.

    Post-install message from capybara:
    IMPORTANT! Some of the defaults have changed in Capybara 2.1. If you're 
    experiencing failures,                                                                  
    please revert to the old behaviour by setting:

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

We come back to them if we encounter problems. 

## Update Secondhand configuration files
Now we use a rake task that helps to interactively update configuration files.

    $ rake rails:update

This will ask whether to overwrite the old files with new files. With `d` we
can diff the old and the new file. Here is how we process Secondhand.

File                                    | Overwrite | After update action
--------------------------------------- | --------- | -------------------
config/boot.rb                          | yes       | no
config/routes.rb                        | no        | yes
config/application.rb                   | yes       | yes
config/environment.rb                   | no        | no
conifg/environments/development.rb      | yes       | yes
config/environsments/production.rb      | yes       | yes
config/environments/test.rb             | yes       | yes
config/initializers/inflections.rb      | yes       | yes
config/initializers/secret\_token.rb    | yes       | no
config/initializers/sessions\_store.rb  | yes       | no
config/initializers/wrap\_parameters.rb | yes       | no
config/locales/en.yml                   | no        | no
bin/rails                               | yes       | no
bin/rake                                | yes       | no

### config/routes.rb
If we run `rspec` we will get error messages which can be considered hints in
regard of changes in the REST actions.

    $ rspec
    /home/pierre/.rvm/gems/ruby-1.9.3-p551@rails4013/gems/actionpack-4.0.13/
    lib/action_dispatch/routing/mapper.rb:191:in `normalize_conditions!': You 
    should not use the `match` method in your router without specifying an 
    HTTP method. (RuntimeError)
    If you want to expose your action to both GET and POST, add 
      `via: [:get, :post]` option.
    If you want to expose your action to GET, use `get` in the router:
      Instead of: match "controller#action"
      Do: get "controller#action"

We replace the `match` method with a `get` or `delete` method in 
`config/routes.rb` as shown in the table.

Ruby 4.0                                    | Ruby 3.2
------------------------------------------- | --------------------------------
root                'static\_pages#home'    | root to: 'static\_pages#home'
get    'signup'  => 'users#new'             | match '/signup', to: 'users#new'
get    'signin'  => 'sessions#new'          | match '/signin', to: 'sessions#new'
delete 'signout' => 'sessions#destroy'      | match '/signout', to: 'sessions#destroy', via: :delete
get    'about'   => 'static\_pages#about'   | match '/about', to: 'static\_pages#about'
get    'help'    => 'static\_pages#help'    | match '/help', to: 'static\_pages#help'
get    'contact' => 'static\_pages#contact' | match '/contact', to: 'static\_pages#contact'
get    'message' => 'static\_pages#message' | match '/message', to: 'static\_pages#message'
put :update\_list                           | patch :update\_list
put :update\_item                           | patch :update\_item

When done we can run `rspec` again and check whether routing errors occur. But
we also can check the `rake routes` command whether it draws error messages.

    $ rake routes

### config/application.rb

Action                   | Description
------------------------ | ------------------------------------------------
require 'interleave2of5' | require 'interleave2of5'
autoload files from lib/ | config.autoload\_paths << Rails.root.join('lib')

### config/environments/development.rb

Action                 | Description
---------------------- | -----------------------------------------------
default URL            | config.action\_mailer.default\_url\_options = \
                       |   { host: "localhost:3000" } 
mailer delivery method | config.action\_mailer.delivery\_method = :test 

### config/environments/staging.rb

Action      | Description
----------- | ------------------------------------------------
deliveries  | config.action\_mailer.perform\_deliveries = true
default URL | config.action\_mailer.default\_url\_options = \
            |   { host: "syc.dyndns.org:8082" }

### config/environments/production.rb

Action      | Description
----------- | ------------------------------------------------
deliveries  | config.action\_mailer.perform\_deliveries = true
default URL | config.action\_mailer.default\_url\_options = \
            |   { host: "syc.dyndns.org:8080" }

### config/environments/test.rb

Action      | Description
----------- | --------------------------------------------  
default URL | config.action\_mailer.default\_url\_options = \
            |   { host: "localhost:3000" }

### config/initializers/inflections.rb

Action            | Description
----------------- | -------------------------------------------------
Pluralize 'Liste' | ActiveSupport::Inflector.inflections do |inflect|
                  |   inflect.plural 'Liste', 'Listen' 
                  | end

## Error Messages
In this section error message are discussed that have arisen after upgrading to
Rals 4.

## Deprecated has\_many options

```
DEPRECATION WARNING: The following options in your Cart.has_many :line_items 
declaration are deprecated: :order. Please use a scope block instead. For 
example, the following: 

    has_many :spam_comments, conditions: { spam: true }, class_name: 'Comment'  
                                                                                
should be rewritten as the following:
                                                                                
    has_many :spam_comments, -> { where spam: true }, class_name: 'Comment'

. (called from <class:Cart> at 
   /home/pierre/Work/Secondhand/app/models/cart.rb:2)
```

In `app/models/cart.rb` we change

    has_many :line_items, :order => "created_at DESC"

to

    has_many :line_items, -> { order(created_at: :desc) }

## Strong parameters in favor of attr\_accessible
In Rails 4 `attr_accessible` is not used anymore in the model. Accessible 
attributes are now defined in the controller. The error below shows up when
using `attr_accessible` in the model.

```
/home/pierre/.rvm/gems/ruby-1.9.3-p551@rails4013/gems/activemodel-4.0.13/lib/act
ive_model/deprecated_mass_assignment_security.rb:17:in `attr_accessible': `attr_
accessible` is extracted out of Rails into a gem. Please use new recommended pro
tection model for params(strong_parameters) or add `protected_attributes` to you
r Gemfile to use old one. (RuntimeError) 
```

To change that we define accessible attributes in the controller and remove
`attr_accessible` from the model.

In the `app/models/cart.rb` model we remove `attr_accessible :cart_type` and 
add following to `app/controllers/cart_controller.rb`.

    private

    def cart_params
      params.require(:cart).permit(:cart_type)
    end

Then in the `new` and `update` action use the `cart_params` method.

In order to speed up migration we will use the `protected_attributes` gem and
then gradually migrate to *strong prameters*. Add following line to the
*Gemfile*.

    gem 'protected_attributes'

and run

    $ bundle install

## scope without passing a callable object
`scope` without calling a callable object is deprecated.

## database\_cleaner
Version 0.7.0 has to be upgraded to >= 1.1.0. Replace the version `0.7.0` with
`1.5.0` (the latest at this time of writing) and run

    $ bundle update --source database_cleaner

## ActionController::RoutingError: uninitialized constant SessionController
This occured as I was using `'signin' => 'session#new'` instead of 
`'singin` => 'sessions#new'`. In this case the `ActionController` is using a
controller `SessionController` instead of the `SessionsController`

## Missing host to link to

```
Missing host to link to! Please provide the :host parameter, 
set default_url_options[:host], or set :only_path to true
```

In this case add to 

`config/environments/test.rb`  and `config/environment/development.rb`

    config.action_mailer.default_url_options = { host: "localhost:3000" }

`config/environments/staging.rb` 

    config.action_mailer.default_url_options = { host: "syc.dyndns.org:8082" }

`config/environments/production.rb` 

    config.action_mailer.default_url_options = { host: "syc.dyndns.org:8080" }

## Deprecation Warnings
This section discusses deprecation warnings and how to fix them.

### Dynamic methods

```
DEPRECATION WARNING: This dynamic method is deprecated. Please use e.g. 
Post.where(...).all instead. (called from total_count at 
/home/pierre/Work/Secondhand/app/models/list.rb:78)
```

Old                                 | New
----------------------------------- | --------------------------------------
List.find_all_by_event_id(event_id) | List.where(event_id: event_id)
List.find_all_by_event_id(@event)   | List.where(event_id: @event)
List.find_by_list_number!(number)   | List.find_by!(list_number: number)
List.find_by_list_number_and_date(number, date) | List.where(list_number: number, date: date)

Note: When changing to Rails 4 finders not the behaviour in regard to 
exceptions as shown in following table.

Finder               | Exception
-------------------- | --------------------------------------------
User.find(id)        | if `id` doesn't exist exception is thrown
User.find_by(id: id) | if `id` doesn't exist no exception is thrown

