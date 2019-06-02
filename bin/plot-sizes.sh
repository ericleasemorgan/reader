#!/usr/bin/env bash

# sizes.sh = given a few inputs, visualize sizes of documents


# configure
DB='./etc/reader.db'
SQL='.headers on\n.mode tabs\nSELECT words AS "sizes in words" FROM bib ORDER BY words DESC;'
RESULT='./tmp/sizes.tsv'
PLOT='./bin/plot.py'

# sanity check
if [[ -z $1 || -z $2 ]]; then

	echo "Usage: $0 <type> <output>" >&2
	exit
	
fi

# get input
TYPE=$1
OUTPUT=$2

# query
printf "$SQL" | sqlite3 $DB > $RESULT

# plot (twice) and done
$PLOT $RESULT $TYPE $OUTPUT