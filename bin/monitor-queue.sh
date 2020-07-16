#!/usr/bin/env bash

# monitor-queue.sh - look for carrels to create, and if found, create them

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# June 2, 2020 - first cut
# June 7, 2020 - created in-process... processing


# set up environment; overkill
PERL_HOME='/export/perl/bin'
JAVA_HOME='/export/java/bin'
READER_HOME='/export/reader'
WORD2VEC_HOME='/export/word2vec/bin'
EXPORT_HOME='/export/bin'
PATH=$EXPORT_HOME:$WORD2VEC_HOME:$PERL_HOME:$JAVA_HOME:$READER_HOME:$PATH

# configure
HOME='/export/reader'
TODO='/export/reader/queue/todo'
INPROCESS='/export/reader/queue/in-process'
SUBMITTTED='/export/reader/queue/submitted.tsv'
QUEUE2CARREL='./bin/queue2carrel.sh'

# make sane
cd $HOME

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
	$QUEUE2CARREL $INPROCESS/$BASENAME.tsv
	
	# clean up
	rm -rf $INPROCESS/$BASENAME.tsv
	
# fini
done
exit