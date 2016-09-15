Fail over MySQL and Rails
========================
We have two machines with each having a MySQL server and the Rails application
running Secondhand. One of the servers is the master with IP address 
192.168.178.61 the other is the slave with the IP address 192.168.178.66. 
The master database will be mirrored to the slave database.
In case our master is crashing we want to switch over to the slave server. 

In order to implement such configuration we have to conduct following step 
assuming we have both servers running with MySQL and Secondhand

* Configure the master server
  * Set the MySQL server ID on the master server
  * Set the log file on the MySQL master server
  * Bind the IP address on the master that is visible to the slave server
  * Restart the server
  * Set permission on MySQL master to give the MySQL slave access
* Create and copy the current master database dump to the slave server
* Configure the slave
  * Check the connection from the slave to the master database
  * On the MySQL slave set the server ID and bind address
  * Configure the master server
* Restore the master database on the MySQL slave
* Start replication on the MySQL slave

Configure the MySQL server
--------------------------
On the MySQL server we have to set the server ID and the log file. We do that
in `/etc/mysql/my.cnf` by uncommenting these two lines

    server-id = 1
    log_bin   = /var/log/mysql/mysql-bin.log

We also have to make the database available to machines other than local host.
We do that by changing the `bind-address = 172.0.0.1` to the address of the
master server

    bind-address = 192.168.178.61

After changing the configuration we have to restart the server

    $ sudo service mysql restart

We can check up on the replication with

    $ mysql -uroot -p
    mysql> show master status;

Next we create a replication user that is restricted to the rights needed for
replication

    mysql> create user 'repl'@'%' identified by 'slavepass';
    mysql> grant replication slave on *.* to 'repl'@'%';

Copy master database to the slave database
------------------------------------------
We dump the production database and then copy the dump file from the master to
the slave server. On the slave server we restore the dump file into the slave
database.

    development$ ssh mercury
    mercury$ mysqldump -uroot -p --quick --single-transaction --triggers \
      --master-data secondhand_production | gzip > secondhand-repl.sql.gz
    mercury$ scp secondhand-repl.sql.gz user@uranus:secondhand-repl.sql.gz
    mercury$ exit

Configure the MySQL slave
-------------------------
We first check that we can access the master from the slave server.

    development$ ssh uranus
    uranus$ mysql -urepl -pslavepass -h192.168.178.61 --port 3306 \
    -e "show databases"

This should list the databases on the server.

The configuration on the slave is similar. We first edit the `/etc/mysql/my.cnf`
by setting the *server-id* and the *bind-address* of the slave

    uranus$ sudo vi /etc/mysql/my.cnf

We adjust my.cnf to

    server-id = 2
    bind-address = 192.168.178.66

The server-id has to be unique. We just increment for each slave the IP address.
Our master has the server-id 1 and our slave 2. If we add additional slaves we
just increment each slave's server-id by 1.

After the configuration we have to restart the server in order the changes take
effect

    uranus$ sudo service mysql restart

Now in MySQL we tell the slave where to find the master server and with which
user to connect

    uranus$ mysql -uroot -p
    mysql> change master to
        -> master_host='192.168.178.61',
        -> master_user='repl',
        -> master_password='slavepass';
    mysql> exit

Note: If your MySQL server or your slave gets a new IP address you have to 
adjust the `bind-address` in **/etc/mysql/my.conf** and in **mysql** 
accordingly.

Restore database on slave server
--------------------------------
We now restore the previously dumped database from the server on the slave. This
will include the log file name and log file position.

    development$ ssh uranus

Before we restore the database we have to create the database where we want to
restore it to

    uranus$ mysql -uroot -p
    mysql> create database secondhand_production default character set utf8;
    mysql> grant all privileges to 'pierre'@'localhost' identified by 'secret';
    mysql> exit

Now we restore the database into secondhand\_production

    uranus$ gunzip < secondhand-repl.sql.gz | mysql -uroot -p \
    secondhand_production

Start replication
-----------------
On the slave server uranus we start the replication

    uranus$ mysql -uroot -p
    mysql> start slave;

We can check the slave status with

    mysql> show slave status\G;

Adding additional slaves
------------------------
If we want to have additional slaves for replicating the master database then we
just follow the steps above, that is

On the master server

* dump the master database and copy it to the new slave server

On the slave server

* set `server-id` to a unique positive integer and set the bind-address to the
  slave server's IP address. Both is done in /etc/mysql/my.cnf 
* restart the MySQL server
* configure the master server in mysql
* create the database in MySQL
* restore the dumped database into MySQL
* start the replication

Sources
-------
* [MySQL replication - YouTube](https://www.youtube.com/watch?v=JXDuVypcHNA)
* [High Performance MySQL - O'Reilly](http://shop.oreilly.com/product/0636920022343.do)
* [Deploying Rails Applications - Pragmatic Programmer](https://pragprog.com/book/cbdepra/deploying-rails)

