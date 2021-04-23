#!/usr/bin/env python

# pre-require and configure
import os
READERCORD_HOME = os.environ[ 'READERCORD_HOME' ]


# configure
TEMPLATE = READERCORD_HOME + '/etc/tsv2htm-questions.htm'

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
	identifier = str( row[ 'identifier' ] )
	question   = str( row[ 'question' ] )
	
	# build
	rows = rows + "<tr><td>" + identifier + "</td><td>" + question + "</td></tr>\n"
	
# slurp up the template and do the substitution
with open( TEMPLATE, 'r' ) as handle : htm = handle.read()
htm = htm.replace( '##ROWS##', rows )

# output and done
print( htm )
exit()