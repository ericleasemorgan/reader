#!/usr/bin/env python

# tsv2htm-bibliographics.ph - given a TSV file, output a stream of HTML

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# June 26, 2020 - enhanced by Maria Carrol to be more meaningful and link to plain text


# configure
TEMPLATE = '/export/reader/etc/tsv2htm-bibliographics.htm'

# require
import pandas as pd
import sys

# sanity check
if len( sys.argv ) !=2:
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <tsv>" + "\n")
	quit()

# get input
tsv = sys.argv[ 1 ]

# slurp up the given file
df = pd.read_csv( tsv, sep='\t', error_bad_lines=False )

# process each row in the given tsv file
rows = ''
for index, row in df.iterrows() :
	
	# parse
	id        = str( row[ 'id' ] )
	author    = str( row[ 'author' ] )
	title     = str( row[ 'title' ] )
	date      = str( row[ 'date' ] )
	words     = str( row[ 'words' ] )
	sentences = str( row[ 'sentences' ] )
	text      = str( row[ 'txt' ] )
	path      = '../txt/' + id + '.txt'
	
	# build
	rows = rows + "<tr><td>" + id + "</td><td>" + author + "</td><td>" + title + "</td><td>" + date + "</td><td>" + words + "</td><td>" + sentences + "</td><td>" + '<a href="' + path + '">view text</a>'"</td></tr>\n" 
	
# slurp up the template and do the substitution
with open( TEMPLATE, 'r' ) as handle : htm = handle.read()
htm = htm.replace( '##ROWS##', rows )

# output and done
print( htm )
exit()
