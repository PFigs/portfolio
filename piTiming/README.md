# README #

Hello this code is meant for a Raspberry pi but should be compilable and runnable in a normal Unix environment. Just make sure PI is not define in the compiler flags.

### How to get the program running? ###

The program is meant to accept an ublox and a micro strain IMU.

By default the program assumes none of these devices are present, therefore it requires their location to be passed to the program as

```
#!c
./pitiming -gps /dev/ttyACM0 //only the ublox

./pitiming -mcs /dev/ttyACM1 //only the IMU

./pitiming -gps /dev/ttyACM0 -mcs /dev/ttyACM1 //both

./pitiming -gps ./raw.ubx //or even a bin file
```

Once it is called the program will launch a thread for each device and block until a notification from the system is received. If running in the PI this should be until a rising edge is detected on the pin **PIN_GPS_TIM**, otherwise the behaviour can be simulated by sending SIGRTMIN+3 to the process. 

For the later case, you can send signals to the program by opening a terminal and typing *(if DEBUG is on, the PID of the main program is printed on the terminal)*

```
#!bash

kill -l #lists signal's name and their value (SIGRTMIN+3 is 37)

kill -37 <proccess_id>
```

Once the program receives the signal, it notifies the working threads who search for a valid mesage (GPSTIME for the UBLOX) and dump it into a file.

Exiting the program is done is a similar way and can be done using CRT-C/SIGINT but since the main thread will be blocked in the sem_wait you might have to send it a SIGRTMIN+3 beforehand. You can also send the SIGINT using kill 

```
#!bash
kill -2 <proccess_id>
```


### Reading the log ###

In tools, you can find a small example on way to parse the contents of the log and check if it is accurate. Just keep in mind that changing machines might lead to different results, due to the endiness of the systems.

For a formatted string output, define SHOW_STRING in the compiler and the program will write to stdout N lines with the following format

```
#!c
%lld.%.9ld\t%lld.%.9ld\t%lld.%.9ld\t%u\t%u\t%d\t%d\t%d\t%u\n
```

the following information

#From the Pi

CLOCK_REALTIME  : System time (unix time in seconds)

CLOCK_MONOTONIC : Time Tag after waking up (more precise clock but referring to an unspecified point in time, usually it refers to seconds elapsed since boot)

CLOCK_MONOTONIC : Time Tag after reading serial port (seconds)


#From the uBlox

iTOW            : Time of week (ms)

fTOW            : fractional part of TOW (ns)

week            : GPS week number (#)

leaps           : GPS leap seconds (GPS-UTC)

valid           : Validity Flags (eg, 7: TOW, Week and Leaps OK , 3: TOW and Week OK, Leaps NOK, 1: TOW OK, Week and Leaps NOK)

tAcc            : Time Accuracy Estimate (ns)

The precise GPS time of week in seconds is (iTOW * 1e-3) + (fTOW * 1e-9)


### Who do I talk to? ###

Pedro Silva, pedro.silva@tut.fi

Pekka Peltola, pekka.peltola@nottingham.ac.uk