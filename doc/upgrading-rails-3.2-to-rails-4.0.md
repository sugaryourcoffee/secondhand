Upgrading from Rails 3.2 to Rails 4.0
=====================================
In this document I describe the steps to upgrade *Secondhand* from Rails 3.2 to
Rails 4.0. The current versions used are

* Ruby 1.9.3-p547
* Rails 3.2.11
* RVM 1.26.11

We are using following RVM gemset for the application

* ruby-1.9.3-p547@rails3211

We run the migration in two stages. First we do a preparation phase where we
update the application to the most recent versions within the major version.
When this is done we do the actual migration. 

The preparation steps to follow are

* Run the tests and ensure they pass
* Tag the current version to Git
* Check out a new branch for the migration process
* Update to the lates Ruby 1.9.3 patch level
* Update to the lates Rails 3.2 version

The actual migratio is as follows

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
This is stage 1 where we prepare for upgrading our Rails 3.2 app to Rails 4.0.

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

# Stage 2 - Upgrade to Rails 4
Now we are prepared to actually upgrade to Rails 4. We checkout a new branch

    $ git checkout -b upgrade-to-rails-4
    $ git push --set-upstream origin upgrade-to-rails-4

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

## Upgrade bin/ directory
When you run `rails server` or `rails console` you will get a message saying

```
Looks like your app's ./bin/rails is a stub that was generated by Bundler.

In Rails 4, your app's bin/ directory contains executables that are versioned
like any other source code, rather than stubs that are generated on demand.

Here's how to upgrade:

  bundle config --delete bin    # Turn off Bundler's stub generator
  rake rails:update:bin         # Use the new Rails 4 executables
  git add bin                   # Add bin/ to source control

You may need to remove bin/ from your .gitignore as well.

When you install a gem whose executable you want to use in your app,
generate it and add it to source control:

  bundle binstubs some-gem-name
  git add bin/new-executable
```

To upgrade we just follow the instructions and interactively upgrade the bin/ 
directory. The table shows that we overwrite `bin/rails` and `bin/rake` without
any after update actions.

File      | Overwrite | After update action
--------- | --------- | -------------------
bin/rails | yes       | no
bin/rake  | yes       | no

## Error Messages
In this section error message are discussed that have arisen after upgrading to
Rals 4.

## undefined method 'table' for Prawn
The *Prawn* version 1.3.0 has extracted `table`. So whe running *Secondhand* we
get an error message saying

    NoMethodError:
      undefined method `table` for #<Prawn::Document:0x000000006b397a8>

In order to get rid of the error we have to add *prawn-table* to our *Gemfile*.

    gem 'prawn-table', '~> 0.2.2'

And then run `$ bundle install`

We render the generated pdf to a file. In the previous version 0.12.0 the 
generated filename was returned. No `pdf.generate_file` returns `nil`. To get
the filename we have to return the filename explicitly.

    pdf.render_file("tmp/selling_#{id}.pdf")
    File.absolute_path("tmp/selling_#{id}.pdf")

In the calling method we expect the old behaviour to get a file handle where we
retrieve the path with `to_path`. In the new version we have to remove method 
call as we already receive the filename.

In `app/controllers/sellings_controller.rb` we change 

    if system('lpr', @selling.to_pdf.to_path)

to

    if system('lpr', @selling.to_pdf)

## ActionController::UnknownFormat
This error is caused by *Capybara* when clicking a link that is configured with
`remote: true` and should render a *JavaScript* template. The `js` format is not
forwarded to the controller and hence the error occurs. When clicking the link
in the application it working without errors. To overcome this issue in the 
tests we have to explicitly specify the template to render.

The custom action uses `respond_to` in 
`app/controllers/acceptances_controller.rb`

    def edit_list
      @list = List.find(params[:id])
      respond_to do |format|
        format.js
      end
    end

We change this as follows

    def edit_list
      @list = List.find(params[:id])
      render template: 'acceptances/edit_list.js.erb'
    end

## Error in method\_missing
In Rails 4 IDs of associated models are determined with `method_missing`. If 
you overwrite `method_missing` and are operating on the valued that is send to
method missing you have to send all values to super if the value is not operated
on.

    class LineItem < ActiveRecord::Base
      belongs_to :selling # foreign key is selling_id

      def method_missing(name, *args)
        m = name.to_s.scan(/^.*(?=_opponent$)/).first
        super if !respond_to? m.to_sym
        return selling  if m == 'reversal'
        return reversal if m == 'selling'
      end
    end

Now consider accessing `selling_id`

    > line_item = LineItem.new
    > line_item.selling_id
    NoMethodError:
      undefined method 'to_sym' for nil:NilClass

In the example `selling_id` is not known in the `LineItem` model and therefor 
`selling_id` is send to `method_missing`. But `selling_id` is not recognized
by the regex and `m` will be `nil` and hence the exception is thrown. To fix
this we have to check for `m.nil?`

    class LineItem < ActiveRecord::Base
      belongs_to :selling # foreign key is selling_id

      def method_missing(name, *args)
        m = name.to_s.scan(/^.*(?=_opponent$)/).first
        super if m.nil? or !respond_to? m.to_sym
        return selling  if m == 'reversal'
        return reversal if m == 'selling'
      end
    end
    
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
`'singin' => 'sessions#new'`. In this case the `ActionController` is using a
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

### This dynamic method is deprecated

```
DEPRECATION WARNING: This dynamic method is deprecated. Please use e.g. 
Post.where(...).all instead. (called from total_count at 
/home/pierre/Work/Secondhand/app/models/list.rb:78)
```

Old                                 | New
----------------------------------- | --------------------------------------
List.find\_all\_by\_event\_id(event\_id) | List.where(event\_id: event\_id)
List.find\_all\_by\_event\_id(@event)   | List.where(event\_id: @event)
List.find\_by\_list\_number!(number)   | List.find\_by!(list\_number: number)
List.find\_by\_list\_number\_and\_date(number, date) | List.where(list\_number: number, date: date)

Note: When changing to Rails 4 finders note the changed behaviour in regard to 
exceptions as shown in following table.

Finder               | Exception
-------------------- | --------------------------------------------
User.find(id)        | if `id` doesn't exist exception is thrown
User.find\_by(id: id) | if `id` doesn't exist no exception is thrown

### Relation#all is deprecated

```
DEPRECATION WARNING: Relation#all is deprecated. If you want to eager-load a relation, you can call #load (e.g. `Post.where(published: true).load`). If you want to get an array of records from a relation, you can call #to_a (e.g. `Post.where(published: true).to_a`). (called from block in _app_views_lists_index_html_erb__2537020648015865330_60608460 at /home/pierre/Work/Secondhand/app/views/lists/index.html.erb:85)
```

To remove the deprecation warning we have to remove `.all` from the `where`
clauses. To find all of the occurences we can use *grep* like so

    $ grep -rn "\.all" app/

and then just remove all the occurrences of `.all`.

### Calling #find(:all) is deprecated

```
DEPRECATION WARNING: Calling #find(:all) is deprecated. Please call #all directly instead. (called from block in _app_views_lists_index_html_erb__2537020648015865330_60608460 at /home/pierre/Work/Secondhand/app/views/lists/index.html.erb:85)
```

This can be cleared with searching for all `find(:all)` occurences and replace
them with `all`.

### #apply\_finder\_options is dreprecated

```
DEPRECATION WARNING: #apply_finder_options is deprecated. (called from index at /home/pierre/Work/Secondhand/app/controllers/lists_controller.rb:17)
```

To solve this deprecation warning we change for instance this snippet in
`app/controllers/lists_controller.rb`

    @lists = List.order(:event_id).order(:list_number)
                 .paginate(page: params[:page], 
                           conditions: List.search_conditions(params))

to

    @lists = List.where(List.search_conditions(params))
                 .order(:event_id)
                 .order(:list_number)
                 .paginate(page: params[:page])

To find all occurrences we issue

    $ grep -rn "conditions:" app/

and replace the occurrenes accordingly.

### :confirm option is deprecated

```
DEPRECATION WARNING: :confirm option is deprecated and will be removed from Rails 4.1. Use 'data: { confirm: 'Text' }' instead. (called from _app_views_users__user_html_erb___3974444937014490660_64610680 at /home/pierre/Work/Secondhand/app/views/users/_user.html.erb:15)
```

This is typically used in a user dialog to confirm a deletion. We replace all
the snippets in the view files as shown in the example in
`app/views/users/_user_html.rb`

    <%= link_to t('.delete'), user, method: :delete, confirm: t('.confirm'),
        class: "btn btn-warning" %>

to

    <%= link_to t('.delete'), user, method: :delete, 
        data: { confirm: t('.confirm') }, class: "btn btn-warning" %>

## RSpec deprecation warnings
RSpec 2.99.0 is a pre-version to RSpec 3 and already pointing to deprecations 
that will be removed from Rails 3. This section explains the necessary changes
to make to be ready for Rails 3.

When you run RSpec you will get a general deprecation warnings saying

```
Deprecation Warnings:

--------------------------------------------------------------------------------
RSpec::Core::ExampleGroup#example is deprecated and will be removed
in RSpec 3. There are a few options for what you can use instead:

  - rspec-core's DSL methods (`it`, `before`, `after`, `let`, `subject`, etc)
    now yield the example as a block argument, and that is the recommended
    way to access the current example from those contexts.
  - The current example is now exposed via `RSpec.current_example`,
    which is accessible from any context.
  - If you can't update the code at this call site (e.g. because it is in
    an extension gem), you can use this snippet to continue making this
    method available in RSpec 2.99 and RSpec 3:

      RSpec.configure do |c|
        c.expose_current_running_example_as :example
      end

(Called from /home/pierre/.rvm/gems/ruby-1.9.3-p551@rails4013/gems/capybara-2.1.0/lib/capybara/rspec.rb:20:in `block (2 levels) in <top (required)>')
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
RSpec::Core::ExampleGroup#example is deprecated and will be removed
in RSpec 3. There are a few options for what you can use instead:

  - rspec-core's DSL methods (`it`, `before`, `after`, `let`, `subject`, etc)
    now yield the example as a block argument, and that is the recommended
    way to access the current example from those contexts.
  - The current example is now exposed via `RSpec.current_example`,
    which is accessible from any context.
  - If you can't update the code at this call site (e.g. because it is in
    an extension gem), you can use this snippet to continue making this
    method available in RSpec 2.99 and RSpec 3:

      RSpec.configure do |c|
        c.expose_current_running_example_as :example
      end

(Called from /home/pierre/.rvm/gems/ruby-1.9.3-p551@rails4013/gems/capybara-2.1.0/lib/capybara/rspec.rb:21:in `block (2 levels) in <top (required)>')
--------------------------------------------------------------------------------
```

These error messages are caused by *Capybara* version 2.1.0. To remove these we
can add the code snippets mentioned in the deprecation warnings to 
`spec/spec_helper.rb`.

    RSpec.configure do |config|
      config.expose_current_running_example_as :example
      config.infer_spec_type_from_file_location!
    end

### Use of rspec-core's 'its' method is deprecated.

```
Use of rspec-core's `its` method is deprecated. Use the rspec-its gem instead. Called from /home/pierre/Work/Secondhand/spec/models/item_spec.rb:22:in `block in <top (required)>'.
```

We can replace `its` as follows

RSpec 2                                | RSpec 2.99.0 or 3
-------------------------------------- | ---------------------------------
its(:list) { should == list }          | it { @item.list.should eq(list) }

We could also keep using `its` when intalling *rspec-its* gem instead.

### 'be\_false' is deprecated

```
`be_false` is deprecated. Use `be_falsey` (for Ruby's conditional semantics) or `be false` (for exact `== false` equality) instead. Called from /home/pierre/Work/Secondhand/spec/models/cart_spec.rb:35:in `block (4 levels) in <top (required)>'.
```

### 'be\_true' is deprecated

```
`be_true` is deprecated. Use `be_truthy` (for Ruby's conditional semantics) or `be true` (for exact `== true` equality) instead. Called from /home/pierre/Work/Secondhand/spec/models/cart_spec.rb:43:in `block (4 levels) in <top (required)>'.
```

### expect { }.not\_to raise\_error(SpecificErrorClass) is deprecated

```
`expect { }.not_to raise_error(SpecificErrorClass)` is deprecated. Use `expect { }.not_to raise_error` (with no args) instead. Called from /home/pierre/Work/Secondhand/spec/requests/event_pages_spec.rb:111:in `block (5 levels) in <top (required)>'.
```

### expect(collection).to have(1).items is deprecated

```
`expect(collection).to have(1).items` is deprecated. Use the rspec-collection_matchers gem or replace your expectation with something like `expect(collection.size).to eq(1)` instead. Called from /home/pierre/Work/Secondhand/spec/models/item_spec.rb:16:in `block (2 levels) in <top (required)>'.
```

To search for all occurences we can use *grep* with Perl syntax like so

    $ grep -rnP "have\(\d+\)" spec/

We can replace as follows

RSpec 2                                | RSpec 2.99.0 or 3
-------------------------------------- | -----------------------------------
it { list.items.should have(1).items } | it { list.items.size.should eq(1) }
it { list.items.should have(0).items } | it { list.items.should be\_empty }

## Merge to Master
Now that all our specs run without error we merge our *upgrade-to-rails-4* 
branch back to the master branch.

    $ git checkout master
    $ git merge upgrade-to-rails-4

