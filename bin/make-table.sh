#!/usr/bin/env bash

# make-table.sh - loop through a directory of study carrels and output a TSV file

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# May 26, 2020 - migrating to Project CORD


# configure
CARRELS='/export/reader/carrels'
DB='etc/reader.db'
ZIP='study-carrel.zip';

# process each study carrel in the library
find $CARRELS ! -path $CARRELS -maxdepth 1 -type d | while read CARREL; do

	echo "carrel: $CARREL" >&2
	
	# compute
	SHORTNAME=$( basename $CARREL )
	ITEMS=$( echo "SELECT COUNT( id ) FROM bib;" | sqlite3 "$CARREL/$DB" )
	WORDS=$( echo "SELECT SUM( words ) FROM bib;" | sqlite3 "$CARREL/$DB" )
	FLESCH=$( echo "SELECT RTRIM( ROUND( AVG( flesch ) ), '.0' ) FROM bib;" | sqlite3 "$CARREL/$DB" )
	KEYWORDS=$( echo "SELECT keyword FROM wrd GROUP BY keyword ORDER BY COUNT( keyword ) DESC LIMIT 3;" | sqlite3 "$CARREL/$DB" )
	SIZE=$( du "$CARREL/$ZIP" | cut -f1 )
	DATE=$( stat --printf='%z' $CARREL | cut -d ' ' -f1 )

	# format outputs
	KEYWORDS=$( echo $KEYWORDS | sed 's/ /, /g' )
	SIZE=$( printf "%'.f" $SIZE )
	WORDS=$( printf "%'.f" $WORDS )
	ITEMS=$( printf "%'.f" $ITEMS )
	
	# debug
	echo $CARREL    >&2
	echo $SHORTNAME >&2
	echo $KEYWORDS  >&2
	echo $ITEMS     >&2
	echo $FLESCH    >&2
	echo $WORDS     >&2
	echo $SIZE      >&2
	echo $DATE      >&2
	echo            >&2

	# output
	printf "$SHORTNAME\t$DATE\t$KEYWORDS\t$ITEMS\t$WORDS\t$FLESCH\t$SIZE\n"
	
done

# done
exit
