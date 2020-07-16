#!/usr/bin/env bash

# initialize-carrel.sh - given a name and an SQL SELECT statement, copy CORD JSON files and metadata to the Reader

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# May 14, 2020 - first investigations
# May 16, 2020 - required WHERE clause as input
# June 7, 2020 - changed input to be a space-delimited list of identifiers; enabled scaling


# pre-configure
TEMPLATE='.mode tabs\nSELECT document_id, cord_uid, authors, title, date FROM documents WHERE ##WHERE##;'

# configure
CACHE='cache'
CARRELS='/export/reader/carrels'
CSV='metadata.csv'
DB='./etc/cord.db'
HEADER='author\ttitle\tdate\tfile'
JSON='./cord/json'
SUBSELECT="SELECT pdf_json FROM documents WHERE document_id = '##DOCID##';"
TSV='metadata.tsv'
COUNT=999
START=0

# sanity check
if [[ -z $1 || -z $2 ]]; then
	echo "Usage: $0 <name> <ids>" >&2
	exit
fi

# get and parse the input
INPUT=( "$@" )
NAME="${INPUT[0]}" 
IDS=( "${INPUT[@]:1}" )

# initialize
TOTAL=${#IDS[@]}

# create output directory
CACHE="$CARRELS/$NAME/$CACHE"
mkdir -p $CACHE

# initialize metadata file
METADATA="$CARRELS/$NAME/$TSV"
printf "$HEADER\n" > $METADATA

# loop forever
while [ 1 ]; do
	
	# re-initialize
	DOCUMENTIDS=''
	
	# create a subset of the input; SQLite is limited to 1000 WHERE statements at a time
	echo "=====" >&2
	echo "Processing $COUNT records out of $TOTAL, starting at $START" >&2
	SUBSET=("${IDS[@]:$START:$COUNT}")
	
	# process each item in the subset; add field name
	for ID in "${SUBSET[@]}"; do DOCUMENTIDS="$DOCUMENTIDS document_id='$ID'"; done		
	DOCUMENTIDS="${DOCUMENTIDS:1}"
	
	# "unionize" the identifiers and create a SELECT statement
	WHERE=$( echo $DOCUMENTIDS | sed "s/ / OR /g" )
	SELECT=$( echo "$TEMPLATE" | sed "s/##WHERE##/$WHERE/" )
	
	# submit SELECT and process each result
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
		#echo "       author: $AUTHOR"  >&2
		#echo "     cord UID: $CORDID"  >&2
		echo "        title: $TITLE"   >&2
		#echo "         date: $DATE"    >&2
		echo "         JSON: $PDFJSON" >&2
		echo "    file name: $FILE"    >&2
		echo                           >&2
		
		# update the metadata file
		#printf "$AUTHOR\t$TITLE\t$DATE\t$FILE\n" >> $METADATA
		echo -e "$AUTHOR\t$TITLE\t$DATE\t$FILE" >> $METADATA
	
		# copy the local JSON file to the cache
		cp "$JSON/$PDFJSON" "$CACHE/$FILE"
	
	done
		
	# increment and break, conditionally
	let START=START+COUNT
	if [[ $START -gt $TOTAL ]]; then break; fi

done

# convert tsv to csv; kewl hack
perl -lpe 's/"/""/g; s/^|$/"/g; s/\t/","/g' < $METADATA > "$CARRELS/$NAME/$CSV"
rm $METADATA

# fini
exit


