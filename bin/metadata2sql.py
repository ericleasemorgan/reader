#!/usr/bin/env python

# metadata2sql.py - given a CSV file with a limited number of columns, output SQL

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 5, 2019 - first cut


# require
import sys
import pandas as pd
import os

# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <csv>\n" )
	quit()

# initialize
csv = sys.argv[ 1 ]

# read the file and pivot it
metadata = pd.read_csv( csv )

# check for known columns; may add fields later
if   'author' in metadata : valid = True
elif 'title'  in metadata : valid = True
elif 'date'   in metadata : valid = True
else                      : valid = False

# check for validity
if valid == False :
	sys.stderr.write( "Invalid metadata file; need at least an author, title, or date column\n" )
	exit()

# make sure their is a content field
if 'file' not in metadata :
	sys.stderr.write( "Invalid metadata file; no file column\n" )
	exit()

# pivot the table
metadata.set_index( 'file', inplace=True )

# process each row
for file, row in metadata.iterrows() :

	# initialize id
	id = os.path.splitext( file )[0]
	id = id.replace( "'", "''" )
	print( "INSERT INTO bib ( 'id' ) VALUES ( '%s' );" % id )
	
	# author
	if 'author' in metadata :
		author = str( row[ 'author' ] )
		author = author.replace( "'", "''" )
		print( "UPDATE bib SET author = '%s' WHERE id is '%s';" % ( author, id ) )
	
	# title
	if 'title' in metadata :
		title = str( row[ 'title' ] )
		title = title.replace( "'", "''" )
		print( "UPDATE bib SET title = '%s' WHERE id is '%s';" % ( title, id ) )
	
	# date
	if 'date' in metadata :
		date = str( row[ 'date' ] )
		date = date.replace( "'", "''" )
		print( "UPDATE bib SET date = '%s' WHERE id is '%s';" % ( date, id ) )
	
	# abstract
	if 'abstract' in metadata :
		abstract = str( row[ 'abstract' ] )
		abstract = abstract.replace( "'", "''" )
		print( "UPDATE bib SET abstract = '%s' WHERE id is '%s';" % ( abstract, id ) )
	
	# url
	if 'url' in metadata :
		url = str( row[ 'url' ] )
		url = url.replace( "'", "''" )
		print( "UPDATE bib SET url = '%s' WHERE id is '%s';" % ( url, id ) )
	
	# doi
	if 'doi' in metadata :
		doi = str( row[ 'doi' ] )
		doi = doi.replace( "'", "''" )
		print( "UPDATE bib SET doi = '%s' WHERE id is '%s';" % ( doi, id ) )
	
	# delimit
	print()
	
# done
exit()
