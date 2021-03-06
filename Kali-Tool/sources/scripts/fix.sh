#!/bin/bash

get_backups(){

	cat /etc/resolv.conf > $BACKUPDIR/resolv.conf.bak
	cat /etc/hostname > $BACKUPDIR/hostname.bak
	cat $TORRC > $BACKUPDIR/torrc.bak
	iptables-save > $BACKUPDIR/iptables.rules.bak
	mkdir $BACKUPDIR/mac_addresses
		IFACES=$(ip -o link show | awk -F': ' '{print $2}')
		    for IFACE in $IFACES; do
			if [ $IFACE != "lo" ]; then
			    cat /sys/class/net/$IFACE/address > $BACKUPDIR/mac_addresses/$IFACE
			fi
		    done
	timedatectl show | grep Timezone | sed 's/Timezone=//g' > $BACKUPDIR/timezone.bak
	cd $BACKUPDIR && tar -czf whoami_fix_backups.tar.gz *
	rm -fr $BACKUPDIR/*.bak $BACKUPDIR/mac_addresses

}

restore_system(){
	
	rm -fr $BACKUPDIR/*.bak $BACKUPDIR/mac_addresses && cd $BACKUPDIR && tar -xzf $BACKUPDIR/tool_fix_backups.tar.gz
	cat $BACKUPDIR/resolv.conf.bak > /etc/resolv.conf 
	cat $BACKUPDIR/hostname.bak > /etc/hostname 
	cat $BACKUPDIR/torrc.bak > /etc/tor/torrc
	iptables-restore <$BACKUPDIR/iptables.rules.bak
	for device in $(ls $BACKUPDIR/mac_addresses) ; do
	    ip link set $device down
	    ip link set $device address $(cat $BACKUPDIR/mac_addresses/$device)
	    ip link set $device up
	done
	restore_timezone=$(cat $BACKUPDIR/timezone.bak) && timedatectl set-timezone $restore_timezone
	rm -fr $BACKUPDIR/*.bak $BACKUPDIR/mac_addresses

}
