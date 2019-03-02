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
TIKA_PATH=$TIKA_HOME
TIKA_LOG_PATH="./log"
TIKA_STARTUP_SLEEP=10
export TIKA_PATH
export TIKA_LOG_PATH
export TIKA_STARTUP_SLEEP

# make sane
mkdir -p $OUTPUT

# find desirable file types, submit the work, wait, and done
find $INPUT -name '*.html' -exec $FILE2TXT {} $OUTPUT \;
find $INPUT -name '*.pdf'  -exec $FILE2TXT {} $OUTPUT \;
find $INPUT -name '*.txt'  -exec $FILE2TXT {} $OUTPUT \;
find $INPUT -name '*.xml'  -exec $FILE2TXT {} $OUTPUT \;
wait

# done
exit
