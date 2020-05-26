#!/usr/bin/env bash

# ent2sql.sh - given a TSV file of name entities, output a set of SQL INSERT statements
# usage: mkdir ./sql-ent; find ./ent -name "*.ent" | sort | parallel ent2sql.sh

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# May 26, 2020 - first cut


# configure
SQLENT='./sql-ent'
TEMPLATE="INSERT INTO ent ( 'document_id', 'sid', 'eid', 'entity', 'type' ) VALUES ( '##DOCUMENTID##', '##SID##', '##EID##', '##ENTITY##', '##TYPE##' );"

if [[ -z $1 ]]; then
	echo "Usage: $0 <ent>" >&2
	exit
fi

# initialize
TSV=$1
BASENAME=$( basename $TSV .ent )
IFS=$'\t'

# debug
echo "$BASENAME" >&2

# if the desired output already exists, then don't do it again
if [[ -f "$SQLENT/$BASENAME.sql" ]]; then exit; fi

# extract document_id; I wish they had given me a key
DOCUMENTID=$( echo $BASENAME | cut -d'-' -f2 | sed 's/^0*//' )

# configure and then process each line in the file, sans the header
cat $TSV | tail -n +2 | ( while read ID SID EID ENTITY TYPE; do

		# escape
		ENTITY=$( echo $ENTITY | sed "s/'/''/g" )
		ENTITY=$( echo $ENTITY | sed "s/%/'%/g" )
		
		# create an INSERT statement and then update the SQL
		INSERT=$( echo $TEMPLATE | sed "s/##DOCUMENTID##/$DOCUMENTID/" | sed "s|##SID##|$SID|" | sed "s|##EID##|$EID|" | sed "s|##ENTITY##|$ENTITY|"| sed "s|##TYPE##|$TYPE|" )
		SQL="$SQL$INSERT\n"

	done

	# output 
	printf "$SQL" > "$SQLENT/$BASENAME.sql"

)

# done
exit
