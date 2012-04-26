#Autopache - automatically setup a vhost for you, right here
# Syntax: autopache.sh yourlocaldomain.local
# Parameter 2:
#  --delete - deletes the vhost
#  --open - opens in browser 
#!/bin/bash
echo "Autopache, version 0.1. Author: Dan Dart. License: Public Domain (or equivalent)"
if [ "0" -ne "$UID" ]
then
	echo "This program must be run as root (as it requires permissions to edit apache, hosts & restart apache)"
	exit 1
fi

SITENAME=$1
if [ -z "$1" ]
then
	echo "Usage: autopache.sh server-name-here.tld [--delete|--open]"
	exit 255 
fi
DIRENTRY="{{DIR}}"
CURDIR=$(pwd)
NAMEENTRY="{{NAME}}"
SITESAVAILABLE=/etc/apache2/sites-available

if [ "--delete" == "$2" ]
then
a2dissite $SITENAME
/etc/init.d/apache2 restart
rm $SITESAVAILABLE/$SITENAME
sed -i "s%^.*$SITENAME.*$%%g" /etc/hosts
exit 0
fi

if [ -e ./autopache.conf ]
then
	cp ./autopache.conf $SITESAVAILABLE/$SITENAME
elif [ -e /etc/autopache.conf ]
then
	cp /etc/autopache.conf $SITESAVAILABLE/$SITENAME
else
	echo "You plonker - where's autopache.conf?"
fi

sed -i "s%$DIRENTRY%$CURDIR%g" $SITESAVAILABLE/$SITENAME
sed -i "s%$NAMEENTRY%$SITENAME%g" $SITESAVAILABLE/$SITENAME

a2ensite $SITENAME
/etc/init.d/apache2 restart
echo 127.0.0.1 $SITENAME >> /etc/hosts

if [ "--open" == "$2" ]
then
	USER=$(who am i | gawk '{print $1}')
	su - $USER xdg-open http://$SITENAME/
fi
