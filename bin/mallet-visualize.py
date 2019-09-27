#!/usr/bin/env pythonw

# mallet-visualize.py - given a (MALLET) CSV file, illustrate the "topics"

# require
import pandas as pd
import matplotlib.pyplot as plt
import sys

# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <CSV>\n" )
	quit()

# get input
file = sys.argv[ 1 ]

# create a data frame and drop unnecessary column
df = pd.read_csv( file, index_col='filename' )
df = df.drop('docId', axis=1)

# sort the frame, visualize, and done
df.sort_index( inplace=True )
df.plot( kind='barh', stacked=True )
plt.show()
exit()
