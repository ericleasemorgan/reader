#!/usr/bin/env bash

# json2sql.sh - give an JSON file of specific shape, output an SQL statement as well as plain text

# Eric Lease Morgan <emorgan@nd.ed>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 16, 2020 - first cut


# configure
TEMPLATE="INSERT INTO articles ( 'id', 'title', 'author' ) VALUES ( '##ID##', '##TITLE##', '##AUTHOR##' );"
TXT='./txt'
INSERTS='./sql'

# sanity check
if [[ -z $1 ]]; then
	echo "Usage: $0 <json>" >&2
	exit
fi

# get input
FILE=$1

# make more sane
mkdir -p $TXT
mkdir -p $INSERTS

# don't do work we've already done
BASENAME=$( basename $FILE .json )
if [[ -f "$TXT/$BASENAME.txt" ]]; then
	echo "$TXT/$BASENAME.txt exists; skipping" >&2
	exit
fi

# parse the easy stuff
ID=$( cat $FILE    | jq --raw-output '.paper_id' )
TITLE=$( cat $FILE | jq --raw-output '.metadata.title' )

# author
AUTHORLAST=$( cat $FILE  | jq --raw-output '.metadata.authors[0].last' )
AUTHORFIRST=$( cat $FILE | jq --raw-output '.metadata.authors[0].first' )
AUTHOR="$AUTHORLAST, $AUTHORFIRST"

# abstract
ABSTRACT=$( cat $FILE | jq --raw-output '.abstract[].text' )
ABSTRACT=$( echo -e $ABSTRACT | sed s"/$/\n/g" )

# body
BODY=$( cat $FILE | jq --raw-output ".body_text[].text" )
BODY=$( echo -e $BODY | sed s"/$/\n/g" )

# bibliographics
BIBENTRIES=$( cat $FILE | jq --raw-output '.bib_entries[].title' )
BIBENTRIES=$( echo -e $BIBENTRIES | sed s"/$/\n/g" )

# backmatter
BACKMATTER=$( cat $FILE | jq --raw-output '.back_matter[].text' )
BACKMATTER=$( echo -e $BACKMATTER | sed s"/$/\n/g" )

# debug
#echo -e "           id: $ID"          >&2
#echo -e "        title: $TITLE"       >&2
#echo -e "       author: $AUTHOR"      >&2
#echo -e "     abstract: $ABSTRACT"    >&2 
#echo -e "         body: $BODY"        >&2
#echo -e "      entries: $BIBENTRIES"  >&2
#echo -e "  back matter: $BACKMATTER"  >&2
#echo                                  >&2

# build the text
TEXT="$ABSTRACT\n\n$BODY\n\n$ENTRIES\n\n$BACKMATTER"

# escape
TITLE=$( echo $TITLE | sed s"/'/''/g" )
AUTHOR=$( echo $AUTHOR | sed s"/'/''/g" )

# output sql
echo -e "INSERT INTO articles ( 'id' ) VALUES ( '$ID' );"             >  $INSERTS/$ID.sql
echo -e "UPDATE articles SET 'author' = '$AUTHOR' WHERE id IS '$ID';" >> $INSERTS/$ID.sql
echo -e "UPDATE articles SET 'title'  = '$TITLE'  WHERE id IS '$ID';" >> $INSERTS/$ID.sql

# output text and done
echo -e "$TEXT" > $TXT/$ID.txt
exit


