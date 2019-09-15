#!/usr/bin/env python

# configure
TEMPLATE = '/export/reader/etc/tsv2htm-bibliographics.htm'

# require
import sys
import pandas as pd

# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <tsv>\n" )
	quit()

# get input
tsv    = sys.argv[ 1 ]

# slurp up the given file
df = pd.read_csv( tsv, sep='\t' )

rows = ''
for index, row in df.iterrows() :
	
	# parse
	id     = str( row[ 'id' ] )
	author = str( row[ 'author' ] )
	title  = str( row[ 'title' ] )
	date  = str( row[ 'date' ] )
	words  = str( row[ 'words' ] )
	sentences  = str( row[ 'sentences' ] )
	pages  = str( row[ 'pages' ] )
	cache  = str( row[ 'cache' ] )
	text  = str( row[ 'txt' ] )
	
	# build
	rows = rows + "<tr><td>" + id + "</td><td>" + author + "</td><td>" + title + "</td><td>" + date + "</td><td>" + words + "</td><td>" + sentences + "</td><td>" + pages + "</td><td>" + cache + "</td><td>" + text + "</td></tr>\n"
	
# slurp up the template and do the substitution
with open( TEMPLATE, 'r' ) as handle : htm = handle.read()
htm = htm.replace( '##ROWS##', rows )

# output and done
print( htm )
exit()