#!/usr/bin/env python

# metadata2sql.py - given a few configurations, output sets of sql insert statements

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 20, 2020 - first cut; there are lots o' "20's" in that date; Happy Spring


# configure
METADATA = './etc/metadata.csv'
CROSSREF = 'http://dx.doi.org/'
TEMPLATE = "INSERT INTO articles ( 'sha', 'title', 'journal', 'date', 'doi', 'abstract' ) VALUES ( '##SHA##', '##TITLE##', '##JOURNAL##', '##DATE##', '##DOI##' ,'##ABSTRACT##' );"
INSERTS='./sql'

# require
import pandas as pd
import re
import sys
import os 

# process each row in the metadata file
metadata = pd.read_csv( METADATA )
for index, row in metadata.iterrows() :

	# provide status
	sys.stderr.write( "    index: " + str( index ) + "\n" )

	# parse and check; we must have rows with keys
	sha = str( row[ 'sha' ] )
	if ( sha == 'nan' ) : continue

	# parse some more
	authors  = str( row[ 'authors' ] )
	title    = str( row[ 'title' ] )
	date     = str( row[ 'publish_time' ] )
	journal  = str( row[ 'journal' ] )
	abstract = str( row[ 'abstract' ] )
	doi      = str( row[ 'doi' ] )
	source   = str( row[ 'source_x' ] )

	# munge; normalize
	doi     = doi.replace( CROSSREF, '' )
	authors = re.sub( "^\['", '', authors )
	authors = re.sub( "\']$", '', authors )
	authors = re.sub( "', '", '; ', authors )

	# debug
	sys.stdout.write( "  authors: " + authors  + "\n" )
	sys.stdout.write( "    title: " + title    + "\n" )
	sys.stdout.write( "     date: " + date     + "\n" )
	sys.stdout.write( "  journal: " + journal  + "\n" )
	sys.stdout.write( "      sha: " + sha      + "\n" )
	sys.stdout.write( "      doi: " + doi      + "\n" )
	sys.stdout.write( "   source: " + source   + "\n" )
	sys.stdout.write( "  abstrct: " + abstract + "\n" )
	sys.stdout.write( "\n" )

	# escape
	title    = title.replace( "'", "''" )
	abstract = abstract.replace( "'", "''" )
	journal  = journal.replace( "'", "''" )

	# build sql
	sql = TEMPLATE
	sql = sql.replace( '##SHA##', sha )
	sql = sql.replace( '##TITLE##', title )
	sql = sql.replace( '##JOURNAL##', journal )
	sql = sql.replace( '##DATE##', date )
	sql = sql.replace( '##DOI##', doi )
	sql = sql.replace( '##ABSTRACT##', abstract )

	# save; would rather use re-direction
	file   = INSERTS + '/' + sha + '.sql' 
	handle = open( file , 'w' )
	handle.write( sql + "\n" )
	handle.close
    
# done
exit

   
    