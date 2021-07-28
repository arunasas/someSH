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
PASSTEST="sshpasswdtest"

CMD=$2
IPBASE=$3
IPSTART=$4
IPEND=$5
SLEEP=20

selectPasswdFile ()
{
	case "$( tr '[:upper:]' '[:lower:]' <<< "$1" )" in 
		pass0)
			PASS=$PASS0
			;;
		pass1)
			PASS=$PASS1
			;;
		pass2)
			PASS=$PASS2
			;;
		passtest)
			PASS=$PASSTEST
			;;
		*)
			echo "No such $1 sshpasswdfile. Quitting."
			exit 1
			;;
	esac
}

sshCommand ()
{
    IP=$1
    $SSHPASS -f $PASS $SSH $USER@$IP $SSHOPTSAPC $CMD
}

delayCounter ()
{
    echo -n "Next reboot in [s]: "
    n=$1
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
	echo "Usage example: $0 sshpasswdfile 'command' x.x.x. x x"
	echo "Usage example: $0 sshpasswdfile 'uname -a' 192.168.8. 10 15"
}

#showUsage

selectPasswdFile $1

for ((i=$IPSTART; i<=$IPEND; i++))
    do
    sshCommand $IPBASE$i
    
    [ $? -eq 0 ] && echo "$IPBASE$i sent '$CMD' command" || 
    echo "$IPBASE$i failed to send '$CMD' command"
    
    [ ! $i -eq $IPEND ] && delayCounter $SLEEP || continue
    
    #[ ! $i -eq $IPEND ] && sleep $SLEEP || continue
    
    done
