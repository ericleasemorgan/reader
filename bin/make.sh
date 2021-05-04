#!/usr/bin/env bash

# make.sh - one script to rule them all

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 10, 2018 - first cut


# configure
CARRELS='/export/reader/carrels'
CACHE2TXT='/export/reader/bin/cache2txt.sh'
MAP='/export/reader/bin/map.sh'
REDUCE='/export/reader/bin/reduce.sh'
DB2REPORT='/export/reader/bin/db2report.sh'
REPORT='etc/report.txt'
CARREL2VEC='/export/reader/bin/carrel2vec.sh'
MAKEPAGES='/export/reader/bin/make-pages.sh'
CORPUS="./etc/reader.txt"

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

echo "  Cool environment variables:"                 >&2
echo "         ACCOUNT_STRING: $ACCOUNT_STRING"      >&2 
echo "       APPLICATION_NAME: $APPLICATION_NAME"    >&2
echo "           CHASSIS_NAME: $CHASSIS_NAME"        >&2 
echo "              CPU_COUNT: $CPU_COUNT"           >&2 
echo "        EXECUTABLE_PATH: $EXECUTABLE_PATH"     >&2 
echo "                EXPORTS: $EXPORTS"             >&2 
echo "             GATEWAY_ID: $GATEWAY_ID"          >&2 
echo "      GATEWAY_USER_NAME: $GATEWAY_USER_NAME"   >&2 
echo "              INPUT_DIR: $INPUT_DIR"           >&2 
echo "                 INPUTS: $INPUTS"              >&2 
echo "               JOB_NAME: $JOB_NAME"            >&2 
echo "  JOB_SUBMITTER_COMMAND: $PRE_JOB_COMMANDS"    >&2 
echo "           MAIL_ADDRESS: $MAIL_ADDRESS"        >&2 
echo "          MAX_WALL_TIME: $MAX_WALL_TIME"       >&2 
echo "        MODULE_COMMANDS: $MODULE_COMMANDS"     >&2 
echo "                  NODES: $NODES"               >&2 
echo "             OUTPUT_DIR: $OUTPUT_DIR"          >&2 
echo "      POST_JOB_COMMANDS: $POST_JOB_COMMANDS"   >&2 
echo "       PRE_JOB_COMMANDS: $PRE_JOB_COMMANDS"    >&2 
echo "       PROCESS_PER_NODE: $PROCESS_PER_NODE"    >&2 
echo "     QUALITY_OF_SERVICE: $QUALITY_OF_SERVICE"  >&2 
echo "             QUEUE_NAME: $QUEUE_NAME"          >&2 
echo "            RESERVATION: $RESERVATION"         >&2 
echo "       SCRATCH_LOCATION: $MODULE_COMMANDS"     >&2 
echo "             SHELL_NAME: $SHELL_NAME"          >&2 
echo "    STANDARD_ERROR_FILE: $STANDARD_ERROR_FILE" >&2 
echo "      STANDARD_OUT_FILE: $STANDARD_OUT_FILE"   >&2 
echo "               USED_MEM: $USED_MEM"            >&2 
echo "              USER_NAME: $USER_NAME"           >&2 
echo "            WORKING_DIR: $WORKING_DIR"         >&2 

# get input
NAME=$1

# start tika
java -jar /export/lib/tika/tika-server.jar &
PID=$!
sleep 10

# transform cache to plain text files
$CACHE2TXT $NAME

# extract parts-of-speech, named entities, etc
$MAP $NAME
kill $PID

# build the database
$REDUCE $NAME

# build ./etc/reader.txt; a plain text version of the whole thing
echo "Building ./etc/reader.txt" >&2
rm -rf $CORPUS >&2
find "./txt" -name '*.txt' -exec cat {} >> "$CORPUS" \;
#sed -e "s/[[:punct:]]\+//g" $CORPUS > ./tmp/corpus.001
tr '[:upper:]' '[:lower:]' < "$CORPUS" > ./tmp/corpus.001
tr '[:digit:]' ' ' < ./tmp/corpus.001 > ./tmp/corpus.002
tr '\n' ' ' < ./tmp/corpus.002 > ./tmp/corpus.003
tr -s ' ' < ./tmp/corpus.003 > "$CORPUS"

# create semantic index
#$CARREL2VEC $NAME

# output a report against the database
$DB2REPORT $NAME > "$CARRELS/$NAME/$REPORT"
cat "$CARRELS/$NAME/$REPORT"

# create about file
$MAKEPAGES $NAME

# done
exit
