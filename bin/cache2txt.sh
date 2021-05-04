#!/usr/bin/env bash

# cache2txt.sh - given an input directory, use tika to transform documents to plain text

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July     8, 2018 - first cut; at the cabin
# January 31, 2019 - removed the use of parallel
# February 2, 2019 - started using Tika more intelligently; "Happy birthday, Mary!"


# configure
TIKA_HOME='/export/lib/tika'
CACHE='cache'
CARRELS='/export/reader/carrels'
FILE2TXT='/export/reader/bin/file2txt.sh'
TXT='txt'
PARALLEL='/export/bin/parallel'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# initialize
NAME=$1
INPUT="$CACHE"
OUTPUT="$TXT"

# set up tika environment
#TIKA_PATH=$TIKA_HOME
TIKA_LOG_PATH="./tmp"
TIKA_STARTUP_SLEEP=5
TIKA_STARTUP_MAX_RETRY=25
#export TIKA_PATH
export TIKA_LOG_PATH
export TIKA_STARTUP_SLEEP
export TIKA_STARTUP_MAX_RETRY

# make sane
mkdir -p "$OUTPUT"

# find desirable file types, submit the work, wait, and done
find $INPUT -type f | $PARALLEL $FILE2TXT {} $OUTPUT
#find "$INPUT" -name '*.doc'  | $PARALLEL $FILE2TXT {} "$OUTPUT"
#find "$INPUT" -name '*.docx' | $PARALLEL $FILE2TXT {} "$OUTPUT"
#find "$INPUT" -name '*.htm'  | $PARALLEL $FILE2TXT {} "$OUTPUT"
#find "$INPUT" -name '*.html' | $PARALLEL $FILE2TXT {} "$OUTPUT"
#find "$INPUT" -name '*.pdf'  | $PARALLEL $FILE2TXT {} "$OUTPUT"
#find "$INPUT" -name '*.ppt'  | $PARALLEL $FILE2TXT {} "$OUTPUT"
#find "$INPUT" -name '*.pptx' | $PARALLEL $FILE2TXT {} "$OUTPUT"
#find "$INPUT" -name '*.txt'  | $PARALLEL $FILE2TXT {} "$OUTPUT" 
#find "$INPUT" -name '*.ukn'  | $PARALLEL $FILE2TXT {} "$OUTPUT"
#find "$INPUT" -name '*.xml'  | $PARALLEL $FILE2TXT {} "$OUTPUT"
wait

# clean up and done
exit
