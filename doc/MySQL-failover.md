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
  * Add user and set permission on MySQL master to give the MySQL slave access
* Create and copy the current master database dump to the slave server
* Configure the slave
  * Check the connection from the slave to the master database
  * On the MySQL slave set the server ID and bind address
  * Configure the master server
  * Add same user on slave with access rights for master replication
* Restore the master database on the MySQL slave
* Start replication on the MySQL slave

Configure the MySQL server
--------------------------
Log into the MySQL master server

    development$ ssh mercury

On the MySQL server we have to set the server ID and the log file. We do that
in `/etc/mysql/my.cnf` by uncommenting these two lines

    server-id = 1
    log_bin   = /var/log/mysql/mysql-bin.log

We also have to make the database available to machines other than local host.
We do that by changing the `bind-address = 172.0.0.1` to the address of the
master server

    bind-address = 192.168.178.61

After changing the configuration we have to restart the server

    mercury$ sudo service mysql restart

We can check up on the replication with

    mercury$ mysql -uroot -p
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

Add the replication user also on the slave with the same credentials

    mysql> create user 'repl'@'%' identified by 'slavepass';
    mysql> exit

Note: If your MySQL server or your slave gets a new IP address you have to 
adjust the `bind-address` in **/etc/mysql/my.conf** and in **mysql** 
accordingly.

Otherwise you will get an error if you call the secondhand web page *something went wrong*. 
The error in log/production.log is:

`Mysql2::Error (Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (2))`

And if you start MySQL from the command line with `$ mysql` you will get the same error with slightly different text:

`ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (2)`

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

Error Messages
--------------
If you get an error message saying

    Mysql2::Error (Can't connect to local MySQL server through socket 
    '/var/run/mysqld/mysqld.sock' (2)):

Then you probably have the wrong IP address in you MySQL slave server. Check 
that the IP address in /etc/mysql/my.conf is the IP address of the slave server
itself.

Changing IP address might happen when you retrieve your IP address from a new
DHCP server.

### Fatal Error 1236
The master and slave might get out of sync if the slave is shut down for a
while or the connection is interrupted. As long as the `Master_Log_File` value
on the slave is still available on the master the slave will catch up the
master. If the `Master_Log_File` is overridden then `show slave status\G`
will have the value `Last_IO_Errno: 1236` and the `Last_IO_Error: Got fatal
error 1236 from master when reading data from binary log: 'Could not find first log file name in binary log index file'`. It might help to reset the
slave with 

    mysql> stop slave;
    mysql> reset slave;
    mysql> start slave;
    mysql> show slave status\G;

If the error is gone. The slave might be gradually synced with the master. If
data is not propperly synced then dump the database on the server and restore
it on the slave as shown [Copy master database to the slave database](#copy-master-database-to-the-slave-database) and in [Restore database on slave server](#restore-database-on-slave-server).

### Last_SQL_Errno: 1133
The error message
    Last_SQL_Error: Error 'Can't find any matching row in the user table' on 
    query. Detault database: ''. Query: 'SET PASSWORD FOR 'repl'@'%'='*....''

indicates that on the slave machine the user 'repl'@'%' is not set. The repl 
user needs to be set on each of the machines that are part of the replication.

### Could not initialize master info structure 

If the following error message is raised while recovering the database to the backup server 

    gunzip < secondhand-repl.sql.gz | mysql -uroot -p secondhand_production
    Enter password:
    ERROR 1201 (HY000) at line 22: Could not initialize master info structure; more error messages can be found in the MySQL error log
    pierre@jupiter:~$ gunzip < secondhand-repl.sql.gz | mysql -uroot -p secondhand_production
    Enter password:
    ERROR 1201 (HY000) at line 22: Could not initialize master info structure; more error messages can be found in the MySQL error log

This can be solved by **resetting the slave**

    $ mysql -uroot -p
    Enter password:
    mysql> use secondhand_production;
    Reading table information for completion of table and column names
    You can turn off this feature to get a quicker startup with -A
    Database changed
    mysql> reset slave;
    Query OK, 0 rows affected (0.28 sec)
    mysql> exit
    Bye

The we repeat the command to recover the database to the backup server database 

    $ gunzip < secondhand-repl.sql.gz | mysql -uroot -p secondhand_production
    Enter password:
    mysql> use secondhand_production;
    Reading table information for completion of table and column names
    You can turn off this feature to get a quicker startup with -A
    Database changed
    mysql> start slave;
    Query OK, 0 rows affected (0.00 sec)
    mysql> exit 
    Bye

Sources
-------
* [MySQL replication - YouTube](https://www.youtube.com/watch?v=JXDuVypcHNA)
* [High Performance MySQL - O'Reilly](http://shop.oreilly.com/product/0636920022343.do)
* [Deploying Rails Applications - Pragmatic Programmer](https://pragprog.com/book/cbdepra/deploying-rails)

