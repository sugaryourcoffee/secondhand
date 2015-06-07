Rails Database Queries
======================
This is a collection of database queries used in secondhand. A comprehensive
overview about ActiveRecord can be found at [ruby on rails guids](http://guides.rubyonrails.org/active_record_querying.html)

###Select only records that have non-empty associations
We want to have only those carts that have line items

     scope :not_empty, lambda {
       joins(:line_items).uniq
     }

