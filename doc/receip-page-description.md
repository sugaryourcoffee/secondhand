Create a Receipt Page 
=====================

Up to now we hand out purchase receipts with the list of bought items, the
prices and a total amount. If a buyer wants to return items, she gets a return
receipt with the returned items, price per item and a total credit note. The
receipts are handed out on paper. The advantage is that the items have been
payed is visualized, when the buyer leaves the venue. The disadvantag is the
waste of paper.

The idea is to provided a means for the buyer to retrieve the receipt online by
providing the puchase number. A purchase is saved to the sellings table with a
selling number. From the secondhand organizer's point of view a buyer's purchase
is a selling.

From now on we take the view of the buyer and talk about purchase and purchase
number.

Buyer's workflow 
---------------- 

The buyer gets a note with the selling number and the price. With this note the
buyer approaches the cashier and pays the price shown on the note.

If the buyer wants to obtain the receipt online, she access the receipts page at
`secondhand.sugaryourcoffee.de/receipts`. There she can enter the purchase
number and can retrieve the receipt. 

The receipt is shown on the web page with the option of printing or exporting as
a _CVS_ file.

Design considerations 
---------------------

### View 

We need one web page with an input field for the purchase nummber, a view for
the receipt and two buttons. One button is for printing, the other one for
exporting the receipt as a csv file. 

The view should look something like the picture 

--------------------------------------------------------------------------------

Secondhand 

                Kinderkleider- und Spielzeug-Börse Burgthann Receipts 

                Purchase Number 
                ---------------------------------------
                |                                     |
                ---------------------------------------

                Receipt 
                
                Spring 2025

                Number  Description                      Size Price
                001/01  Trousers                         S     0.50
                004/13  Shirt                            M     1.00
                .
                .
                .
                121/37  Shoes                            39    5.00
                ---------------------------------------------------
                Total                                         25.50

                                                    CSV       PRINT

--------------------------------------------------------------------------------

At the beginning only the input field will be visible. When the purchase number
is entered and send the receipt will be displayed togehter with the butoons. If
no receipt exists for the purchase number provided a message will be displayed
_No receipt for this pruchase number_.

As this is just a view page, and it doesn't contain sensitive data, we don't
need to login.

### Model 

As stated previously we don't have a separate model for a receipt. We us the
existing _selling_ model. If it turns out we need a separate model, we will
re-evaluate the model.

### Controller 

We will have a controller with three actions. The action to view a receipt, the action to print and an action to download the receipt as a csv file.

Tests 
-----

### Without logged in I can access the page at .../receipt 

### Expect to have a input field _Receipt Number_ 

### With existing receipt number expect receipt being displayed 

### Expect receipt page has buton CSV and Print 

### With non-existing receipt number expect to see text 'Receipt does not exist'


