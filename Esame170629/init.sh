#!/bin/bash

if [ $# -ne 1 ] then
	echo "Parametri non validi"
	exit 1
fi
MYIP = $(ifconfig eth2 | grep "inet addr" | awk -F 'addr:' '{ print $2 }' | cut -f1 -d" ")
scp /root/counter.sh root@"$1"
ssh root@"$1" "iptables -A OUTPUT -p udp --dport 161 -d $MYIP -j ACCEPT"
ssh root@"$1" "iptables -A INPUT -s $MYIP -p udp --sport 161 -m state --state ESTABLISHED,RELATED -j ACCEPT "
cat "/root/ports.to.monitor" | while read PORT ; do
	CHAIN = "PORT_$PORT"
	ssh root@"$1" "iptables -N $CHAIN"
	ssh root@"$1" "iptables -A $CHAIN -p tcp --sport $PORT -j ACCEPT"
done
ssh root@"$1" "echo extend .1.3.6.1.4.1.2021.60 esame /bin/ps -h -o user,uid >> /etc/snmp/snmpd.conf"

# SSH: generare sui server coppie di chiavi ssh, mettere le chiavi pubbliche dei server su ogni monitor nel file /root/.ssh/authorized_keys
