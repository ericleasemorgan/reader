#!/usr/bin/env bash

# cache.sh - given a few configurations, create a file system, download data, uncompress it, and move it into place

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 20, 2020 - first cut; "Happy Spring!"
# May   13, 2020 - accommodating new data set layout


# configure URLs; these will change
DOCUMENTS='https://ai2-semanticscholar-cord-19.s3-us-west-2.amazonaws.com/latest/document_parses.tar.gz';
METADATA='https://ai2-semanticscholar-cord-19.s3-us-west-2.amazonaws.com/latest/metadata.csv'

# configure file system
ZIPS='./zips'
JSON='./json'
TMP='./tmp'
ETC='./etc'

# initialize
echo '===== initializing file system =====' >&2
HOME=$( pwd )
rm -rf $JSON
rm -rf $TMP
rm -rf $ZIPS
mkdir -p $ETC
mkdir -p $JSON
mkdir -p $TMP
mkdir -p $ZIPS

# get the metadata file and put it into place
echo '===== getting metadata file =====' >&2
wget -O $ETC/metadata.csv $METADATA

# get data...
echo '===== getting documents =====' >&2
cd $ZIPS
wget $DOCUMENTS

# ...copy it...
echo '===== moving documents to tmp =====' >&2
cd $HOME
cp $ZIPS/*.gz $TMP

# ...and uncompress them
echo '===== uncompressing documents =====' >&2
cd $TMP
tar xvf *.gz

# move the resulting json files to the json directory
echo '===== moving JSON files =====' >&2
cd $HOME
find $TMP -name "*.json" -exec mv {} $JSON \;

# done
exit
