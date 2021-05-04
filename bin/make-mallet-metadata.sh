#!/usr/bin/env bash

# make-mallet-metadata.sh - given a type and some values, output a metadata CSC file suitable for topic modeling tool


# configure
TMP='./tmp'

# read the input
INPUTS=("$@")

# sanity check
if [[ $# < 3 ]]; then
	echo "Usage: $0 <author|date|keyword> <item> <another item> [<another item> ...]" >&2
	exit
fi

# initialize
TYPE=${INPUTS[0]}
if [[ $TYPE == 'author' ]]; then
	DATA='./bib/*.bib'
	COLUMN='author'
elif [[ $TYPE == 'date' ]]; then
	DATA='./bib/*.bib'
	COLUMN='date'
elif [[ $TYPE == 'keyword' ]]; then
	DATA='./wrd/*.wrd'
	COLUMN='keyword'
else
	echo "Usage: $0 <author|date|keyword> <item> <another item> [<another item> ...]" >&2
	exit
fi

# make sane
mkdir -p $TMP
rm -rf $TMP/item*.csv

# process each item
for (( i=1; i < $#; i++ )) {

	# re-initialize
	ITEM="item_$i.csv"
	MATCH=${INPUTS[$i]}
	IFS=','
	L=0
		
	# create a temporary file and append the desired data to it
	echo "id,$COLUMN" > "$TMP/$ITEM"
	csvstack $DATA | csvgrep -t -c $COLUMN -m "$MATCH" | csvcut -c id,$COLUMN | while read ID DATA; do
		let "L=L+1"
		if [[ $L -eq 1 ]]; then continue; fi
		echo "$ID.txt,$DATA" >> "$TMP/$ITEM"
	done
	
}

# combine the temporary files and done
csvstack $TMP/item*.csv
exit


