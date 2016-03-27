Failover MySQL and Rails
========================
We have two machines with each having a MySQL server and the Rails application
running Secondhand. One of the servers is the master the other is the slave. 
The master database will be mirrored to the slave database.
In case our master is crashing we want to switch over to the slave server. 

In order to implement such configuration we have to conduct following step 
assuming we have both servers running with MySQL and Secondhand

* Copy the current master database to the slave server
* Configure the master server
  * Set the MySQL server ID on the master server
  * Set the log file on the MySQL master server
  * Bind the IP address on the master that is visible to the slave server
  * Restart the server
  * Set permission on MySQL master to give the MySQL slave access
  * Block write attempts and determine the position of MySQL master
* Configure the slave
  * Check the connection from the slave to the master database
  * On the MySQL slave set the server ID, bind address and log file
  * On the MySQL slave we set master IP address, the user and log position
  * Start replication on the MySQL slave

Copy master database to the slave database
------------------------------------------
We dump the production database and then copy the dump file from the master to
the slave server. On the slave server we restore the dump file into the slave
database.

    development$ ssh mercury
    mercury$ mysqldump -uroot -p --quick --single-transaction --triggers \
      secondhand_production | gzip > secondhand.sql.gz
    mercury$ scp secondhand.sql.gz user@uranus:secondhand.sql.gz
    mercury$ exit
    development$ ssh uranus
    uranus$ gunzip < secondhand.sql.gz | mysql -uroot - secondhand_staging

Configure the MySQL server
--------------------------
On the MySQL server we have to set the server ID and the log file. We do that
in `/etc/mysql/my.cnf` by uncommenting these two lines

    server-id = 1
    log_bin   = /var/log/mysql/mysql-bin.log

We also have to make the database available to machines other than local host.
We do that by changing the `bind-address = 172.0.0.1` to

    bind-address = 0.0.0.0

This configuration accepts connections on all IPv4 host interfaces. We could
also explicitly set the IP address that we want to bind the server to.

After changing the configuration we have to restart the server

    $ sudo service mysql restart

Configure the MySQL slave
-------------------------

