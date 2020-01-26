#!/bin/bash
#Rolling MTR Capture

dstip=$1 
dsttcpprt=$2
if [ -z $dstip ] || [ -z $dsttcpprt ]
then
	echo "Please enter both varibles  eg.  bash rolling-mtr.sh www.google.co.in 80"
	exit
fi
echo -e "MTR will run recursively for destination $dstip on TCP Port $dsttcpprt. Do you want continue?(Y/n) (Default:n)"
read confirm
if [ "$confirm" = "Y" ] || [ "$confirm" = "y" ] || [ "$confirm" = "yes" ] || [ "$confirm" = "YES" ] || [ "$confirm" = "Yes" ] 
then
	if [ ! -d /var/tmp/rolling-mtr ]; then
		mkdir /var/tmp/rolling-mtr
	fi

	while true; do
		time_now=`date +%Y-%m-%d_%H:%M:%S`
		mtr $dstip -P $dsttcpprt -m 64 -n -T -c 300 --report >> /var/tmp/rolling-mtr/mtr_$dstip\_$time_now.txt
		sleep 5
	done &

else
	exit
fi
