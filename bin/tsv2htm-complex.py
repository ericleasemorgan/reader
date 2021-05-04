#!/usr/bin/env python

# tsv2htm-complex.py - give a type of value and its corresponding TSV file, output a searchable, sortable, browsable HTML file

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public license

# December 27, 2019 - first documentation; sorted dataframe and truncated it for gradual degradation


# pre-require and configure
import os
READERCORD_HOME = os.environ[ 'READERCORD_HOME' ]


# configure
TEMPLATE = READERCORD_HOME + '/etc/tsv2htm-complex.htm'
MAXIMUM  = 2500

# require
import sys
import pandas as pd

# sanity check
if len( sys.argv ) != 4 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <type> <another type> <tsv>\n" )
	quit()

# get input
type01 = sys.argv[ 1 ]
type02 = sys.argv[ 2 ]
tsv    = sys.argv[ 3 ]

# slurp up the given file, sort it, and truncate it
df = pd.read_csv( tsv, sep='\t' )
df = df.sort_values( by='frequency', ascending=False )
df = df.head( n=MAXIMUM )

rows = ''
for index, row in df.iterrows() :
	
	# parse
	item01    = str( row[ 0 ] )
	item02    = str( row[ 1 ] )
	frequency = str( row[ 'frequency' ] )
	
	# build
	rows = rows + "<tr><td>" + item01 + "</td><td>" + item02 + "</td><td>" + frequency + "</td></tr>\n"
	
# slurp up the template and do the substitution
with open( TEMPLATE, 'r' ) as handle : htm = handle.read()
htm = htm.replace( '##ROWS##', rows )
htm = htm.replace( '##ITEM01##', type01 )
htm = htm.replace( '##ITEM02##', type02 )

# output and done
print( htm )
exit()