#!/bin/bash

SSHPASS=/usr/bin/sshpass
SSH=/usr/bin/ssh

SSHOPTSAPC="
-oKexAlgorithms=+diffie-hellman-group1-sha1 
-oHostKeyAlgorithms=+ssh-dss 
-c aes256-cbc 
-oStrictHostKeyChecking=no 
-oLogLevel=ERROR 
-oUserKnownHostsFile=/dev/null"

SSHOPTSNFT="
-oKexAlgorithms=+diffie-hellman-group1-sha1 
-oHostKeyAlgorithms=+ssh-dss
-oStrictHostKeyChecking=no 
-oLogLevel=ERROR
-oUserKnownHostsFile=/dev/null"

USER="admin"
PASS0="/root/sshpasswd0"
PASS1="/root/sshpasswd1"
PASS2="/root/sshpasswd2"

IPBASE=$1
IPSTART=$2
IPEND=$3

reboot ()
{
    IP=$1
    $SSHPASS -f $PASS0 $SSH $USER@$IP $SSHOPTSNFT 'uptime'
}

delayCounter ()
{
    echo -n "Next reboot in [s]: "
    n=$1a
    while [ $n -ge 10 ]
    do
        echo -n "$n "
        n=$(( $n - 10 ))
        sleep 10
    done
    echo
}

showUsage ()
{
	echo "Usage example: $0 192.168.8. 10 15"
}

showUsage

for ((i=$IPSTART; i<=$IPEND; i++))
    do
    reboot $IPBASE$i
    
    [ $? -eq 0 ] && echo "$IPBASE$i sent reboot command" || 
    echo "$IPBASE$i failed to send reboot command"
    
    delayCounter 40
    done
