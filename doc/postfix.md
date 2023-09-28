Install and setup Postfix
=========================
To send email from apptrack we need to install a mail transfer agent (MTA). On
Ubuntu the application at hand ist Postfix. This document describes how to 
install and setup Postfix to be used from a Rails application.

* Install Postfix
* Configure Postfix

Instal Postfix
--------------
First check if Postfix is installed

    $ dpkg -s postfix

If it is not installed first update your system and type

    $ sudo apt-get update
    $ sudo apt-get upgrade
    $ sudo apt-get install postfix

Postfix will ask you some questions to configure Postfix appropriately to your
use case. Before we start some hints.

At some point of the installation/configuration process you will be asked how 
to forward the emails.

| Type                    | Description                                        |
| ----------------------- | ---------------------------------------------------|
| Internet                |In this case you will need a public internet address|
| Intenet with smart host |relay email over your ISP                           |
| Sattlite                |Only for outgoing email                             |
| Local                   |Send emails only within LAN                         |

In our case we want to use internet with *smart host*.

Next question is about your system mail name. For that use the name of your
machine which is probably pre-selected in the input field.

Now you have to provide your SMTP relay host. This now depends on your ISP. If
your ISP is 1und1 add *smtp.1und1.de:587*. Port 587 is used for TLS encryption.

After you hit <ok> Postfix will get installed and you will see a lot of output.
The intersting parts are explained below.

If you find a line saying `mailname is not a fully qualified domain name. Not 
  changing /etc/mailname.` then you can add a mail name to /etc/mailname.
      
If you find a line saying `WARNING: /etc/aliases exists, but does not have a 
  root alias.` Then you can add a directive to forward emails for root to a 
  specific email address `root: web@your-domain.com`

After installation you will get following information

    Postfix is now set up with a default configuration.  If you need to make
    changes, edit /etc/postfix/main.cf (and others) as needed.

    After modifying main.cf, be sure to run '/etc/init.d/postfix reload' or run
    'systemctl reload postfix'

Configure Postfix
-----------------
Now open */etc/postfix/main.cf* and add following lines

    smtp_sasl_auth_enable = yes
    smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
    smtp_sasl_security_options = noanonymous

Next create * sudo vi /etc/postfix/sasl\_passwd* and add your credentials

    smtp.1und1.de web@sugaryourcoffee.de:my-very-secret-password

One last step is to convert the passord file to the Postfix database format

    sudo postmap /etc/postfix/sasl_passwd

Finally start reload Postfix configuration

    /etc/init.d/postfix reload or systemctl reload postfix

To send e-mail from the command line install *mail-utils*

    sudo apt-get install mail-utils

This is the time to send your first email.

    mail -a From:web@sugaryourcoffee.de -s "My first e-mail" info@example.com

If you don't receive emails then check the */var/log/mail.log* and */var/log/mail.err*. Or just issue the 'mail' command and see whether your mail has been rejected.

You could also leave off the *From* e-mail address and configure the sender gets automatically mapped to the right address. Standard bevaviour is that the sener e-mail address is created out of the user name and the computer name. If the user is pierre and the computer name is uranus, then the sender name will map to *pierre@uranus*. This will rejected from the ISP. To map the sender e-mail address add following to /etc/postfix/main.cf

    smtp-generic-maps = hash:/etc/postfix/generic

Then add the mapping to /etc/postfix/generic

    pierre@uranus web@sugaryourcoffee.de

Create the database entry with

    postmap /etc/postfix/generic

and run 'systemctl reload postfix'. Now you can send the e-mail with

    mail -s "message from uranus" me@example.com.

Sources
-------
[Ubuntu postfix installation](https://help.ubuntu.com/lts/serverguide/postfix.html)

