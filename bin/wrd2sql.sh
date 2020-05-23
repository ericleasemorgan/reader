#!/usr/bin/env bash

# wrd2sql.sh - given a TSV file of keywords, output a set of SQL INSERT statements
# usage: mkdir ./sql-wrd; find ./wrd -name "*.wrd" | sort | parallel wrd2sql.sh

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# May  22, 2020 - first cut


# configure
SQLWRD='./sql-wrd'
TEMPLATE="INSERT INTO wrd ( 'document_id', 'keyword' ) VALUES ( '##DOCUMENTID##', '##KEYWORD##' );"

if [[ -z $1 ]]; then
	echo "Usage: $0 <wrd>" >&2
	exit
fi

# initialize
TSV=$1
BASENAME=$( basename $TSV .wrd )
IFS=$'\t'

# debug
echo "$BASENAME" >&2

# if the desired output already exists, then don't do it again
if [[ -f "$SQLWRD/$BASENAME.sql" ]]; then exit; fi

# extract document_id; I wish they had given me a key
DOCUMENTID=$( echo $BASENAME | cut -d'-' -f2 | sed 's/^0*//' )

# configure and then process each line in the file, sans the header
cat $TSV | tail -n +2 | ( while read ID KEYWORD; do

		# escape
		KEYWORD=$( echo $KEYWORD | sed "s/'/''/g" )
		
		# create an INSERT statement and then update the SQL
		INSERT=$( echo $TEMPLATE | sed "s/##DOCUMENTID##/$DOCUMENTID/" | sed "s|##KEYWORD##|$KEYWORD|" )
		SQL="$SQL$INSERT\n"

	done

	# output 
	printf "$SQL" > "$SQLWRD/$BASENAME.sql"

)

# done
exit
