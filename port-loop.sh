#!/bin/bash

request_count=${1-10}
destination_url=${2-127.0.0.1}
port=$3
sleep_timer=${4-0.1}

echo $request_count $destination_url $sleep_timer

for (( c=1; c<=$request_count; c++ ))
do
        echo "Test Number $c at `date \"+%Y-%m-%dT%H:%M:%S.%3N\"`"
        nc -vz $destination_url $port
        echo ""
        sleep $sleep_timer
done
