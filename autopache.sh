#Autopache - automatically setup a vhost for you, right here
# Syntax: autopache.sh yourlocaldomain.local
# Parameter 2:
#  --delete - deletes the vhost
#  --open - opens in browser 
#!/bin/bash
echo "Autopache, version 0.2. Author: Dan Dart. License: Public Domain (or equivalent)"
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
RELEASE=`cat /etc/*release`
# Now determine the distro name and set VHOSTDIR as appropriate
if [[ $RELEASE == *Ubuntu* ]]
then
    VHOSTDIR=/etc/apache2/sites-available
    RELEASENAME=Debian
    SUFFIX=
elif [[ $RELEASE == *Debian* ]]
then
    VHOSTDIR=/etc/apache2/sites-available
    RELEASENAME=Debian
    SUFFIX=
elif [[ $RELEASE == *Gentoo* ]]
then
    VHOSTDIR=/etc/apache2/vhosts.d
    RELEASENAME=Gentoo
    SUFFIX=.conf
else
    echo "Unknown distribution release. Please contact the author at dandart@googlemail.com."
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
	echo "You plonker - where's autopache.conf?"
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
