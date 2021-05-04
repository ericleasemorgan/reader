#!/usr/bin/env python

# tsv2htm-entities.py - give a type of value and its corresponding TSV file, output a searchable, sortable, browsable HTML file

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public license

# December 27, 2019 - first documentation; sorted dataframe and truncated it for gradual degradation

# pre-require and configure
import os
READERCORD_HOME = os.environ[ 'READERCORD_HOME' ]

# configure
TEMPLATE = READERCORD_HOME + '/etc/tsv2htm-entities.htm'
MAXIMUM  = 2500

# require
import sys
import pandas as pd

# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + "<tsv>\n" )
	quit()

# get input
tsv    = sys.argv[ 1 ]

# slurp up the given file, sort it, and truncate it
df = pd.read_csv( tsv, sep='\t' )
df = df.sort_values( by='frequency', ascending=False )
df = df.head( n=MAXIMUM )

rows = ''
for index, row in df.iterrows() :
	
	# parse
	entity    = str( row[ 'entity' ] )
	type      = str( row[ 'type' ] )
	frequency = str( row[ 'frequency' ] )
	
	# build
	rows = rows + "<tr><td>" + entity + "</td><td>" + type + "</td><td>" + frequency + "</td></tr>\n"
	
# slurp up the template and do the substitution
with open( TEMPLATE, 'r' ) as handle : htm = handle.read()
htm = htm.replace( '##ROWS##', rows )

# output and done
print( htm )
exit()