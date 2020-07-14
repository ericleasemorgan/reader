#!/usr/bin/env bash

# json2txt.sh - give an JSON file of specific shape, output a pseudo-structured plain text file

# Eric Lease Morgan <emorgan@nd.ed>
# (c) University of Notre Dame; distributed under a GNU Public License

# June 11, 2020 - first cut


# configure
DB='./etc/cord.db'

# sanity check
if [[ -z $1 ]]; then
	echo "Usage: $0 <json>" >&2
	exit
fi

# get input
FILE=$1

# debug
echo -e "         file: $FILE" >&2

# get the (sort of) key, the sha
SHA=$( cat $FILE | jq --raw-output '.paper_id' )

# set query column based on json paper_id field
ID_COLUMN="sha"
PMC_FILE_ID="PMC*"
if [[ "$SHA" == $PMC_FILE_ID ]]; then
	ID_COLUMN="pmc_id"
fi

TEMPLATE=".mode tabs\nSELECT authors, title, date, journal, doi, abstract, \
document_id, cord_uid FROM documents WHERE ${ID_COLUMN} is '##SHA##';"

# get more metadata
QUERY=$( echo $TEMPLATE | sed "s/##SHA##/$SHA/" )
IFS=$'\t'
printf $QUERY | sqlite3 $DB | while read -a RESULTS; do

	# parse
	AUTHORS=${RESULTS[0]}
	TITLE=${RESULTS[1]}
	DATE=${RESULTS[2]}
	JOURNAL=${RESULTS[3]}
	DOI=${RESULTS[4]}
	ABSTRACT=${RESULTS[5]}
	DOCID=${RESULTS[6]}
	CORDID=${RESULTS[7]}

	# build a file name; a bit obtuse
	ITEM=$( printf "%06d" $DOCID )
	KEY="cord-$ITEM-$CORDID"

	# extract the body; jq++
	BODY=$( cat $FILE | jq --raw-output ".body_text[].text" )
	BODY=$( echo -e $BODY | sed s"/$/\n/g" )

	# bibliographics
	BIBENTRIES=$( cat $FILE | jq --raw-output '.bib_entries[].title' )
	BIBENTRIES=$( echo -e $BIBENTRIES | sed s"/$/\n/g" )

	# backmatter
	BACKMATTER=$( cat $FILE | jq --raw-output '.back_matter[].text' )
	BACKMATTER=$( echo -e $BACKMATTER | sed s"/$/\n/g" )

	# debug
	echo -e "          key: $KEY"         >&2
	echo -e "      authors: $AUTHORS"     >&2
	echo -e "        title: $TITLE"       >&2
	echo -e "         date: $DATE"        >&2
	echo -e "      journal: $JOURNAL"     >&2
	echo -e "          DOI: $DOI"         >&2
	echo -e "          sha: $SHA"         >&2
	echo -e "       doc_id: $DOCID"       >&2
	echo -e "     cord_uid: $CORDID"      >&2
	#echo                                  >&2
	#echo -e "     abstract: $ABSTRACT"    >&2 
	#echo                                  >&2
	#echo -e "         body: $BODY"        >&2
	#echo                                  >&2
	#echo -e "      entries: $BIBENTRIES"  >&2
	#echo                                  >&2
	#echo -e "  back matter: $BACKMATTER"  >&2
	#echo                                  >&2
	echo                                  >&2

	# build the plain and output
	TEXT="key: $KEY\nauthors: $AUTHORS\ntitle: $TITLE\ndate: $DATE\njournal: $JOURNAL\nDOI: $DOI\nsha: $SHA\ndoc_id: $DOCID\ncord_uid: $CORDID\n\n$ABSTRACT\n\n$BODY\n\n$BIBENTRIES\n\n$BACKMATTER"
	echo -e "$TEXT"

done
exit
