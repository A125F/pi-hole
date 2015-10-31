#!/bin/bash
# Pi-hole automated install
# Raspberry Pi Ad-blocker
#
# Install with this command (from the Pi):
#
# curl -s "https://raw.githubusercontent.com/jacobsalmela/pi-hole/master/automated%20install/basic-install.sh" | bash
#
# Or run the commands below in order

clear
echo "  _____ _        _           _      "
echo " |  __ (_)      | |         | |     "
echo " | |__) |   __  | |__   ___ | | ___ "
echo " |  ___/ | |__| | '_ \ / _ \| |/ _ \ "
echo " | |   | |      | | | | (_) | |  __/ "
echo " |_|   |_|      |_| |_|\___/|_|\___| "
echo "                                    "
echo "      Raspberry Pi Ad-blocker       "
echo "									  "
echo "Set a static IP before running this!"
echo "			             			  "
echo "	    Press Enter when ready        "
echo "									  "
read

if [[ -f /etc/dnsmasq.d/adList.conf ]];then
	echo "Original Pi-hole detected.  Initiating sub space transport..."
	sudo mkdir -p /etc/pihole/original/
	sudo mv /etc/dnsmasq.d/adList.conf /etc/pihole/original/adList.conf.$(date "+%Y-%m-%d")
	sudo mv /etc/dnsmasq.conf /etc/pihole/original/dnsmasq.conf.$(date "+%Y-%m-%d")
	sudo mv /etc/resolv.conf /etc/pihole/original/resolv.conf.$(date "+%Y-%m-%d")
	sudo mv /etc/lighttpd/lighttpd.conf /etc/pihole/original/lighttpd.conf.$(date "+%Y-%m-%d")
	sudo mv /var/www/pihole/index.html /etc/pihole/original/index.html.$(date "+%Y-%m-%d")
	sudo mv /usr/local/bin/gravity.sh /etc/pihole/original/gravity.sh.$(date "+%Y-%m-%d")
else
	:
fi

echo "Updating the Pi..."
sudo apt-get update
sudo apt-get -y upgrade

echo "Installing tools..."
sudo apt-get -y install dnsutils
sudo apt-get -y install bc
sudo apt-get -y install toilet

echo "Installing DNS..."
sudo apt-get -y install dnsmasq
sudo update-rc.d dnsmasq enable

echo "Installing a Web server"
sudo apt-get -y install lighttpd php5-common php5-cgi php5
sudo mkdir /var/www/html
sudo chown www-data:www-data /var/www/html
sudo chmod 775 /var/www/html
sudo usermod -a -G www-data pi

echo "Stopping services to modify them..."
sudo service dnsmasq stop
sudo service lighttpd stop

echo "Backing up original config files and downloading Pi-hole ones..."
sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
sudo mv /etc/lighttpd/lighttpd.conf /etc/lighttpd/lighttpd.conf.orig
sudo mv /var/www/html/index.lighttpd.html /var/www/html/index.lighttpd.orig
sudo curl -o /etc/dnsmasq.conf "https://raw.githubusercontent.com/jacobsalmela/pi-hole/master/advanced/dnsmasq.conf"
sudo curl -o /etc/lighttpd/lighttpd.conf "https://raw.githubusercontent.com/jacobsalmela/pi-hole/master/advanced/lighttpd.conf"
sudo lighty-enable-mod fastcgi fastcgi-php
sudo mkdir /var/www/html/pihole
sudo curl -o /var/www/html/pihole/index.html "https://raw.githubusercontent.com/jacobsalmela/pi-hole/master/advanced/index.html"

echo "Installing the Web interface..."
sudo wget https://github.com/jacobsalmela/AdminLTE/archive/master.zip -O /var/www/master.zip
sudo unzip /var/www/master.zip -d /var/www/html/
sudo mv /var/www/html/AdminLTE-master /var/www/html/admin
sudo rm /var/www/master.zip 2>/dev/null
sudo touch /var/log/pihole.log
sudo chmod 644 /var/log/pihole.log
sudo chown dnsmasq:root /var/log/pihole.log

echo "Locating the Pi-hole..."
sudo curl -o /usr/local/bin/gravity.sh "https://raw.githubusercontent.com/jacobsalmela/pi-hole/master/gravity.sh"
sudo curl -o /usr/local/bin/chronometer.sh "https://raw.githubusercontent.com/jacobsalmela/pi-hole/master/advanced/Scripts/chronometer.sh"
sudo chmod 755 /usr/local/bin/gravity.sh
sudo chmod 755 /usr/local/bin/chronometer.sh

echo "Entering the event horizon..."
sudo /usr/local/bin/gravity.sh

echo "Restarting..."
sudo reboot