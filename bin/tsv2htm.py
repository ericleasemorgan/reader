#!//usr/bin/env python

# configure
TEMPLATE = '/export/reader/etc/tsv2htm.htm'

# require
import sys
import pandas as pd

# sanity check
if len( sys.argv ) != 3 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <type> <tsv>\n" )
	quit()

# get input
type = sys.argv[ 1 ]
tsv = sys.argv[ 2 ]

# slurp up the given file
df = pd.read_csv( tsv, sep='\t' )

rows = ''
for index, row in df.iterrows() :
	
	# parse
	item      = str( row[ type ] )
	frequency = str( row[ 'frequency' ] )
	
	# build
	rows = rows + "<tr><td>" + item + "</td><td>" + frequency + "</td></tr>\n"
	
# slurp up the template and do the substitution
with open( TEMPLATE, 'r' ) as handle : htm = handle.read()
htm = htm.replace( '##ROWS##', rows )
htm = htm.replace( '##TYPE##', type )

# output and done
print( htm )
exit()