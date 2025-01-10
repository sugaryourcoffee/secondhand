Reset the _MySQL_ root password 
===============================

If the access to _MySQL_ is not granted because I lost the password then there is a way to reset it. A detailed description can be found at [Reset Your MySQL Root Password like a Pro](https://thelinuxcode.com/change-mysql-password-ubuntu-22-04/). 

    $ mysql -uroot -p
    Enter password:
    ERROR 1698 (28000): Access denied for user 'root'@'localhost'

Following I describe the essential steps, that area

1. Ensure _MySQL_ version is >= 8
2. Stop the _MySQL_ service 
3. Start _MySQL_ without _Grant Tables_ 
4. Login to _MySQL_ 
5. Reset the Password 
6. Restart _MySQL_ 
7. Login as root with new Password 

1. Ensure _MySQL_ version is >= 8
---------------------------------

This method only works with a _MySQL_ version >= 8. The _MySQL_ version can be checked with 

    $ mysql --version 
    mysql  Ver 8.0.40-0ubuntu0.24.04.1 for Linux on x86_64 ((Ubuntu))

2. Stop the _MySQL_ service 
---------------------------

To stop the _MySQL_ service we use `sudo systemctl stop mysql.service`. And check if it is down `sudo systemctl status mysql.service`

    ○ mysql.service - MySQL Community Server
         Loaded: loaded (/usr/lib/systemd/system/mysql.service; enabled; preset: enabled)
         Active: inactive (dead) since Fri 2025-01-10 21:25:09 UTC; 1min 35s ago
       Duration: 3w 1d 1h 40min 51.334s
        Process: 1253 ExecStart=/usr/sbin/mysqld (code=exited, status=0/SUCCESS)
       Main PID: 1253 (code=exited, status=0/SUCCESS)
         Status: "Server shutdown complete"
            CPU: 2h 54min 25.275s
    
    Dec 19 19:44:02 uranus systemd[1]: Starting mysql.service - MySQL Community Server...
    Dec 19 19:44:17 uranus systemd[1]: Started mysql.service - MySQL Community Server.
    Jan 10 21:25:08 uranus systemd[1]: Stopping mysql.service - MySQL Community Server...
    Jan 10 21:25:09 uranus systemd[1]: mysql.service: Deactivated successfully.
    Jan 10 21:25:09 uranus systemd[1]: Stopped mysql.service - MySQL Community Server.
    Jan 10 21:25:09 uranus systemd[1]: mysql.service: Consumed 2h 54min 25.275s CPU time, 442.3M memory peak, 0B memory swap peak.

It tells me "Server shutdown complete".

3. Start _MySQL_ without _Grant Tables_ 
---------------------------------------

We tell the service to not use _grant-tables_ with `sudo systemctl set-environment MYSQLD_OPTS="--skip-grant-tables"` and start the service again with `sudo systemctl start mysql.service`. And we check that the service is running with `sudo systemctl status mysql.service`

    $ sudo systemctl status mysql.service
    ● mysql.service - MySQL Community Server
         Loaded: loaded (/usr/lib/systemd/system/mysql.service; enabled; preset: enabled)
         Active: active (running) since Fri 2025-01-10 21:31:16 UTC; 5s ago
        Process: 619372 ExecStartPre=/usr/share/mysql/mysql-systemd-start pre (code=exited, status=0/SUCCESS)
       Main PID: 619380 (mysqld)
         Status: "Server is operational"
          Tasks: 38 (limit: 9390)
         Memory: 367.3M (peak: 382.2M)
            CPU: 991ms
         CGroup: /system.slice/mysql.service
                 └─619380 /usr/sbin/mysqld
    
    Jan 10 21:31:13 uranus systemd[1]: Starting mysql.service - MySQL Community Server...
    Jan 10 21:31:16 uranus systemd[1]: Started mysql.service - MySQL Community Server.

4. Login to _MySQL_ 
-------------------

Now the interesting part logging into _MySQL_ with `sudo mysql -uroot`

    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 8
    Server version: 8.0.40-0ubuntu0.24.04.1 (Ubuntu)
    
    Copyright (c) 2000, 2024, Oracle and/or its affiliates.
    
    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.
    
    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

It worked! We are back in!

5. Reset the Password 
---------------------

To reset the password we do in _MySQL_ console `ALTER USER ‘root‘@‘localhost‘ IDENTIFIED BY ‘password‘;` and we get the feedbacks

    Query OK, 0 rows affected (0.04 sec)
    
and finally exit out of the _MySQL_ console 

    mysql> exit 
    Bye

6. Restart _MySQL_ 
------------------

We now are restarting _MySQL_ normally by unsetting the option `skip-grant-tables` with `sudo systemctl unset-environment MYSQL_OPTS` and then restart with `sudo systemctl restart mysql.service`. Final check that the server is up a gain

    ● mysql.service - MySQL Community Server
         Loaded: loaded (/usr/lib/systemd/system/mysql.service; enabled; preset: enabled)
         Active: active (running) since Fri 2025-01-10 21:44:51 UTC; 15s ago
        Process: 619991 ExecStartPre=/usr/share/mysql/mysql-systemd-start pre (code=exited, status=0/SUCCESS)
       Main PID: 620001 (mysqld)
         Status: "Server is operational"
          Tasks: 38 (limit: 9390)
         Memory: 367.1M (peak: 382.1M)
            CPU: 1.051s
         CGroup: /system.slice/mysql.service
                 └─620001 /usr/sbin/mysqld
    
    Jan 10 21:44:48 uranus systemd[1]: Starting mysql.service - MySQL Community Server...
    Jan 10 21:44:51 uranus systemd[1]: Started mysql.service - MySQL Community Server.

7. Login as root with new Password 
----------------------------------

Now we log in with the new passwords

    $ sudo mysql -u root -p
    Enter password:
    Welcome to the MySQL monitor.  Commands end with ; or \g.
    Your MySQL connection id is 8
    Server version: 8.0.40-0ubuntu0.24.04.1 (Ubuntu)
    
    Copyright (c) 2000, 2024, Oracle and/or its affiliates.
    
    Oracle is a registered trademark of Oracle Corporation and/or its
    affiliates. Other names may be trademarks of their respective
    owners.
    
    Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
    
    mysql>

Final Remark 
------------

Thanks to [TheLinuxCode](https://thelinuxcode.com)
