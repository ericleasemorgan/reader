#!/usr/bin/env bash

# many2carrel.sh - a front-end to many2carrel.pl

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# July 31, 2020 - first investigations; watch out for bogus SQL results


# configure
MANY2CARREL='./bin/many2carrel.pl'
DB='./etc/cord.db';
AUTHORS='SELECT LOWER(author) FROM authors GROUP BY LOWER(author) ORDER BY COUNT(LOWER(author)) DESC LIMIT 28;'
JOURNALS='SELECT journal FROM documents GROUP BY journal ORDER BY COUNT(journal) DESC LIMIT 4;'
KEYWORDS='SELECT LOWER(keyword) FROM wrd GROUP BY LOWER(keyword) ORDER BY COUNT(LOWER(keyword)) DESC LIMIT 4;'

# sanity check
if [[ -z $1 ]]; then
	echo "Usage: <authors|journals|keyword|entity>" >&2
	exit
fi

# initialize
TYPE=$1
	
# authors
if [[ $TYPE == 'authors' ]]; then

	# process each author
	echo $AUTHORS | sqlite3 $DB | while read AUTHOR; do
		
		# eliminate bogus authors and submit the work
		if [[ $AUTHOR == 'nan' || $AUTHOR == *'o039'* || $AUTHOR == *'d039'* ]]; then continue; fi
		$MANY2CARREL author "$AUTHOR"
		
	done

# journals
elif [[ $TYPE == 'journals' ]]; then

	# process each journal
	echo $JOURNALS | sqlite3 $DB | while read JOURNAL; do
		
		# eliminate bogus titles and submit the work
		if [[ $JOURNAL == 'nan' ]]; then continue; fi
		$MANY2CARREL journal "$JOURNAL"
		
	done

# keywords
elif [[ $TYPE == 'keywords' ]]; then

	# process each journal
	echo $KEYWORDS | sqlite3 $DB | while read KEYWORD; do
		
		# eliminate bogus titles and submit the work
		if [[ $KEYWORD == 'fig' || $KEYWORD == 'figure' ]]; then continue; fi
		$MANY2CARREL keyword "$KEYWORD"
		
	done

else

	echo "Usage: <authors|journals|keywords|entities>" >&2
	exit
	
fi

# done
exit
