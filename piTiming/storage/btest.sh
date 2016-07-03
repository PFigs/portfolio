#!/bin/bash

# trap interruption
trap "echo Exited!\n; exit;" SIGINT SIGTERM

# Define a timestamp function

echo_time_gnss() {
    date +"#:%H:%M:%S:%N,$*"
}



# Port setting
#stty -F /dev/ttyS1 raw speed 9600

#cat /dev/ttyACM0 | while read line ; do echo_time_gnss $line; done

# Loop
while [ 1 ]; do
        READ=`dd if=/dev/ttyACM0 count=1`
        echo_time_gnss $READ
done
