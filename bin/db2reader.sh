#!/usr/bin/env bash

# db2reader.sh - set up for Distant reader

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 16, 2020 - first cut


# configure, a lot
TXT='./txt'
HEADER="author,title,file"
METADATA="$TXT/metadata.csv"
SQL=".mode csv\nSELECT author, title, id||'.txt' FROM articles;"
DB='./etc/covid.db'
CARREL='/export/reader/carrels/covid'
SLURM='./etc/covid.slurm'
ZIP='input.zip'

# initialize metadata, and the fill it up
echo $HEADER                >  $METADATA
printf "$SQL" | sqlite3 $DB >> $METADATA

# zip it up, copy things to the reader, and done
zip $ZIP $TXT/*
cp $ZIP $CARREL
cp $SLURM $CARREL
exit
