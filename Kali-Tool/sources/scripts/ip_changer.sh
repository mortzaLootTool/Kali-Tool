#!/bin/bash

start_ip_changer(){

source /usr/share/Kali-Tool/sources/config

if [[ "$dns_changer_status" == "Disable" ]]; then

   # backup and configuring transparent proxy for tor
   if [[ "$ip_changer_status" == "Disable" ]]; then
	cat $TORRC > $BACKUPDIR/torrc.bak
	cat /etc/resolv.conf > $BACKUPDIR/resolv.conf.bak
	iptables-save > $BACKUPDIR/iptables.rules.bak

	iptables -F
	iptables -X
	iptables -t nat -F
	iptables -t nat -X
	iptables -t nat -A OUTPUT -d 10.192.0.0/10 -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j REDIRECT --to-ports 9040
	iptables -t nat -A OUTPUT -d 127.0.0.1/32 -p udp -m udp --dport 53 -j REDIRECT --to-ports 5353
	iptables -t nat -A OUTPUT -m owner --uid-owner $tor_uid -j RETURN
	iptables -t nat -A OUTPUT -o lo -j RETURN

	for lan in 127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16; do
		iptables -t nat -A OUTPUT -d $lan -j RETURN
	done

	iptables -t nat -A OUTPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j REDIRECT --to-ports 9040
	iptables -A INPUT -m state --state ESTABLISHED -j ACCEPT
	iptables -A INPUT -i lo -j ACCEPT
	iptables -A INPUT -j DROP
	iptables -A FORWARD -j DROP
	iptables -A OUTPUT -m conntrack --ctstate INVALID -j DROP
	iptables -A OUTPUT -m state --state INVALID -j DROP
	iptables -A OUTPUT -m state --state ESTABLISHED -j ACCEPT
	iptables -A OUTPUT -m owner --uid-owner $tor_uid -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -m state --state NEW -j ACCEPT
	iptables -A OUTPUT -d 127.0.0.1/32 -o lo -j ACCEPT
	iptables -A OUTPUT -d 127.0.0.1/32 -p tcp -m tcp --dport 9040 --tcp-flags FIN,SYN,RST,ACK SYN -j ACCEPT
	iptables -A OUTPUT -j DROP
	iptables -P INPUT DROP
	iptables -P FORWARD DROP
	iptables -P OUTPUT DROP

	cat >"/etc/tor/torrc" <<EOF
VirtualAddrNetworkIPv4 10.192.0.0/10
AutomapHostsOnResolve 1
TransPort 9040 IsolateClientAddr IsolateClientProtocol IsolateDestAddr IsolateDestPort
SocksPort 9050
DNSPort 5353
EOF

	cat >"/etc/resolv.conf" <<EOF
# This file was edited by kali-whoami. Do not change manually!
nameserver 127.0.0.1
EOF
	systemctl --system daemon-reload

	if systemctl is-active tor.service >/dev/null 2>&1; then
	      systemctl stop tor.service
	fi
	
	sysctl -w net.ipv6.conf.all.disable_ipv6=1 &> /dev/null
	sysctl -w net.ipv6.conf.default.disable_ipv6=1 &> /dev/null
	systemctl start tor.service &>/dev/null
	sed -i 's/ip_changer_status="Disable"/ip_changer_status="Enable"/g' $SRCDIR/sources/config
	info "Ip changer successfully enabled"

	else
	   warn "Ip changer is already running"
	fi
else
	warn "The Ip changer is not available. (Dns changer enabled)"
fi

}

stop_ip_changer(){

	source /usr/share/KALI-TOOL/sources/config
	
	iptables -F
	iptables -X
	iptables -t nat -F
	iptables -t nat -X
	iptables -P INPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -P OUTPUT ACCEPT
	systemctl stop tor.service
	iptables-restore <$BACKUPDIR/iptables.rules.bak
	sysctl -w net.ipv6.conf.all.disable_ipv6=0 &> /dev/null
	sysctl -w net.ipv6.conf.default.disable_ipv6=0 &> /dev/null
	
	cat $BACKUPDIR/torrc.bak > $TORRC && cat $BACKUPDIR/resolv.conf.bak > /etc/resolv.conf && rm -fr $BACKUPDIR/resolv.conf.bak $BACKUPDIR/torrc.bak $BACKUPDIR/iptables.rules.bak	
	sed -i 's/ip_changer_status="Enable"/ip_changer_status="Disable"/g' $SRCDIR/sources/config
	info "Ip changer successfully disabled"

}