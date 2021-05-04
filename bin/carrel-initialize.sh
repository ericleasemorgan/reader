#!/usr/bin/env bash

# initialize-carrel.sh - given a name and an SQL SELECT statement, copy CORD JSON files and metadata to the Reader

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# May  14, 2020 - first investigations
# May  16, 2020 - required WHERE clause as input
# June  7, 2020 - changed input to be a space-delimited list of identifiers; enabled scaling
# July 28, 2020 - modified so we include both types of JSON files; getting ugly


# pre-configure
TEMPLATE='.mode tabs\nSELECT document_id, cord_uid, authors, title, date, abstract, doi, url, pmc_json, pdf_json FROM documents WHERE ##WHERE##;'

# configure
CACHE='cache'
CARRELS="$READERCORD_HOME/carrels"
CSV='metadata.csv'
DB='./etc/cord.db'
HEADER='author\ttitle\tdate\tfile\tabstract\tdoi\turl'
JSON='./cord/json'
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
	printf "$SELECT" | sqlite3 $DB | while read DOCID CORDID AUTHORS TITLE DATE ABSTRACT DOI URLS PMCJSON PDFJSON; do

		# for right now, we only want a single PMC or PDF JSON file; dirty data
		PMCJSON=$( echo $PMCJSON | cut -d';' -f1 )
		PDFJSON=$( echo $PDFJSON | cut -d';' -f1 )
	
		# if there is no content, then skip this record
		if [[ $PMCJSON == 'nan' && $PDFJSON = 'nan' ]]; then continue; fi
		
		# for right now, we only want a single author
		AUTHOR=$( echo $AUTHORS | cut -d';' -f1 )
	
		# for right now, we only want a single url
		URL=$( echo $URLS | cut -d';' -f1 )
	
		# build a file name; a bit obtuse
		ITEM=$(printf "%06d" $DOCID)
		FILE="cord-$ITEM-$CORDID.json"
	
		# debug
		echo "       document ID: $DOCID"   >&2
		echo "           CORD ID: $CORDID"  >&2
		echo "             title: $TITLE"   >&2
		echo "              date: $DATE"    >&2
		echo "          PDF JSON: $PDFJSON" >&2
		echo "          PMC JSON: $PMCJSON" >&2
	
		# update the metadata file
		echo -e "$AUTHOR\t$TITLE\t$DATE\t$FILE\t$ABSTRACT\t$DOI\t$URL" >> $METADATA
	
		# copy a JSON (content) file to the cache
		if [[ ! -z $PDFJSON && $PDFJSON != 'nan' ]]; then
			echo "       source file: $PDFJSON" >&2
			echo "  destination file: $FILE"    >&2
			cp "$JSON/$PDFJSON" "$CACHE/$FILE"
		else
			echo "         source file: $PMCJSON" >&2
			echo "    destination file: $FILE"    >&2
			cp "$JSON/$PMCJSON" "$CACHE/$FILE"
		fi

		# delimit
		echo >&2
	
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


