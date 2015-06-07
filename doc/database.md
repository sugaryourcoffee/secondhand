Rails Database Queries
======================
This is a collection of database queries used in secondhand.

###Select only records that have non-empty associations
We want to have only those carts that have line items

     scope :not_empty, lambda {
       joins(:line_items).uniq
     }

