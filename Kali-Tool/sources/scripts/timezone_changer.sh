#!/bin/bash

start_timezone_changer(){

source /usr/share/Kali-Tool/sources/config

if [[ "$timezone_changer_status" == "Disable" ]]; then

	timedatectl show | grep Timezone | sed 's/Timezone=//g' > $BACKUPDIR/timezone.bak
	timedatectl set-timezone UTC &> /dev/null
	sed -i 's/timezone_changer_status="Disable"/timezone_changer_status="Enable"/g' $SRCDIR/sources/config
	info "Timezone changer successfully enabled"
else
	warn "Timezone changer is already running"

fi
}

stop_timezone_changer(){

	source /usr/share/Kali-Tool/sources/config
	restore_timezone=$(cat $BACKUPDIR/timezone.bak) && timedatectl set-timezone $restore_timezone && rm -fr $BACKUPDIR/timezone.bak
	sed -i 's/timezone_changer_status="Enable"/timezone_changer_status="Disable"/g' $SRCDIR/sources/config
	info "Timezone changer successfully disabled"
}