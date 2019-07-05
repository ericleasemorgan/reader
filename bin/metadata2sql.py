#!/usr/bin/env python

# metadata2sql.py - given a CSV file with a limited number of columns, output SQL

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 5, 2019 - first cut


# require
import sys
import pandas as pd

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

	# initialize record
	print( "INSERT INTO bib ( 'id' ) VALUES ( '%s' );" % file )
	
	# author
	if 'author' in metadata :
		author = row[ 'author' ]
		print( "UPDATE bib SET author = '%s' WHERE id is '%s';" % ( author, file ) )
	
	# title
	if 'title' in metadata :
		title = row[ 'title' ]
		print( "UPDATE bib SET title = '%s' WHERE id is '%s';" % ( title, file ) )
	
	# date
	if 'date' in metadata :
		date = row[ 'date' ]
		print( "UPDATE bib SET date = '%s' WHERE id is '%s';" % ( date, file ) )
	
	# delimit
	print()
	
# done
exit()
