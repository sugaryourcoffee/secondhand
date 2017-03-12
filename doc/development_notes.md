Development Notes
=================
Here you will find notes on topics that needed some research to get tackled and
are off the standard rails path. Also there are some gotchas that I rarely
use and I can lookup here if I need them.

Views
=====
Topics related to views can be found here.

Read User Input from Textfield and split into different Textfields
------------------------------------------------------------------
When collecting *Items* in a sales transaction or *Lineitems* in a redemption
transaction the *list number* and the *item number* have to be entered in to
different fields. When working with a barcode scanner the *list number* and 
*item number* are read into one field. This entry has to be split up into 
*list number* and *item number* and entered programatically into the two
respective fields.

### How to
When the user enters the page the focus has to be on the *list number* field.
That is the *list number* field needs `autofocus: true`. If there is a value
from a previous scan we need to overwrite this with a new scan. In order to
accomplish that we need to select the value on focus with 
`onfocus: "this.select()"`

Here is the view code for the above described approach.

    <%= text_field_tag :search_list_number, params[:search_list_number], 
                       autofocus: true, onfocus: "this.select()",
                       class: "input-medium search-query" %>

The next step is to read the value from the *list number* field. To do this we
listen on the `keydown` event of the `search_list_number` field. If the key is
`CR` we check whether the field contains 6 characters, 3 for the *list number*,
2 for the *item number* and 1 for the *check digit*. If so we split the value
and add the first 3 characters to the `search_list_number` field and the next 2
characters into the `search_item_number` text field. If the character count is
less than 6 digits we dont do nothing.

The coffee script code looks like this.

    $(document).ready ->
      $('#search_list_number').keydown (e) ->
        if e.keyCode == 13
          value = $(this).val()
          if value.length == 6
            $(this).val(value.slice(0,3))
            $('#search_item_number').val(value.slice(3,5))

Add an application version number
---------------------------------
An application number is especially usefull in cases of user requests or issues.
If we tag our releases in Git we can read the tag number and use it as the
version number.

    $ git describe --tags --abbrev=0

In `config/application.rb` we add a method that writes that reads the version
from git and writes it to `config/version`.

    if Rails.env.development?
      File.open('config/version', 'w') do |file|
        file.write `git describe --tags --abbrev=0`
      end
    end

    module Secondhand
      class Application < Rails::Application
        config.version = File.read('config/version')
      end
    end

`config/application.rb` runs only once when we start the server.

We can access the version with `Rails.configuration.version`. We use this in
the `app/views/layouts/_footer.html.erb`.

    <a href="https://github.com/sugaryourcoffee/secondhand",
      target="_blank">Secondhand <%= Rails.configuration.version %></a>
      by Sugar Your Coffee

Render views
------------
There are some conventions when rendering templates that are described here.

### Render implicit templates
We can render templates implicit by just invoking the `render` method with a
collection like so

    <%= render(@list.items) %>

This will assume a template called `_item.html.erb`. In that case it is assumed
that the `_item.html.erb` is in the same directory as the template calling the
`render` method.

Database
========
Here we find information on how to work with databases in Rails.

Add new Field to Table
----------------------
We can add new fields to tables with the `rails generate migration` function.

### Write the Test first
Assume we want to add a file `operator` to the `User` model. Before we add a 
new field to a table we first write a test with the expectation that the model 
responds to the new field. Using *RSpec* the respective test would look like 
this.

    require 'spec_helper'

    describe User do 
      before do
        @user = User.new(name: "Example User", email: "user@example.com")
      end

      subject { @user }

      .
      .
      it { should respond_to(:operator) }
      .
      .
    end
    
When we run the test with `$ rspec spec/models/user_spec.rb` we should get an
error that the `User` doesn't respond to `operator`.

### Create the Migration
The next step is to create the migration. We want to add an `operator` column
which defaults to `false`.

    $ rails generate migration add_operator_to_users operator:boolean
      invoke  active_record
      create    db/migrate/20150906084235_add_operator_to_users.rb

Now open up the generated migration and add the default value `false`.

    $ vi db/migrate/20150906084235_add_operator_to_users.rb
    class AddOperatorToUsers < ActiveRecord::Migration
      def change
        add_column :users, :operator, :boolean, default: false
      end
    end

To see all mirgrations we can run `$ rake db:migrate:status`. This will show
which migrations have been run indicated by *up* and which are pending indicated
by *down*.

### Run the Migration
After our migration is complete we can run it with

    $ rake db:migrate

This command will add the attribute to `db/schema.rb`.

If we have made any errors in our migration we can rollback the migration with 
`$ rake db:rollback`.

In order that the field gets also populated to our test database we have to run

    $ rake db:test:prepare

Otherwise we would still see the error that the `User` model doesn't respond to
`operator`.

### Run the Test to pass
Now our test should pass.

    $ rspec spec/models/user_spec.rb

Populate a Value from an associated Table
-----------------------------------------
Assume we have two tables User and News. Each `News` has an `author` which is
an `User` with the `admin` role. We want to add to the `author` field in the
`News` table an `User` that has the `admin` role. We can do so in a migration.

    class SetAuthorInNews < ActiveRecord::Migration
      class User < ActiveRecord::Base
      end
      class News < ActiveRecord::Base
        belongs_to :user
      end

      def up
        author = User.find_by_admin(true)
        News.update_all(user_id: author.id)
      end

      def down
        News.update_all(user_id: nil)
      end
    end

Rails Database Queries
----------------------
This is a collection of database queries used in secondhand. A comprehensive
overview about ActiveRecord can be found at [ruby on rails guides](http://guides.rubyonrails.org/active_record_querying.html)

### Select only records that have non-empty associations
We want to have only those carts that have line items

    scope :not_empty, lambda {
      joins(:line_items).uniq
    }

### WHERE with LIKE clause
If we need to find similar records of a table we can use the LIKE clause with
WHERE. Assume we want to find users with same domain name in their e-mail 
address.

    sugaryourcoffee = User.where("email like ?", "%@sugaryourcoffee.de")

If we want to make them all admins we could do

    sugaryourcoffee.each { |u| u.toggle!(:admin) }

Rake Tasks
==========
To list all Rake tasks run

    $ rake -T

To list only Rake task for the database you can run

    $ rake -T db

Git
===
The application is managed with Git.

Initialize a Git repository
---------------------------
In the application directory we intialize a Git repository.

    $ git init
    $ git add .
    $ git commit -am "intial commit"

Check out a Branch
------------------
When we work on a new functionality we want to do that in different branch in
order to roll back to the master branch if we mess up our application.

To create a new branch we call

    $ git checkout -b new-function-name
    $ git push --set-upstream origin new_function_name

  Then we work on the application and do our commits and pushs as usual.
    
    $ git commit -am "changes we made"
    $ git push

When done and our specs ran without errors we check out master and merge the
branch into it

    $ git checkout master
    $ git merge new_function_name
    $ git push

Selenium Webdriver with Firefox
===============================
After upgrading Firefox to 47.0 the Selenium webdriver is not working anymore.
It opens the Firefox default window but doesn't go to the requested website.
After the specs ran it shows an error message like

     Failure/Error: sign_in(admin)
     Selenium::WebDriver::Error::WebDriverError:
     unable to obtain stable firefox connection in 60 seconds (127.0.0.1:7055)

First we update to the newest Selenium Webdriver. To do that we create a new 
Git branch

    $ git checkout -b selenium-webdriver-upgrade

Then we update the selenium-webdriver gem with
   
    $ bundle update selenium-webdriver

This will update the gem and all dependencies.

When running the specs again the Firefox window doesn't show up anymore and 
shows the error

    Failure/Error: sign_in user
    Errno::ECONNREFUSED:
      Connection refused - connect(2)

This issue results from an incompatibility of selenium-webdriver 2.53.4 and
Firefox 47.0 but selenium-webdriver runs with Firefox 47.0.1 so we need to 
update to that version. But unfortunately it is not available in the Ubuntu
repository. So we need to install it manually as describe [here](http://libre-software.net/how-to-install-firefox-on-ubuntu-linux-mint/).
Following is a summary of the installation steps.

We download Firefox from [https://www.mozilla.org/de/firefox/channel/#firefox](https://www.mozilla.org/de/firefox/channel/#firefox).

Then we go to the download location and extract the bz2 file

    $ cd Downloads
    $ tar xjf firefox-47.0.1.tar.bz2

Next we move the directory to `/opt/firefox`. If this already exists we rename
the old one to `/opt/firefox-47`.

    $ mv firefox /opt/firefox-47.0.1

We want to use Firefox 47.0.1 as the default browser and rename the existing 
firefox launcher

    $ sudo mv /usr/bin/firefox /usr/bin/firefox-47

and create a symbolic link to the firefox launcher for version 47.0.1

    $ sudo ln -s /opt/firefox-47.0.1/firefox /usr/bin/firefox

From command line we can check that we are now start version 47.0.1

    $ firefox --version
    Mozill Firefox 47.0.1

If we run now `rspec` it should work as before.

A better solution can be found at [blog.pixera.com)[http://blog.pixarea.com/2013/02/locking-the-firefox-version-when-testing-rails-with-capybara-and-selenium/).

Here is the main extract

Create a new file `spec/helpers/env.helper` and add following lines

    Capybara.register_driver :selenium do |app|
      require 'selenium/webdriver'
      Selenium::WebDriver::Firefox::Binary.path = "/opt/firefox-47.0.1/firefox"
      Capybara::Selenium::Driver.new(app, browser: :firefox)
    end


