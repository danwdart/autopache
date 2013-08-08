#!/bin/bash
#Autopache - automatically setup a vhost for you, right here

echo "Autopache, version 1.0. Author: Dan Dart. License: MIT"

if [ "--help" == "$1" ]
then
    echo "Syntax: $0 yourlocaldomain.local"
    echo "Note: Must be run as root as it modifies your apache config and hosts file."
    echo "Parameter 3 (optional):"
    echo "  --delete - deletes the vhost"
    echo "  --open - opens in browser"
    echo "Other options:"
    echo "$0 --remove - removes the program keeping the configuration file intact."
    echo "$0 --purge - removes both the program and the configuration file."
    exit 0
fi

if [ "0" -ne "$UID" ]
then
	echo "This program must be run as root (as it requires permissions to edit apache, hosts & restart apache)"
	exit 1
fi

if [ "--remove" == "$1" ]
then
    echo "REMOVING Autopache..."
    read -r -p "Are you sure? This will remove Autopache from the system directories, keeping the configuration file intact [y/N] " response
    response=${response,,} # tolower
    if [[ $response =~ ^(yes|y)$ ]]
    then
        rm /usr/bin/autopache.sh
        echo Done.
        exit 0
    else
        echo Aborted.
        exit 1
    fi
fi

if [ "--purge" == "$1" ]
then
    echo "PURGING Autopache..."
    read -r -p "Are you sure? This will remove Autopache and its configuration file from the system directories [y/N] " response
    response=${response,,} # tolower
    if [[ $response =~ ^(yes|y)$ ]]
    then
        rm /usr/bin/autopache.sh
        rm /etc/autopache.conf
        echo Done.
        exit 0
    else
        echo Aborted.
        exit 1
    fi
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
RELEASE=`cat /etc/*release`
# Now determine the distro name and set VHOSTDIR as appropriate
if [[ $RELEASE == *Ubuntu* || $RELEASE == *Debian* ]]
then
    VHOSTDIR=/etc/apache2/sites-available
    RELEASENAME=Debian
    SUFFIX=.conf
elif [[ $RELEASE == *Gentoo* || $RELEASE == *Funtoo* ]]
then
    VHOSTDIR=/etc/apache2/vhosts.d
    RELEASENAME=Gentoo
    SUFFIX=.conf
else
    echo "Unknown distribution release. Please contact the author at autopache@dandart.co.uk"
    exit 1
fi

if [ "--delete" == "$2" ]
then

    if [[ $RELEASENAME == Debian ]]
    then
        a2dissite $SITENAME
    fi
rm $VHOSTDIR/$SITENAME$SUFFIX
sed -i "s%^.*$SITENAME.*$%%g" /etc/hosts
/etc/init.d/apache2 restart
exit 0
fi

if [ -e ./autopache.conf ]
then
	cp ./autopache.conf $VHOSTDIR/$SITENAME$SUFFIX
elif [ -e /etc/autopache.conf ]
then
	cp /etc/autopache.conf $VHOSTDIR/$SITENAME$SUFFIX
else
	echo "You silly billy - I can't find autopache.conf in /etc or the current directory."
fi

sed -i "s%$DIRENTRY%$CURDIR%g" $VHOSTDIR/$SITENAME$SUFFIX
sed -i "s%$NAMEENTRY%$SITENAME%g" $VHOSTDIR/$SITENAME$SUFFIX

if [[ $RELEASENAME == Debian ]]
then
    a2ensite $SITENAME
fi

/etc/init.d/apache2 restart
echo 127.0.0.1 $SITENAME >> /etc/hosts

if [ "--open" == "$2" ]
then
	USER=$(who am i | gawk '{print $1}')
	su - $USER xdg-open http://$SITENAME/
fi


