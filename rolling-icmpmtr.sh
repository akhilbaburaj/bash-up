#!/bin/bash
#Rolling MTR Capture

dstip=$1

if [ -z $dstip ]
then
        echo "Please enter IP address eg>>  bash rolling-mtr.sh 4.2.2.2"
        exit
fi
echo -e "MTR will run recursively for destination $dstip using ICMP probes. Do you want continue?(Y/n) (Default:n)"
read confirm
if [ "$confirm" = "Y" ] || [ "$confirm" = "y" ] || [ "$confirm" = "yes" ] || [ "$confirm" = "YES" ] || [ "$confirm" = "Yes" ]
then
        if [ ! -d /var/tmp/rolling-mtr ]; then
                mkdir /var/tmp/rolling-mtr
        fi

        while true; do
                time_now=`date +%Y-%m-%d_%H:%M:%S`
                mtr $dstip  -m 64 -n -c 100 --report-wide >> /var/tmp/rolling-mtr/mtr_$dstip\_$time_now.txt
                sleep 5
        done &

else
        exit
fi

