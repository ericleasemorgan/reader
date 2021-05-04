#!/usr/bin/env bash

# monitor-queue.sh - look for carrels to create, and if found, create them

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# June 2, 2020 - first cut
# June 7, 2020 - created in-process... processing



# configure
TODO="$READERCORD_HOME/queue/todo"
INPROCESS="$READERCORD_HOME/queue/in-process"
SUBMITTTED="$READERCORD_HOME/queue/submitted.tsv"
QUEUE2CARREL='queue2carrel.sh'

# process each to-do item
find $TODO -name '*.tsv' | while read FILE; do

	# move to-do item to in-process
	cat $FILE >> $SUBMITTTED	
	BASENAME=$( basename $FILE .tsv )
	mv $FILE $INPROCESS/$BASENAME.tsv
	
	# debug and do the work
	echo "===================" >&2
	echo ''                    >&2
	cat $FILE                  >&2
	echo ''                    >&2
	$QUEUE2CARREL $INPROCESS/$BASENAME.tsv 2>> ~/log/queue2carrel.log
	
	# clean up
	rm -rf $INPROCESS/$BASENAME.tsv
	
# fini
done
exit