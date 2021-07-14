#!/usr/bin/env bash

# email-patron.sh - given the name of a carrel and a status, send a note to the patron

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# December 6, 2020 - first cut; back from Lancaster


# configure
CARRELS="$READERCORD_HOME/carrels"
PROVENANCE='provenance.tsv'
STARTED="$READERCORD_HOME/etc/template-email-started.txt"
PROCESSING="$READERCORD_HOME/etc/template-email-processing.txt"
FINISHED="$READERCORD_HOME/etc/template-email-finished.txt"
PATRONS='/data-disk/etc/reader-patrons.db';
REPORT='standard-output.txt'
LOGFILE='standard-error.txt'

# get input
if [[ -z $1 || -z $2 ]]; then
	echo "Usage: $0 <carrel> <started|processing|finished>" >&2
	exit
fi
CARREL=$1
STATUS=$2

# given the carrel and the provenance, look up the patron's username and address
PATRON=$( cat "$CARRELS/$CARREL/$PROVENANCE" | cut -d$'\t' -f5 )
ADDRESS=$( echo "SELECT email FROM patrons WHERE username IS '$PATRON' AND email_verify_date IS NOT '';" | sqlite3 $PATRONS )

# make sure we have an address
if [[ -z $ADDRESS ]]; then exit; fi

# branch accordingly; started
if [[ $STATUS == 'started' ]]; then

	# configure and do the work
	SUBJECT="[distant reader] $CARREL has started"
	BODY=$( cat $STARTED | sed s"/##CARREL##/$CARREL/" )
	echo -e "$BODY" | mailx -s "$SUBJECT" "$ADDRESS"

# processing
elif [[ $STATUS == 'processing' ]]; then

	# configure and do the work
	SUBJECT="[distant reader] $CARREL is about half finished"
	ATTACHMENT="$CARRELS/$CARREL/$REPORT"
	BODY=$( cat $PROCESSING | sed s"/##CARREL##/$CARREL/" )
	echo -e "$BODY" | mailx -s "$SUBJECT" -a "$ATTACHMENT" "$ADDRESS"

# finished
elif [[ $STATUS == 'finished' ]]; then

	# configure and do the work
	SUBJECT="[distant reader] $CARREL has finished"
	ATTACHMENT="$CARRELS/$CARREL/$LOGFILE"
	BODY=$( cat $FINISHED | sed s"/##CARREL##/$CARREL/g" | sed s"/##PATRON##/$PATRON/g"  )
	echo -e "$BODY" | mailx -s "$SUBJECT" -a "$ATTACHMENT" "$ADDRESS"

# error
else

	echo "Usage: $0 <carrel> <started|processing|finished>" >&2
	exit

fi

# done
exit

