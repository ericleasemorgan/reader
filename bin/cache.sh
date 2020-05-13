#!/usr/bin/env bash

# cache.sh - given a few configurations, create a file system, download data, uncompress it, and move it into place

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 20, 2020 - first cut; "Happy Spring!"


# configure URLs; these will change
COMMUSE='https://ai2-semanticscholar-cord-19.s3-us-west-2.amazonaws.com/latest/comm_use_subset.tar.gz';
NONCOMMUSE='https://ai2-semanticscholar-cord-19.s3-us-west-2.amazonaws.com/latest/noncomm_use_subset.tar.gz'
#PMC='https://ai2-semanticscholar-cord-19.s3-us-west-2.amazonaws.com/2020-03-20/custom_license.tar.gz'
BIORXIVMEDRXIV='https://ai2-semanticscholar-cord-19.s3-us-west-2.amazonaws.com/latest/biorxiv_medrxiv.tar.gz'
METADATA='https://ai2-semanticscholar-cord-19.s3-us-west-2.amazonaws.com/latest/metadata.csv'

# configure file system
ZIPS='./zips'
JSON='./json'
TMP='./tmp'
ETC='./etc'

# initialize
HOME=$( pwd )
mkdir -p $ZIPS
mkdir -p $JSON
mkdir -p $TMP
mkdir -p $ETC

# get data...
cd $ZIPS
rm ./*.gz
wget $COMMUSE
wget $NONCOMMUSE
#wget $PMC
wget $BIORXIVMEDRXIV

# ...copy it...
cd $HOME
cp $ZIPS/*.gz $TMP

# ...and uncompress them
cd $TMP
find ./ -name "*.gz" | parallel --will-cite tar xvf

# move the resulting json files to the json directory
cd $HOME
find $TMP -name "*.json" | parallel --will-cite mv {} $JSON

# get the metadata file and put it directory into place
wget -O $ETC/metadata.csv $METADATA

# done
exit
