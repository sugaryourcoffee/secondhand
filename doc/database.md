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
* Lists with no sold items
* Lists with revenue less than 20 EUR

We want to query the database directly within MySQL and later on implement the
statistics within the secondhand application.

We first have to switch to our Secondhand server

    $ ssh secondhand@mercury

We start the MySQL console with

    $ mysql -upierre -p

We can list all databases with `mysql> show databases;`

Then we select the database 

    myslq>use secondhand_production

    Database changed

First we list all tables with `mysql> show tables;`


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

Count of sellers per event

    mysql> select e.title, count(distinct s.id) sellers
        -> from events e 
        -> inner join lists l on l.event_id = e.id
        -> inner join users s on l.user_id = s.id
        -> group by e.title;

    +---------------------------------+---------+
    | title                           | sellers |
    +---------------------------------+---------+
    | Frühjahrsbörse Burgthann 2014   |     139 |
    | Frühjahrsbörse Burgthann 2015   |     146 |
    | Frühjahrsbörse Burgthann 2016   |     143 |
    | Herbstbörse Burgthann 2013      |     130 |
    | Herbstbörse Burgthann 2014      |     153 |
    | Herbstbörse Burgthann 2015      |     141 |
    | Herbstbörse Burgthann 2016      |       9 |
    | Testbörse 2017 Beta 3.0.0       |       2 |
    +---------------------------------+---------+
    8 rows in set (0.00 sec)

Count of lists for each event

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

Count of items for each event

    mysql> select e.title, count(i.id) items from events e
        -> inner join lists l on l.event_id = e.id
        -> inner join items i on i.list_id = l.id
        -> group by e.title;

    +---------------------------------+-------+
    | title                           | items |
    +---------------------------------+-------+
    | Frühjahrsbörse Burgthann 2014   |  8946 |
    | Frühjahrsbörse Burgthann 2015   |  9969 |
    | Frühjahrsbörse Burgthann 2016   |  9903 |
    | Herbstbörse Burgthann 2013      |  8564 |
    | Herbstbörse Burgthann 2014      |  9238 |
    | Herbstbörse Burgthann 2015      |  9619 |
    | Herbstbörse Burgthann 2016      |   251 |
    | Testbörse 2017 Beta 3.0.0       |     7 |
    +---------------------------------+-------+
    8 rows in set (0.00 sec)

Value of the lists for each event

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

Count of sellings per event

    mysql> select e.title, count(s.id) sellings from events e
        -> inner join sellings s on s.event_id = e.id
        -> group by e.title;
    +---------------------------------+----------+
    | title                           | sellings |
    +---------------------------------+----------+
    | Frühjahrsbörse Burgthann 2016   |      410 |
    | Herbstbörse Burgthann 2015      |      427 |
    | Herbstbörse Burgthann 2016      |        1 |
    | Testbörse 2017 Beta 3.0.0       |        3 |
    +---------------------------------+----------+
    4 rows in set (0.00 sec)

Count of sold items per event
    mysql> select e.title, count(li.id) line_items from events e 
        -> inner join sellings s on s.event_id = e.id 
        -> inner join line_items li 
        ->   on li.selling_id = s.id and li.reversal_id is null 
        -> group by e.title;
    +---------------------------------+------------+
    | title                           | line_items |
    +---------------------------------+------------+
    | Frühjahrsbörse Burgthann 2016   |       4975 |
    | Herbstbörse Burgthann 2015      |       5020 |
    | Herbstbörse Burgthann 2016      |          2 |
    | Testbörse 2017 Beta 3.0.0       |          5 |
    +---------------------------------+------------+
    4 rows in set (0.06 sec)

Average sales value per event

Revenue per event

    mysql> select e.title, sum(i.price) revenue from events e 
        -> inner join sellings s on s.event_id = e.id 
        -> inner join line_items li 
             on li.selling_id = s.id and li.reversal_id is null 
        -> inner join items i on i.id = li.item_id 
        -> group by e.title;
    +---------------------------------+----------+
    | title                           | revenue  |
    +---------------------------------+----------+
    | Frühjahrsbörse Burgthann 2016   | 14622.00 |
    | Herbstbörse Burgthann 2015      | 16103.00 |
    | Herbstbörse Burgthann 2016      |    16.50 |
    | Testbörse 2017 Beta 3.0.0       |    48.00 |
    +---------------------------------+----------+
    4 rows in set (0.06 sec)

Count of reversals per event

    mysql> select e.title, count(r.id) reversals from events e 
        -> inner join reversals r on r.event_id = e.id group by e.title;
    +---------------------------------+-----------+
    | title                           | reversals |
    +---------------------------------+-----------+
    | Frühjahrsbörse Burgthann 2016   |         1 |
    | Herbstbörse Burgthann 2015      |         6 |
    | Testbörse 2017 Beta 3.0.0       |         1 |
    +---------------------------------+-----------+

 3 rows in set (0.00 sec)

Count of reversed items per event

    mysql> select e.title, count(li.id) line_items from events e 
        -> inner join reversals r on r.event_id = e.id 
        -> inner join line_items li on li.reversal_id = r.id 
        -> group by e.title;
     +---------------------------------+------------+
     | title                           | line_items |
     +---------------------------------+------------+
     | Frühjahrsbörse Burgthann 2016   |          2 |
     | Herbstbörse Burgthann 2015      |         13 |
     | Testbörse 2017 Beta 3.0.0       |          1 |
     +---------------------------------+------------+
     3 rows in set (0.00 sec)
 
Average reversal value per event

Reversal value per event

    mysql> select e.title, sum(i.price) reversals from events e 
        -> inner join reversals r on r.event_id = e.id 
        -> inner join line_items li on li.reversal_id = r.id 
        -> inner join items i on i.id = li.item_id 
        -> group by e.title;
    +---------------------------------+-----------+
    | title                           | reversals |
    +---------------------------------+-----------+
    | Frühjahrsbörse Burgthann 2016   |      7.50 |
    | Herbstbörse Burgthann 2015      |     84.00 |
    | Testbörse 2017 Beta 3.0.0       |     10.00 |
    +---------------------------------+-----------+
    3 rows in set (0.01 sec)

Reversals, reversed items, reversed amount, average reversal amout per event

    mysql> select e.title, count(distinct r.id) reversals, 
        -> count(li.id) items, sum(i.price) amount, avg(i.price) average 
        -> from events e 
        -> inner join reversals r on r.event_id = e.id 
        -> inner join line_items li on li.reversal_id = r.id 
        -> inner join items i on i.id = li.item_id 
        -> group by e.title;
    +--------------------------------+-----------+-------+--------+-----------+
    | title                          | reversals | items | amount | average   |
    +--------------------------------+-----------+-------+--------+-----------+
    | Frühjahrsbörse Burgthann 2016  |         1 |     2 |   7.50 |  3.750000 |
    | Herbstbörse Burgthann 2015     |         6 |    13 |  84.00 |  6.461538 |
    | Testbörse 2017 Beta 3.0.0      |         1 |     1 |  10.00 | 10.000000 |
    +--------------------------------+-----------+-------+--------+-----------+
    3 rows in set (0.00 sec)


Lists with no sold items

    mysql> select e.id, count(distinct l.id) from events e left join lists l 
        -> on l.event_id = e.id where l.id 
        -> not in (select l.id id from lists l join items i 
        -> on i.list_ id = l.id join line_items li on li.item_id = i.id) 
        -> group by e.id;

Lists with revenue < 20 EUR

    mysql> select e.id, e.title, l.id lists from lists l inner join events e 
        -> on l.event_id = e.id join 
        -> (select l.id, sum(i.price) total from lists l join items i 
        ->  on i.list_id = l.id join line_items li 
        ->  on li.item_id = i.id and li.reversal_id is null group by l.id) x 
        -> on x.id = l.id and x.total < 20;
   

