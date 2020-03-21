#!/usr/bin/env bash

# json2txt.sh - give an JSON file of specific shape, output a pseudo-structured plain text file

# Eric Lease Morgan <emorgan@nd.ed>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 16, 2020 - first cut
# March 20, 2020 - added additional data to the txt output


# configure
TXT='./txt'
INSERTS='./sql'
TEMPLATE=".mode tabs\n.headers off\nSELECT doi, journal, date FROM articles WHERE sha is '##SHA##';"
DB='./etc/covid.db'

# sanity check
if [[ -z $1 ]]; then
	echo "Usage: $0 <json>" >&2
	exit
fi

# get input
FILE=$1

# make more sane
mkdir -p $TXT

# don't do work we've already done
BASENAME=$( basename $FILE .json )
if [[ -f "$TXT/$BASENAME.txt" ]]; then
	echo "$TXT/$BASENAME.txt exists; skipping" >&2
	exit
fi

# get the key, the sha
SHA=$( cat $FILE    | jq --raw-output '.paper_id' )
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
#echo -e "          sha: $SHA"          >&2
#echo -e "        title: $TITLE"       >&2
#echo -e "       author: $AUTHOR"      >&2
#echo -e "     abstract: $ABSTRACT"    >&2 
#echo -e "         body: $BODY"        >&2
#echo -e "      entries: $BIBENTRIES"  >&2
#echo -e "  back matter: $BACKMATTER"  >&2
#echo                                  >&2

# get more metadata; there has got to be a better way
QUERY=$( echo $TEMPLATE | sed "s/##SHA##/$SHA/" )
IFS=$'\t'
printf $QUERY | sqlite3 $DB | while read -a ITEMS; do

	# parse
	DOI=${ITEMS[0]}
	JOURNAL=${ITEMS[1]}
	DATE=${ITEMS[2]}
	
	# build the plain text and output
	TEXT="$SHA\n$AUTHOR\n$TITLE\n$DATE\n$JOURNAL\n$DOI\n\n$ABSTRACT\n\n$BODY\n\n$ENTRIES\n\n$BACKMATTER"
	echo -e "$TEXT" > $TXT/$SHA.txt

done
exit



