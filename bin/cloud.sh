#!/usr/bin/env bash

# cloud.sh - a front-end to cloud.py

# Eric Lease Morgan <emorgan@nd.edu>
# November 7, 2018 - first cut


# configure
CLOUD='./bin/cloud.py'
DB='./etc/reader.db'
TABULATIONS='./tmp/tabulations'
OUTPUT='./tmp'
LIMIT=150

# sanity check
if [[ -z "$1" ]]; then
	echo "Usage: $0 <nouns|keywords|pronouns|verbs|proper|adjectives|supadj|supadv>" >&2
	exit
fi

# get input
TYPE=$1

# configure some more; keywords
if [[ $TYPE = 'keywords' ]]; then

	SQL=".mode tabs\nselect keyword, count(keyword) as c from wrd group by keyword order by c desc limit $LIMIT;"
	TABULATIONS="$TABULATIONS-keywords.txt"
	COLOR='white'
	OUTPUT="$OUTPUT/keywords.jpg"
	
# nouns
elif [[ $TYPE = 'nouns' ]]; then

	SQL=".mode tabs\nselect lemma, count(lemma) as c from pos where pos is 'NN' or pos is 'NNS' group by lemma order by c desc limit $LIMIT;"
	TABULATIONS="$TABULATIONS-nouns.txt"
	COLOR='black'
	OUTPUT="$OUTPUT/nouns.jpg"

# pronouns
elif [[ $TYPE = 'pronouns' ]]; then

	SQL=".mode tabs\nselect lower(token), count(lower(token)) as c from pos where pos is 'PRP' group by lower(token) order by c desc limit $LIMIT;"
	TABULATIONS="$TABULATIONS-pronouns.txt"
	COLOR='gray'
	OUTPUT="$OUTPUT/pronouns.jpg"

# proper nouns
elif [[ $TYPE = 'proper' ]]; then

	SQL=".mode tabs\nselect token, count(token) as c from pos where pos LIKE 'NNP%%' group by token order by c desc limit $LIMIT;"
	TABULATIONS="$TABULATIONS-proper.txt"
	COLOR='blue'
	OUTPUT="$OUTPUT/proper.jpg"

# verbs
elif [[ $TYPE = 'verbs' ]]; then

	SQL=".mode tabs\nselect lemma, count(lemma) as c from pos where pos like 'V%%' group by lemma order by c desc limit $LIMIT;"
	TABULATIONS="$TABULATIONS-verbs.txt"
	COLOR='gray'
	OUTPUT="$OUTPUT/verbs.jpg"

# adjectives
elif [[ $TYPE = 'adjectives' ]]; then

	SQL=".mode tabs\nselect lemma, count(lemma) as c from pos where (pos like 'J%%' or pos like 'R%%') group by lemma order by c desc limit $LIMIT;"
	TABULATIONS="$TABULATIONS-adjectives.txt"
	COLOR='red'
	OUTPUT="$OUTPUT/adjectives.jpg"

# superlative adjectives
elif [[ $TYPE = 'supadj' ]]; then

	SQL=".mode tabs\nselect lemma, count(lemma) as c from pos where (pos is 'JJS') group by lemma order by c desc limit $LIMIT;"
	TABULATIONS="$TABULATIONS-supadj.txt"
	COLOR='yellow'
	OUTPUT="$OUTPUT/supadj.jpg"

# superlative adverbs
elif [[ $TYPE = 'supadv' ]]; then

	SQL=".mode tabs\nselect lemma, count(lemma) as c from pos where (pos is 'RBS') group by lemma order by c desc limit $LIMIT;"
	TABULATIONS="$TABULATIONS-supadv.txt"
	COLOR='green'
	OUTPUT="$OUTPUT/supadv.jpg"

# error
else

	echo "Usage: $0 <nouns|keywords|pronouns|verbs|proper|adjectives|supadj|supadv>" >&2
	exit

fi

# do the work and done
printf "$SQL" | sqlite3 $DB > $TABULATIONS
$CLOUD $TABULATIONS $COLOR $OUTPUT
exit
