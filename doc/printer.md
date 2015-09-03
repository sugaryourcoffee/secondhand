Setting up CUPS on Ubuntu Server
================================
Secondhand prints receipts on check out to a network printer. In order to 
accomplish this we have to install CUPS (common Unix Print Server) and the
appropriate driver for the printer to use. What we will do is

* install CUPS
* install the printer driver
* test the printer
* get to know command line programs to manage print jobs
* call the printer from within the secondhand application

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

To make the the changes take effect we have to restart the CUPS server with

    $ sudo service cups restart

Now head over to your browser and enter `uranus:631` and you should see the
CUPS web interface.

Install a Printer
-----------------
In the CUPS web interface click the *Administration* tab and click the button
*Add Printer*. You have to provide your username and password which is the same
as you use to login to your machine where CUPS is installed. Now you are 
forwarded to the *Add Printer* page. Select the printer you want to add and 
press the *Continue* button. Now add the name, description and location, select
whether you want to share this printer, that is other machines can see the 
printer in their printer selection without installing the printer on their 
machine. To proceed press the *Continue* Button. Now select the model of your
printer. By selecting a model the corresponding printer driver will be
installed. If you don't find the printer driver search the web for the prnter
driver. The printer driver usually comes in a zipped file. Unpack the zip file
and and select the *Browse...* button in the CUPS web interface. Navigate to
the directory where you unpacked the drivers and select the appropriate *PPD* 
file for your printer. In my case it is a *Canon LPB6650dn*. The driver is not
available in the *Model* select box. So I have to download the driver from the
Internet at [Canon Drivers](http://www.canon-europe.com/support/consumer_products/products/printers/laser/i-sensys_lbp6650dn.aspx?type=drivers&driverdetailid=tcm:13-1293638&os=Linux%20%2864-bit%29&language=EN).
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

Then change to the directory and find the *deb* package for your machine, that
is 32 or 64 bit. Now install the debian packages with *dpkg*.

    uranus$ sudo dpkg -i cndrvcups-common_3.10-1_amd64.deb

You might get an error about missing dependencies. Then install the missing
dependencies with

    uranus$ sudo apt-get install -f

Then finish the installation of the commons package with

    uranus$ sudo dpkg -i cndrvcups-common_3.10-1_amd64.deb

Next you need to install the *urf2* package

    uranus$ sudo dpkg -i cndrvcups-ufr2-uk_3.00-1_amd64.deb

And again if you get an error about missig dependencies proceede as with the
installation of the *commons* package above.

When installed go back to the CUPS web interface and go back one page and 
press the *continue* button to load the new drivers. Now navigate to the 
appropriate driver in the select box and select it and press the *Add Printer* 
button.

You will be forwarded to a page where you can configure the printer settings.
Finally check whether you can print. Select the tab "Printers" and within the
*Printers* page select the newly installed printer. Click the drop down menu
and select *Print test page*. If everything is correctly installed the printer
should print the test page.

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
means that you have eather specify the printer that you want to print to or to
set a default printer.

To specify a printer enter

    uranus$ lpr -P printer file-to-print

To set a default printer go to the CUPS web interface and in the page where you
can manage the printer click the *Administration* drop down menue and select
*Set as Server default*. If you want to print from within an application it is
best to select a default printer.

Print from within Rails Applications
------------------------------------
To print from within an Rails application we can do so with a *system* call in
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
          get :check_out
          get :print
        end
      end

Trouble Shooting
----------------
If you file doesn't get printed you can look at the log files at
`/var/log/cups/`.

Resources
---------
More detailed information can be found in following book and website

* [The Linux Command Line]() from Williar E. Schotts, Jr.
* [CUPS Website](https://www.cups.org/documentation.php)

and if you have installed CUPS on your laptop you can view the web site at

* [localhost:631](localhost:631)

