#!/usr/bin/env python

# metadata2sql.py - given a few configurations, output sets of sql insert statements

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# March 20, 2020 - first cut; there are lots o' "20's" in that date; Happy Spring
# May   14, 2020 - modified because the metadata changed its shape


# configure
METADATA = './etc/metadata.csv'
TEMPLATE = "INSERT INTO documents ( 'authors', 'title', 'date', 'year', 'journal', 'source', 'abstract', 'license', 'pdf_json', 'pmc_json', 'sha', 'url', 'doi', 'arxiv_id', 'cord_uid', 'mag_id', 'pmc_id', 'pubmed_id', 'who_id' ) VALUES ( '##AUTHHORS##', '##TITLE##', '##DATE##', '##YEAR##', '##JOURNAL##', '##SOURCE##', '##ABSTRACT##', '##LICENSE##', '##PDFJSON##', '##PMCJSON##', '##SHA##', '##URL##', '##DOI##', '##ARXIVID##', '##CORDUID##', '##MAGID##', '##PMCID##', '##PUBMEDID##', '##WHOID##' );"
INSERTS='./sql'

# require
import pandas as pd
import re
import sys
import os 

# process each row in the metadata file
metadata = pd.read_csv( METADATA, low_memory=False )
for index, row in metadata.iterrows() :

	# provide status
	sys.stderr.write( "      index: " + str( index ) + "\n" )

	# parse and check; for right now, we only want rows with titles
	#title    = str( row[ 'title' ] )
	#if ( title == 'nan' ) : continue

	# parse some more
	authors   = str( row[ 'authors' ] )
	title     = str( row[ 'title' ] )
	date      = str( row[ 'publish_time' ] )
	journal   = str( row[ 'journal' ] )
	source    = str( row[ 'source_x' ] )
	abstract  = str( row[ 'abstract' ] )
	license   = str( row[ 'license' ] )
	pmc_json  = str( row[ 'pmc_json_files' ] )
	pdf_json  = str( row[ 'pdf_json_files' ] )
	sha       = str( row[ 'sha' ] )
	url       = str( row[ 'url' ] )
	doi       = str( row[ 'doi' ] )
	arxiv_id  = str( row[ 'arxiv_id' ] )
	cord_uid  = str( row[ 'cord_uid' ] )
	mag_id    = str( row[ 'mag_id' ] )
	pmc_id    = str( row[ 'pmcid' ] )
	pubmed_id = str( row[ 'pubmed_id' ] )
	who_id    = str( row[ 'who_covidence_id' ] )

	# parse even more
	if ( pmc_json != 'nan' ) :
		pmc_json = pmc_json.split( '/' )
		pmc_json = pmc_json[ 2 ]

	if ( pdf_json != 'nan' ) :
		pdf_json = pdf_json.split( '/' )
		pdf_json = pdf_json[ 2 ]
		
	# extract the year
	year = date[ :4 ]
	
	# debug
	sys.stdout.write( "    authors: " + authors   + "\n" )
	sys.stdout.write( "      title: " + title     + "\n" )
	sys.stdout.write( "       date: " + date      + "\n" )
	sys.stdout.write( "       year: " + year      + "\n" )
	sys.stdout.write( "    journal: " + journal   + "\n" )
	sys.stdout.write( "     source: " + source    + "\n" )
	sys.stdout.write( "   abstract: " + abstract  + "\n" )
	sys.stdout.write( "    license: " + license   + "\n" )
	sys.stdout.write( "   pmc json: " + pmc_json  + "\n" )
	sys.stdout.write( "   pdf json: " + pdf_json  + "\n" )
	sys.stdout.write( "        sha: " + sha       + "\n" )
	sys.stdout.write( "        url: " + url       + "\n" )
	sys.stdout.write( "        doi: " + doi       + "\n" )
	sys.stdout.write( "   arxiv_id: " + arxiv_id  + "\n" )
	sys.stdout.write( "   cord_uid: " + cord_uid  + "\n" )
	sys.stdout.write( "     mag_id: " + mag_id    + "\n" )
	sys.stdout.write( "     pmc_id: " + pmc_id    + "\n" )
	sys.stdout.write( "  pubmed_id: " + pubmed_id + "\n" )
	sys.stdout.write( "     who_id: " + who_id    + "\n" )
	sys.stdout.write( "\n" )

	# escape
	title    = title.replace( "'", "''" )
	journal  = journal.replace( "'", "''" )
	abstract = abstract.replace( "'", "''" )
	authors  = authors.replace( "'", "''" )

	# build sql
	sql = TEMPLATE
	sql = sql.replace( '##AUTHORS##', authors )
	sql = sql.replace( '##TITLE##', title )
	sql = sql.replace( '##DATE##', date )
	sql = sql.replace( '##YEAR##', year )
	sql = sql.replace( '##JOURNAL##', journal )
	sql = sql.replace( '##SOURCE##', source )
	sql = sql.replace( '##ABSTRACT##', abstract )
	sql = sql.replace( '##LICENSE##', license )
	sql = sql.replace( '##PDFJSON##', pdf_json )
	sql = sql.replace( '##PMCJSON##', pmc_json )
	sql = sql.replace( '##SHA##', sha )
	sql = sql.replace( '##URL##', url )
	sql = sql.replace( '##DOI##', doi )
	sql = sql.replace( '##ARXIVID##', arxiv_id )
	sql = sql.replace( '##CORDUID##', cord_uid )
	sql = sql.replace( '##MAGID##', mag_id )
	sql = sql.replace( '##PMCID##', pmc_id )
	sql = sql.replace( '##PUBMEDID##', pubmed_id )
	sql = sql.replace( '##WHOID##', who_id )

	# save; would rather use re-direction
	file   = INSERTS + '/' + str( index ) + '.sql' 
	handle = open( file , 'w' )
	handle.write( sql + "\n" )
	handle.close
        
# done
exit

   
    