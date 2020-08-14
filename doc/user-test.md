# User Test Document
This document provides a checklist to test the application from a user 
perspective. The tasks conducted in a typical workflow are listed

The tests are conducted first on the Beta server by at least 1 person and
after a successful test without issues the test is run on the Staging server
with more persons in parallel to simulate load on the server.

# Preparation
During the tests the log-files on the server are monitored to see whether any
errors occur during operating the application. To do so follow the steps

    $ ssh uranus
    $ cd /var/www/<application>/current
    $ tail -f log/<stage-name>.log

## Beta
Start the log monitoring

    $ ssh uranus
    $ cs /var/www/secondhand-beta/current
    $ tail -f log/beta.log

### Admin...
* creates a new event
* prints pick-up tickets that are issued to sellers

### Seller...
* registers at the secondhand website
* registers three lists with the registration codes provided
* enters the items to sell into one of the lists
    * Manually
    * CSV import (test files located at doc/user-test-files)
    * Lists from previous events
* marks lists with line items as finished and sends them to Admin
* prints address labels
* prints list
* prints barcode labels
* releases the third list
* (virtually) ships items to sell to the secondhand event location

### Operator...
#### in scenario 1...
* enters manually a list number in the acceptance overview
* accepts in the acceptance dialog the list
#### in scenario 2...
* scans another list with a barcode scanner in the acceptance overview
* accepts in the acceptance dialog the list

### Buyer...
* (virtually) goes to the counter

### Operator...
* scans the sold items
* deletes a scanned items
* closes the sales (scan) process

### Buyer...
* (virtually) proceedes to the cashier and checks out
* wants to return a bought item

### Operator...
* redeems the item

### Admin...
* prints after the event the lists for payback

## Staging
