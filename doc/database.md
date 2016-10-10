Rails Database Queries
======================
This is a collection of database queries used in secondhand. A comprehensive
overview about ActiveRecord can be found at [ruby on rails guids](http://guides.rubyonrails.org/active_record_querying.html)

###Select only records that have non-empty associations
We want to have only those carts that have line items

     scope :not_empty, lambda {
       joins(:line_items).uniq
     }

###Create statistics about all events
We want to create statistics about our previous events. The statistics should
include

* Event name
* Event date
* Total value of lists
* Count of lists
* Count of registered and closed lists
* Count of sellings
* Revenue
* Average revenue
* Count of returns
* Value of returns
* Average value of returns
* Profit

We want to query the database directly within MySQL and later on implement the
statistics within the secondhand application.

We first have to switch to our Secondhand server

    $ ssh secondhand@mercury

We start the MySQL console with

    $ mysql -upierre -p

Then we select the database

    myslq>use secondhand-production

    Database changed




