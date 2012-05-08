#!/bin/bash
if [ "$1" == "--uninstall" ]; then
	echo Uninstalling Autoapache...
	if [ -e /usr/bin/autopache.sh ]; then
		rm /usr/bin/autoapache.sh
	else
		echo "can't find autoapache script..."
	fi

	# Leaving config as /etc/ often considered protected
	exit
elif [ "$1" == "help" || "$1" == "--help" ]; then
	echo "Autoapache Help."
	echo "Usage: $0 [Option]\n"
	echo "--help		Displays this message"
	echo "--uninstall	Uninstalls\n"
	echo "NB: no parameters will install\n"
	echo "Written by Dan Dart (dandart@googlemail.com) MIT Licence"
	echo "https://github.com/dandart/autopache"
	exit
fi

echo Autopache installer
if [ "0" -ne "$UID" ]
then
	echo "This program must be run as root to install the program and its configuration into global program directories."
	exit 1
fi
echo Installing Autopache...
cp autopache.sh /usr/bin
cp autopache.conf /etc
echo ALl done.
