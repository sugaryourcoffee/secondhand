Secondhand Design Notes
=======================
This document describes thoughts on designing specific topics of the the 
*Secondhand* application. Though it doesn't describe everything, but things that
need some evaluation.

Web Pages
---------
The Secondhand application consists of web pages for different operations 
throughout a secondhand event. There are actually three states of a secondhand
event.

### Preparation
During the preparation phase the admin creates a new event, write a news page
and sends the news to users that have registered for news. Then the admin prints
the pick-up tickets. Following operations are conducted during the preparation
phase.

Operation | Page        | URL | Role | Model |  Menu 
--------- | ----------- | --- | ---- | ----- |  ----
Create new event | Event's index page | /events | admin | Event | Admin/Events
Create a news page with event details | News' index page | /news | admin | News | Admin/News
Send news to registered users that want to receive news | News' index page | /news | admin | News | Admin/News
Print pickup tickets | Event's show page | /events/id | admin | Event | Admin/Events

The next step is that the sellers can collect a pick up ticket and paper to 
print labels on (for a future version it might be usefull that sellers can 
apply at the Secondhand application).

### Collection
Now the sellers can sign-up or sign-in if the user has already an acount for 
the Secondhand application and register their lists with the registration code 
shown on the pick-up ticket. The seller can now collect the items they want to 
sell at the secondhand event.

Operation | Page | URL | Role | Model | Menu
--------- | ---- | --- | ---- | ----- | ----
Sign-up/Sign-in | Secondhand's index page | / | user | User | -
Register list | user's page | /users/id | user, admin | User | Account/My Lists
Collect items | user's list items page | /user/id/lists/id/items | user, admin | List, Item | Account/My Lists
Print list | user's page | /users/id | user, admin | User | Account/My Lists
Print labels | user's page | /user/id | user, admin | User | Account/My Lists
Close and submit list | user's page | /user/id | user, admin | User | Account/My Lists

To print the list is optional. The printed labels are now tagged to the items 
and placed in a container. On the day of delivery, that is a day before the
secondhand event the seller ships the container to the location of the
secondhand event.

### Acceptance
A day before the secondhand event takes place sellers are shipping their items
to the secondhand event location. Operators are accept the items and mark them
as delivered in the Secondhand applicaton.

Operation | Page | URL | Role | Model | Menu
--------- | ---- | --- | ---- | ----- | ----
Find the list by number | Acceptances page | /acceptances | operator, admin | List | Event/Acceptance
Add container color if it doesn't exist | List acceptance edit page | /acceptances/id/edit | operator, admin | List | Event/Acceptance
Edit or delete items | List acceptance edit page | /acceptances/id/edit | operator, admin | List | Event/Acceptance
Accept list | List acceptance edit page | /acceptances/id/edit | operator, admin | List | Event/Acceptance
Revoke acceptance | Acceptances page | /acceptances | admin | List | Event/Acceptance

### Sales
On the day of the secondhand event the customers are buying the items and 
operators are scanning the items. After the items have been scanned the customer
proceedes to the cashier and checks out.

Operation | Page | URL | Role | Model | Menu
--------- | ---- | --- | ---- | ----- | ----
Collect items | Cart page | /carts/item\_collection | operator, admin | Cart | Event/Cart
Check out | Cart page | /carts/item\_collection | operator, admin | Cart | Event/Cart

### Close
After the sales is closed the admin prints all lists showing sold items. These
lists are handed back with the onsold items of this list to the seller. The 
seller receives the list, the unsold items and the revenue upon check-out.

Operation | Page | URL | Role | Model | Menu
--------- | ---- | --- | ---- | ----- | ----
Print lists | Event show page | /events/id/ | admin | Event | Admin/Events

User Roles
----------
There are three user roles *user*, *operator* and *admin*. The *admin* has the
highest authorization and the *user* the least. 

The users can sign-up and sign-in, register lists, collect items into the list,
print the list and print the labels for the list's items. The user can also
deregister a list and send and close the list.

The operator can accept lists and collect sold items in a cart and check out
the cart. An operator also can redeem items and conduct check out. 

The admin is allowed to do all other operations except for editing the user's
account page. 

In the following table we describe which roles are allowed in the controllers. 

Controller                   | Role     | Actions
---------------------------- | -------- | -------
acceptances\_controller      | admin    | all
acceptances\_controller      | operator | all
acceptances\_controller      | user     | none
carts\_controller            | admin    | all
carts\_controller            | operator | all
carts\_controller            | user     | none
counter\_controller          | admin    | all
counter\_controller          | operator | all
counter\_controller          | user     | none
events\_controller           | admin    | all
events\_controller           | operator | none
events\_controller           | user     | none
items\_controller            | admin    | all
items\_controller            | operator | all
items\_controller            | user     | all
line\_items\_controller      | admin    | all
line\_items\_controller      | operator | all
line\_items\_controller      | user     | none
lists\_controller            | admin    | all
lists\_controller            | operator | all
lists\_controller            | user     | print\_list, print\_labels, send\_list
news\_controller             | admin    | all
news\_controller             | operator | none
news\_controller             | user     | none
password\_resets\_controller | admin    | all
password\_resets\_controller | operator | all
password\_resets\_controller | user     | all
reversals\_controller        | admin    | all
reversals\_controller        | operator | index, create, show, check\_out, print
reversals\_controller        | user     | none
sellings\_controller         | admin    | all
sellings\_controller         | operator | index, create, show, check\_out, print
sellings\_controller         | user     | none
sessions\_controller         | admin    | all
sessions\_controller         | operator | all
sessions\_controller         | user     | all
static\_pages\_controller    | admin    | all
static\_pages\_controller    | operator | all
static\_pages\_controller    | user     | all
users\_controller            | admin    | all
users\_controller            | operator | show
users\_controller            | user     | new, create, edit, update, show, register\_list, deregister\_list, print\_address\_labels

Menu
----
On the top of the Secondhand application is the menu bar. The menue items shown
depend on the users role. In the following table is shown which menue items are
available for which user role.

Menu                       | User | Operator | Admin
-------------------------- | ---- | -------- | -----
Language (English/Deutsch) | yes  | yes      | yes
Home                       | yes  | yes      | yes
Help                       | yes  | yes      | yes
Event                      | no   | yes      | yes
Admin                      | no   | no       | yes
Account                    | yes  | yes      | yes

