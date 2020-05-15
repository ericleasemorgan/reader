#!/usr/bin/env bash

# carrel-submit.sh - given the name of a previously initialized carrel, submit process to Slurm

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# April 4, 2020 - first cut; while self-isolating at the cabin


# configure
CARRELS='/home/emorgan/sandbox/carrels'
TEMPLATESLURM='./etc/cord-big.slurm'

# configure some more
JSON='./json'
TESTDATA='./test-data'
TXT='./txt'
HEADER="date,title,file"
METADATA="$CARRELS/$NAME/metadata.csv"
TEMPLATE=".mode csv\nSELECT date, title, sha||'.txt' FROM articles WHERE sha IS '##SHA##';"
DB='./etc/covid.db'
SLURM="cord.slurm"

# initialize
rm -rf $TESTDATA
rm -rf $TXT
mkdir -p $TESTDATA
mkdir -p $TXT

find $JSON -name '*.json' | head -n $SIZE | while read FILE; do cp $FILE $TESTDATA; done
find $TESTDATA -name "*.json" | parallel ./bin/json2txt.sh 

# initialize some more
rm -rf "$CARRELS/$NAME"
mkdir -p "$CARRELS/$NAME"
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

# move the data and create a slurm script
mv $TXT "$CARRELS/$NAME"
cat $TEMPLATESLURM | sed "s/##NAME##/$NAME/" | sed "s/##SIZE##/$SIZE/"> $CARRELS/$NAME/$SLURM

# make sane, submit the job, and done
cd "$CARRELS/$NAME"
sbatch $SLURM
exit
