#!/usr/bin/env python

# mallet-visualize-pivot.py - given a (MALLET) CSV file and quite a few parameters, visualize topics based on a pivot table

# require
import pandas as pd
import matplotlib.pyplot as plt
import sys

# sanity check
if len( sys.argv ) != 4 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <CSV> <bar|barh|line> <index>\n" )
	quit()

# get input
file  = sys.argv[ 1 ]
type  = sys.argv[ 2 ]
index = sys.argv[ 3 ]

# read the input
df = pd.read_csv( file, index_col='filename')
df = df.drop(['docId', 'id'], axis=1)

# get the column names, normalize them, and update the headers accordingly
topics = list( df.columns )
for i in range( 1, len( topics ) ) :
	topics[ i ] = topics[ i ].replace( ' ', '-' )
df.columns = topics

# pivot, plot, and done
table = df.pivot_table( topics, index=index )
table.plot( kind=type )
plt.show()
exit()

