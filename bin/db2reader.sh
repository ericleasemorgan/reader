#!/usr/bin/env bash

# db2reader.sh - set up for Distant reader

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 16, 2020 - first cut


# configure, a lot
TXT='./txt'
HEADER="date,title,file"
METADATA="$TXT/metadata.csv"
SQL=".mode csv\nSELECT date, title, sha||'.txt' FROM articles;"
DB='./etc/covid.db'
CARRELS='/export/reader/carrels'
SLURM='./etc/covid.slurm'
ZIP='input.zip'

# sanity check
if [[ -z $1 ]]; then
	echo "Usage: $0 <name>" >&2
	exit
fi

# get input
NAME=$1

# initialize metadata, and the fill it up
echo $HEADER                >  $METADATA
printf "$SQL" | sqlite3 $DB >> $METADATA

# zip it up, copy things to the reader, and done
zip $ZIP $TXT/*
mkdir -p $CARRELS/$NAME
cp $ZIP $CARRELS/$NAME
cp $SLURM $CARRELS/$NAME
exit
