#!/usr/bin/env bash

# flesch.sh = given a few inputs, visualize the Flesch scores of documents


# configure
DB='./etc/reader.db'
SQL='.headers on\n.mode tabs\nSELECT flesch AS "readability scores" FROM bib ORDER BY words DESC;'
RESULT='./tmp/flesch.tsv'
PLOT='../../bin/plot.py'

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