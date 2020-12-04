#!/usr/bin/env bash

# carrel2patrons.sh - given the name of a study carrel, move it a patron-accessible file system

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# December 4, 2020 - first cut; on vacation in Lancaster and during pandemic


# configure
CARRELS="$READERCORD_HOME/carrels"
PROVENANCE='provenance.tsv'
PATRONS='/data-disk/www/html/library/patrons'
TEMPLATE="$READERCORD_HOME/etc/template-htaccess.txt"

# get input
if [[ -z $1 ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi
CARREL=$1

# get the name of the patron and provisionally create their cache
PATRON=$( cat "$CARRELS/$CARREL/$PROVENANCE" | cut -d$'\t' -f4 )
mkdir -p "$PATRONS/$PATRON"

# (re-)create the patron's htaccess file
cat $TEMPLATE | sed s"/##PATRON##/$PATRON/g" > "$PATRONS/$PATRON/.htaccess"

# make sane, do the work, and done
cd $CARRELS
mv $CARREL "$PATRONS/$PATRON"
exit
