Setting up CUPS on Ubuntu Server
================================
Secondhand prints receipts on check out to a network printer. In order to 
accomplish this we have to install CUPS (Common Unix Print System) and the
appropriate driver for the printer to use. What we will do is

* install CUPS
* install the printer driver
* test the printer
* get to know command line programs to manage print jobs
* call the printer from within the secondhand application

In the following the server where we install CUPS is *uranus* with the IP 
address *192.168.178.66*.

Install CUPS
------------
CUPS can be installed from the repositories with

    $ sudo apt-get install cups

After CUPS has been installed we can do the configuration.

Configure CUPS
--------------
The configuration of CUPS takes place in `/etc/cups/cupsd.conf`. We want to
keep the original configuration file and so we copy it to 
`/etc/cups/cupsd.conf.original`

    $ sudo cp /etc/cups/cupsd.conf /etc/cups/cupsd.conf.original

Now we make following changes in `/etc/cups/cupsd.conf`

* set the e-mail address of the server admin to send messages to
* make CUPS listen on request from the network

Add the e-mail address of the server admin in `/etc/cups/cupsd.conf`

    ServerAdmin webmaster@sugaryourcoffee.de

In order e-mails can be sent you have to setup Postfix. An instruction how to
setup Postfix can be found in [Setup Postfix](postfix.md).

Now we want CUPS not only listen on the localhost interface but also on the
public interface of the machine where CUPS is installed. To do so add following 
to the `/etc/cups/cupsd.conf` configuration file

    Listen 192.168.178.66:631

Note: When the IP changes you have to adjust the IP-address in the configuration
file.

We also want to have access to the CUPS web interface from all machines within
the local network to be able to conduct administration tasks on the CUPS server.
We make following additions to `/etc/cups/cupsd.conf` in the 
*Web interface settings* and add after each `Order allow,deny` directive 
`Allow from 192.168.178.0/24`.

    # Web interface setting...
    WebInterface Yes

    # Restrict access to the server...
    <Location />
      Order allow,deny
      Allow from 192.168.178.0/24
    </Location>

    # Restrict access to the admin pages...
    <Location /admin>
      Order allow,deny
      Allow from 192.168.178.0/24
    </Location>

    # Restrict access to configuration files...
    <Location /admin/conf>
      AuthType Default
      Require user @SYSTEM
      Order allow,deny
      Allow from 192.168.178.0/24
    </Location>

This will give access from all machines that are within the subnet `192.168.178`
on the local area network.

To make the changes take effect we have to restart the CUPS server with

    $ sudo service cups restart

Now head over to your browser and enter `uranus:631` and you should see the
CUPS web interface.

Install a Printer
-----------------
In the CUPS web interface click the *Administration* tab and click the button
*Add Printer*. You have to provide your user name and password which is the same
as you use to login to your machine where CUPS is installed. That user also has
to be in the user group *lpadmin*. Now you are forwarded to the *Add Printer* 
page. Select the printer you want to add and press the *Continue* button. Now 
add the name, description and location, select whether you want to share this 
printer, that is other machines can see the printer in their printer selection 
without installing the printer on their machine. To proceed press the *Continue*
Button. Now select the model of your printer. By selecting a model the 
corresponding printer driver will be installed. If you don't find the printer 
driver search the web for the printer driver. The printer driver usually comes 
in a zipped file. Unpack the zip file and select the *Browse...* button in the 
CUPS web interface. Navigate to the directory where you unpacked the drivers and
select the appropriate *PPD* file for your printer. In my case it is a *Canon 
LPB6650dn*. The driver is not available in the *Model* select box. So I have to 
download the driver from the Internet at [Canon Drivers](http://www.canon-europe.com/support/consumer_products/products/printers/laser/i-sensys_lbp6650dn.aspx?type=drivers&driverdetailid=tcm:13-1293638&os=Linux%20%2864-bit%29&language=EN). 
When downloaded to my local machine I copy it to the CUPS server machine.

    saltspring$ scp o1581en_linux_UFRII_v300.zip \
    > pierre@uranus:linux_UFRII_v300.zip

The driver comes as a zip-file. To unzip the file you need to install the 
`unzip` program.

    uranus$ sudo apt-get install unzip

Now unzip the drivers file

    uranus$ unzip linux_UFRII_v300.zip

This will create a directory. Change the directory to a name that indicates the
content.

    uranus$ mv eng_uk canon-ufr-II-v300-en

Then change to the directory and find the `install.sh` file. The file needs to
have execute rights.

    uranus$ chmod 774 install.sh

Now start the installation with

    uranus$ sudo ./install.sh

When installed go back to the CUPS web interface and go back one page and 
press the *continue* button to load the new drivers. Now navigate to the 
appropriate driver in the select box and select it and press the *Add Printer* 
button.

You will be forwarded to a page where you can configure the printer settings.
Finally check whether you can print. Select the tab "Printers" and within the
*Printers* page select the newly installed printer. Click the *maintenance* dro
down menu and select *Print test page*. If everything is correctly installed the
printer should print the test page.

Using the Command Line to Manage the Printer
--------------------------------------------
There are several command line programs we can manage the printer with.

* lpstat
* lpr

To see the available printers you can use `lpstat -a`

    uranus$ lpstat -a
    Canon_LBP6650 accepting requests since Thu 03 Sep 2015 11:55:45 AM CEST

To print from the command line or from within a program we can use the `lpr`
command which can be installed with 

    uranus$ sudo apt-get install cups-bsd

To actually print a file we can do so with

    uranus$ lpr file-to-print

If it prints an error saying `lpr: Error - no default destination available.` it
means that you ether have to specify the printer that you want to print to or to
set a default printer.

To specify a printer enter

    uranus$ lpr -P printer file-to-print

To set a default printer go to the CUPS web interface and in the page where you
can manage the printer click the *Administration* drop down menu and select
*Set as Server default*. If you want to print from within an application it is
best to select a default printer.

Print from within Rails Applications
------------------------------------
To print from within a Rails application we can do so with a *system* call in
the controller. In this case we are in the 
`app/controllers/sellings_controller.rb` with a *print* route set in 
`config/routes.rb`.

The action in `app/controllers/sellings_controller.rb` looks like this.

    def print
        @selling = Selling.find(params[:id])
        respond_to do |format|
          if system('lpr', @selling.to_pdf.to_path)
            format.html { redirect_to :back,
                          notice: "Successfully printed selling #{@selling.id}" 
                        }
          else
            format.html { redirect_to :back,
                          alert: "Could not print selling #{@selling.id}" }
          end
        end
      end

The corresponding route in `config/routes.rb` looks like this.

      resources :sellings do
        member do
          get :print
        end
      end

Trouble Shooting
----------------
If your file doesn't get printed you can look at the log files at
`/var/log/cups/`.

Resources
---------
More detailed information can be found in following book and website

* [The Linux Command Line]() from William E. Schotts, Jr.
* [CUPS Website](https://www.cups.org/documentation.php)
* [CUPS Wiki on Ubuntu Users](https://wiki.ubuntuusers.de/cups) in German

and if you have installed CUPS on your laptop you can view the web site at

* [localhost:631](http://localhost:631)

