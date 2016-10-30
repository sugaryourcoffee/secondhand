Rails Database Queries
======================
Thisi a collection of database queries used in secondhand. A comprehensive
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

First we list all tables


    +---------------------------------+
    | Tables_in_secondhand_production |
    +---------------------------------+
    | carts                           |
    | conditions                      |
    | events                          |
    | items                           |
    | line_items                      |
    | lists                           |
    | news                            |
    | news_translations               |
    | pages                           |
    | reversals                       |
    | schema_migrations               |
    | sellings                        |
    | terms_of_uses                   |
    | users                           |
    +---------------------------------+
    14 rows in set (0.00 sec)

To show the schema of a table run `desc`

    mysql> desc events;

    +-----------------------+--------------+------+-----+---------+---------------
    | Field                 | Type         | Null | Key | Default | Extra         
    +-----------------------+--------------+------+-----+---------+---------------
    | id                    | int(11)      | NO   | PRI | NULL    | auto_increment
    | title                 | varchar(255) | YES  |     | NULL    |               
    | event_date            | datetime     | YES  |     | NULL    |               
    | location              | varchar(255) | YES  |     | NULL    |               
    | fee                   | decimal(5,2) | YES  |     | NULL    |               
    | deduction             | decimal(5,2) | YES  |     | NULL    |               
    | provision             | decimal(4,2) | YES  |     | NULL    |               
    | max_lists             | int(11)      | YES  |     | NULL    |               
    | max_items_per_list    | int(11)      | YES  |     | NULL    |               
    | created_at            | datetime     | NO   |     | NULL    |               
    | updated_at            | datetime     | NO   |     | NULL    |               
    | active                | tinyint(1)   | YES  |     | 0       |               
    | list_closing_date     | date         | YES  |     | NULL    |               
    | delivery_date         | date         | YES  |     | NULL    |               
    | delivery_start_time   | time         | YES  |     | NULL    |               
    | delivery_end_time     | time         | YES  |     | NULL    |               
    | delivery_location     | varchar(255) | YES  |     | NULL    |               
    | collection_date       | date         | YES  |     | NULL    |               
    | collection_start_time | time         | YES  |     | NULL    |               
    | collection_end_time   | time         | YES  |     | NULL    |               
    | collection_location   | varchar(255) | YES  |     | NULL    |               
    | information           | varchar(255) | YES  |     | NULL    |               
    | alert_terms           | varchar(255) | YES  |     | NULL    |               
    | alert_value           | int(11)      | YES  |     | 20      |               
    +-----------------------+--------------+------+-----+---------+---------------
    24 rows in set (0.00 sec)


    mysql> desc lists;

    +-------------------+--------------+------+-----+---------+----------------+
    | Field             | Type         | Null | Key | Default | Extra          |
    +-------------------+--------------+------+-----+---------+----------------+
    | id                | int(11)      | NO   | PRI | NULL    | auto_increment |
    | list_number       | int(11)      | YES  |     | NULL    |                |
    | registration_code | varchar(255) | YES  |     | NULL    |                |
    | container         | varchar(255) | YES  |     | NULL    |                |
    | event_id          | int(11)      | YES  |     | NULL    |                |
    | user_id           | int(11)      | YES  |     | NULL    |                |
    | created_at        | datetime     | NO   |     | NULL    |                |
    | updated_at        | datetime     | NO   |     | NULL    |                |
    | sent_on           | datetime     | YES  |     | NULL    |                |
    | accepted_on       | datetime     | YES  |     | NULL    |                |
    | labels_printed_on | datetime     | YES  |     | NULL    |                |
    +-------------------+--------------+------+-----+---------+----------------+
    11 rows in set (0.00 sec)

    mysql> desc line_items;

    +-------------+----------+------+-----+---------+----------------+
    | Field       | Type     | Null | Key | Default | Extra          |
    +-------------+----------+------+-----+---------+----------------+
    | id          | int(11)  | NO   | PRI | NULL    | auto_increment |
    | item_id     | int(11)  | YES  |     | NULL    |                |
    | cart_id     | int(11)  | YES  |     | NULL    |                |
    | reversal_id | int(11)  | YES  |     | NULL    |                |
    | created_at  | datetime | NO   |     | NULL    |                |
    | updated_at  | datetime | NO   |     | NULL    |                |
    | selling_id  | int(11)  | YES  |     | NULL    |                |
    +-------------+----------+------+-----+---------+----------------+
    7 rows in set (0.00 sec)

    mysql> desc items;

    +-------------+--------------+------+-----+---------+----------------+
    | Field       | Type         | Null | Key | Default | Extra          |
    +-------------+--------------+------+-----+---------+----------------+
    | id          | int(11)      | NO   | PRI | NULL    | auto_increment |
    | item_number | int(11)      | YES  |     | NULL    |                |
    | description | varchar(255) | YES  |     | NULL    |                |
    | size        | varchar(255) | YES  |     | NULL    |                |
    | price       | decimal(5,2) | YES  |     | NULL    |                |
    | created_at  | datetime     | NO   |     | NULL    |                |
    | updated_at  | datetime     | NO   |     | NULL    |                |
    | list_id     | int(11)      | YES  |     | NULL    |                |
    +-------------+--------------+------+-----+---------+----------------+
    8 rows in set (0.00 sec)

To do database queries we can do that with queries within the MySQL console or
we can dump the database tables into text files and use an external program as
[syc-svpro](https://github.org/gems/sycsvpro).

To dump the database we use mysqldump with

    $ mysqldump -upierre -p --tab=dump_dir secondhand_production

In order to be able to dump the database tables into files we need the file 
priviliges. We have to following command in MySQL

    mysql> GRAND FILE *.* to 'pierre'@'localhost';

Rather than useing syc-svpro we want to use generic MySQL commands to retrieve 
the data an present it in a table.

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

Event | Date | Value | Lists | Closed | Sellings | Revenue | Profit
----- | ---- | ----- | ----- | ------ | -------- | ------- | ------
..    | ..   | ..    | ..    | ..     | ..       | ..      | ..

First we want to retrieve the count of lists for each of the events

    mysql> select e.title, count(l.id) lists 
        -> from events e inner join lists l 
        -> on l.event_id = e.id group by e.title;
    +---------------------------------+-------+
    | title                           | lists |
    +---------------------------------+-------+
    | Frühjahrsbörse Burgthann 2014   |   250 |
    | Frühjahrsbörse Burgthann 2015   |   275 |
    | Frühjahrsbörse Burgthann 2016   |   275 |
    | Frühjahrsbörse Burgthann 2017   |   275 |
    | Herbstbörse Burgthann 2013      |   232 |
    | Herbstbörse Burgthann 2014      |   270 |
    | Herbstbörse Burgthann 2015      |   275 |
    | Herbstbörse Burgthann 2016      |   277 |

    +---------------------------------+-------+
    8 rows in set (0.01 sec)

To get the value of the lists for each event

    mysql> select e.title, sum(i.price) value
        -> from events e inner join lists l 
        -> on l.event_id = e.id inner join items i 
        -> on i.list_id = l.id group by e.title;
    +---------------------------------+--------------+
    | title                           | value        |
    +---------------------------------+--------------+
    | Frühjahrsbörse Burgthann 2014   |     25549.50 |
    | Frühjahrsbörse Burgthann 2015   |     29361.50 |
    | Frühjahrsbörse Burgthann 2016   |     30691.00 |
    | Herbstbörse Burgthann 2013      |     27885.00 |
    | Herbstbörse Burgthann 2014      |     32101.00 |
    | Herbstbörse Burgthann 2015      |     32555.50 |
    | Herbstbörse Burgthann 2016      |     32728.50 |
    +---------------------------------+--------------+
    7 rows in set (0.26 sec)

