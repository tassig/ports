# How to install cups on Axiom

Run following commands as `root`

```sh
mount -o remount,rw /   # make sure rootfs is rw
. ./cups-all.sh
```

# How to use cups on Axiom

Cups provide web interface, which we can access at `127.0.0.1:631` form web browser.

To start cups service, run following command as `root`

```sh
/opt/cups/sbin/cupsd
```

This command will start cups daemon, with following default options, which we can checkk with `ps` command:

`/opt/cups/sbin/cupsd -C /opt/cups-2.2.6/etc/cups/cupsd.conf -s /opt/cups-2.2.6/etc/cups/cups-files.conf`


Open web browser and type `127.0.0.1:631` as url, and web interface will appear.

## Home Tab

Links to in-depth tutorials on how to use cups

## Adminstration

Here we have all administration options, for now it's "Add Printer" that is most interesting for us.

TODO: cups shall be able to discover network printers, add explanations...


### Example how to add network printer Canon MF410

First we need to know IP address of the network printer. It's not straightforward procedure to find it out, either it's a home printer where users knows it's IP, or it can be an office printer, so we have to ask office administrator.

TODO: Perhaps there is a bettere explanation on how to find out network printer IP.


Click `Add Printer`, choose `LPD/LPR Host or Printer` and click `Continue`

Under `Connection` , enter `lpd://hostname/queue` where `hostname` is network printer IP or it's configured netwoork name.In my case it was `lpd://192.168.15.100/queue`

Click `Continue`

Enter `Name` (has to be one word, no spaces allowed), `Description`, `Location` and click `Continue`

Under `Make` choose `Generic` and cliclk `Continue`

Under `Model` choose `Generic PCL laser printer` (other options may work with some issues, like "Generic IPP Everywhere Printer" printing test page in negative)

Click `Add Printer`


Under `Set Default Options for Canon_MF410` we can set Media Size to `A4`, or any other option we like, and click `Set Default Options`


## How to print a test page

Open `Printers` Tab and click on a choosen printer.

Under `Mainetenece` combo box, choose `Print Test Page`. We can check status under `Jobs` Tab.



TODO: How to setup cups with other applications, and hutches/


