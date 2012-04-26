#!/bin/bash
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
