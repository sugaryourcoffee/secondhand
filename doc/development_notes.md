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

If we have made any errors in our migration we can rollback the migration with 
`$ rake db:rollback`.

In order that the field gets also populated to our test database we have to run

    $ rake db:test:prepare

Otherwise we would still see the error that the `User` model doesn't respond to
`operator`.

### Run the Test to pass
Now our test should pass.

    $ rspec spec/models/user_spec.rb

## Populate a Value from an associated Table
Assume we have to tables User and News. Each `News` has an `author` which is
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

Rake Tasks
==========
To list als Rake tasks run

    $ rake -T

To list only Rake task for the database you can run

    $ rake -T db


