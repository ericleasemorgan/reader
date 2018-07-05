#!/usr/bin/env bash

# tika-server.sh - simply manifest tika as a server

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, distributed under a GNU Public License

# November 18, 2017 - first cut; in Pittsburgh on my way to Lancaster


# configure
TIKA='java -jar ./lib/tika-server.jar --port 8080'
PIDFILE='./tmp/tika-server.pid'
LOG='./log/tika-server.log'

# start TIKA
printf "Starting TIKA. Please wait... " 1>&2
$TIKA 2> $LOG &
PID=$!
printf "($PID)\n" 1>&2
echo $PID > $PIDFILE
exit
