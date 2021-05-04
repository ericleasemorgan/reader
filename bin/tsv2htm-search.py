#!/usr/bin/env python

# tsv2htm-search.py - given a previously staged template file and a set of bibliographics, output a stream of HTML

# Maria Carroll <mcarro10@nd.edu>
# June 25, 2020 - first working version


# pre-require and configure
import os
READERCORD_HOME = os.environ[ 'READERCORD_HOME' ]


# configure; the file created from the output of carrel2search.pl
TEMPLATE = READERCORD_HOME + '/tmp/search.htm'

# require
import sys
import pandas as pd

# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <tsv>\n" )
	exit()

# get input
tsv = sys.argv[ 1 ]

# slurp up the given file
df = pd.read_csv( tsv, sep='\t', error_bad_lines=False )

rows = ''
for index, row in df.iterrows() :	
	# parse
	id        = str( row[ 'id' ] )
	author    = str( row[ 'author' ] )
	title     = str( row[ 'title' ] )
	date      = str( row[ 'date' ] )
	words     = str( row[ 'words' ] )
	sentences = str( row[ 'sentences' ] )
	pages     = str( row[ 'pages' ] )
	cache     = str( row[ 'cache' ] )
	text      = str( row[ 'txt' ] )
	summary   = str(row[ 'summary' ])
	flesch    = str(row[ 'flesch' ])
	path      = '../txt/' + id + '.txt'
	linkedtitle = "<a href=" + path + ">" + title + "</a>"
	# build
	rows = rows + "<tr><td>" + linkedtitle + "<table class='display'><tr><td>" +  summary + "</td></tr></table></td>" + "<td>" +  author + "</td><td>" + id + "</td><td>" + date + "</td><td>" + words + "</td><td>" + flesch + "</td><td>" + "<button type = 'button' onclick='Expand()' class='btn-primary'>" + "+" + "</button>" + "<button type = 'button' onclick='Collapse()' class='btn-primary'>" + "-" + "</button>" + "</td></tr>\n"
# slurp up the template and do the substitution
with open( TEMPLATE, 'r' ) as handle : htm = handle.read()
htm = htm.replace( '##ROWS##', rows )
# output and done
print( htm )
exit()
