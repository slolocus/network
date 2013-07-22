#!/bin/bash 

IPT=iptables
ROOTDIR="/root/bin"
BLKLIST=`cat $ROOTDIR/ipblacklist`
PORTLIST=`cat $ROOTDIR/portlist`
for i in INPUT OUTPUT FORWARD ; do 
 $IPT -P $i DROP
 $IPT -I $i -p udp -j LOG --log-tcp-sequence --log-tcp-options --log-ip-options 
 $IPT -I $i -p tcp -j LOG --log-tcp-sequence --log-tcp-options --log-ip-options 
done

# 11371 is for hkp only
# OUTGOING
for i in $PORTLIST; do 
 for j in INPUT OUTPUT; do 
  for k in tcp udp ; do 
   if [ $j == "INPUT" ] ; then
    $IPT -I $j -m $k -p $k --sport $i -j ACCEPT
   else
    $IPT -I $j -m $k -p $k --dport $i -j ACCEPT
   fi
  done 
 done 
done

# LISTENING
for i in 20 21 22 3000 3010 6060 ; do
 for j in INPUT OUTPUT; do
  for k in tcp udp; do
    if [ $j == "INPUT" ] ; then
    $IPT -I $j -m $k -p $k --dport $i -j ACCEPT
   else
    $IPT -I $j -m $k -p $k --sport $i -j ACCEPT
   fi
  done 
 done 
done

# ipp 631
PORT_BLACKLIST="631"

for i in $PORT_BLACKLIST ; do 
 for j in INPUT OUTPUT; do 
  for k in tcp udp ; do 
   if [ $j == "INPUT" ] ; then
    $IPT -I $j -m $k -p $k --sport $i -j DROP
   else
    $IPT -I $j -m $k -p $k --dport $i -j DROP
   fi
  done 
 done 
done

iptables_insert_by_addr(){
 ADDR=$1
 RULE=$2
 for a in INPUT OUTPUT; do 
  for b in tcp udp ; do 
   if  [ $a == "INPUT" ]; then
    $IPT -I $a -m $b -p $b --dst $ADDR -j $RULE
   else
    $IPT -I $a -m $b -p $b --dst $ADDR -j $RULE
   fi
  done
 done 
}

for i in  INPUT OUTPUT ; do 
 iptables -I $i -p icmp --icmp-type echo-reply -j ACCEPT
 iptables -I $i -p icmp --icmp-type echo-request -j ACCEPT
done

iptables -I INPUT -i lo -m udp -p udp --dport 53 -j ACCEPT 
iptables -I OUTPUT -o lo -m udp -p udp --sport 53 -j ACCEPT 
iptables -I INPUT -i lo -m tcp -p tcp --dport 9050 -j ACCEPT 
iptables -I OUTPUT -o lo -m tcp -p tcp --sport 9050 -j ACCEPT 
iptables -I INPUT -i lo -m tcp -p tcp --dport 25 -j ACCEPT 
iptables -I OUTPUT -o lo -m tcp -p tcp --sport 25 -j ACCEPT 
iptables -I INPUT -i lo -m tcp -p tcp --dport 80 -j ACCEPT 
iptables -I OUTPUT -o lo -m tcp -p tcp --sport 80 -j ACCEPT 
# for already established outgoing connections
iptables -I INPUT -m state --state ESTABLISHED -j ACCEPT

for i in $BLKLIST ; do 
 iptables_insert_by_addr $i DROP
done

