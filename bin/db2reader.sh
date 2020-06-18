#!/usr/bin/env bash

# db2reader.sh - set up for Distant reader

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 16, 2020 - first cut
# March 21, 2020 - created metadata file based on existing files


# configure, a lot
TXT='./txt'
HEADER="date,title,file"
METADATA="$TXT/metadata.csv"
TEMPLATE=".mode csv\nSELECT date, title, sha||'.txt' FROM articles WHERE sha IS '##SHA##';"
DB='./etc/covid.db'
CARRELS='/export/reader/carrels'
TEMPLATESLURM='./etc/covid.slurm'
SLURM="covid.slurm"
ZIP='input.zip'

# sanity check
if [[ -z $1 ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# get input
NAME=$1

# initialize metadata file
echo $HEADER > $METADATA

# process each previously created plain text file
I=0
find $TXT -name "*.txt" | while read FILE; do

	# increment and monitor
	let "I=I+1"
	printf "$I\r" >&2
	
	# get the key, find the metadata, and output
	SHA=$( basename $FILE .txt )
	SQL=$( echo $TEMPLATE | sed "s/##SHA##/$SHA/" )
	printf "$SQL" | sqlite3 $DB >> $METADATA
	
done

# zip up the plain text files and the metadata file
zip $ZIP $TXT/*

# create a study carrel directory, put a slurm script there, put the zip file there, and done
mkdir -p $CARRELS/$NAME
cat $TEMPLATESLURM | sed "s/##NAME##/$NAME/" > $CARRELS/$NAME/$SLURM
cp $ZIP $CARRELS/$NAME
exit
