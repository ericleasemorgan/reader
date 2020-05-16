#!/usr/bin/env bash

# initialize-carrel.sh - given a name and an SQL SELECT statement, copy CORD JSON files and metadata to the Reader

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# May 14, 2020 - first investigations
# May 16, 2020 - required WHERE clause as input


# pre-configure
TEMPLATE='.mode tabs\nSELECT document_id, cord_uid, authors, title, date FROM documents WHERE ##WHERE##;'

# configure
CACHE='cache'
CARRELS='/export/reader/carrels'
CSV='metadata.csv'
DB='./etc/cord.db'
HEADER='author\ttitle\tdate\tfile'
JSON='./json'
SUBSELECT="SELECT pdf_json FROM documents WHERE document_id = '##DOCID##';"
TSV='metadata.tsv'

# sanity check
if [[ -z $1 || -z $2  ]]; then
	echo "Usage: $0 <name> <where clause>" >&2
	exit
fi

# get input
NAME=$1
WHERE=$2

# create output directory
CACHE="$CARRELS/$NAME/$CACHE"
mkdir -p $CACHE

# initialize metadata file
METADATA="$CARRELS/$NAME/$TSV"
printf "$HEADER\n" > $METADATA

# initialize select statement
SELECT=$( echo "$TEMPLATE" | sed "s/##WHERE##/$WHERE/" )

# submit select and process each result
IFS=$'\t'
printf "$SELECT" | sqlite3 $DB | while read DOCID CORDID AUTHORS TITLE DATE; do

	# get the pdf_json file name
	SQL=$( echo $SUBSELECT | sed "s/##DOCID##/$DOCID/" )
	PDFJSON=$( echo $SQL | sqlite3 $DB )
	
	# we only want to continue, if we have a file
	if [[ $PDFJSON == 'nan' || -z  $PDFJSON ]]; then continue; fi
	
	# for right now, we only want a single author
	AUTHOR=$( echo $AUTHORS | cut -d';' -f1 )
	
	# build a file name; a bit obtuse
	ITEM=$(printf "%05d" $DOCID)
	FILE="cord-$ITEM-$CORDID.json"
	
	# debug
	echo "  document id: $DOCID"   >&2
	echo "       author: $AUTHOR"  >&2
	echo "     cord UID: $CORDID"  >&2
	echo "        title: $TITLE"   >&2
	echo "         date: $DATE"    >&2
	echo "         JSON: $PDFJSON" >&2
	echo "    file name: $FILE"    >&2
	echo                           >&2
		
	# update the metadata file
	printf "$AUTHOR\t$TITLE\t$DATE\t$FILE\n" >> $METADATA
	
	# copy the local JSON file to the cache
	cp "$JSON/$PDFJSON" "$CACHE/$FILE"
	
done

# convert tsv to csv; kewl hack
perl -lpe 's/"/""/g; s/^|$/"/g; s/\t/","/g' < $METADATA > "$CARRELS/$NAME/$CSV"
rm $METADATA

# fini
exit


