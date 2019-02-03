#!/usr/bin/env bash

# cache2txt.sh - given an input directory, use tika to transform documents to plain text

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July     8, 2018 - first cut; at the cabin
# January 31, 2019 - removed the use of parallel
# February 2, 2019 - started using Tika more intelligently; "Happy birthday, Mary!"

##SBATCH -N 1 
##SBATCH -J c2txt
##SBATCH -o /home/centos/reader/log/cache2txt-%A.log


# configure
HOME=$READER_HOME
TIKA_HOME='/export/tika'
CACHE='cache'
CARRELS='./carrels'
FILE2TXT='./bin/file2txt.sh'
TXT='txt'

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# initialize
NAME=$1
INPUT="$CARRELS/$NAME/$CACHE"
OUTPUT="$CARRELS/$NAME/$TXT"

# set up tika environment
TIKA_PATH=$TIKA_HOME
TIKA_LOG_PATH=$TIKA_HOME
export TIKA_PATH
export TIKA_LOG_PATH

# make sane
cd $HOME
mkdir -p $OUTPUT

# find desirable file types and do the work
find $INPUT -name '*.html' -exec $FILE2TXT {} $OUTPUT \;
find $INPUT -name '*.pdf'  -exec $FILE2TXT {} $OUTPUT \;
find $INPUT -name '*.txt'  -exec $FILE2TXT {} $OUTPUT \;
find $INPUT -name '*.xml'  -exec $FILE2TXT {} $OUTPUT \;


# MONITOR SQUEUE HERE


# done
exit
