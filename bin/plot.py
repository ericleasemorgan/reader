#!/usr/bin/env python

# plot.py - given an input file name, type of plot, and output file name, visualize a simple tsv file

# require
import pandas as pd
import matplotlib.pyplot as plt
import sys

# sanity check
if len( sys.argv ) != 4 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <input file> <histogram|boxplot> <output file>\n" )
	exit()

# initialize
input        = sys.argv[ 1 ]
type         = sys.argv[ 2 ]
output       = sys.argv[ 3 ]
df           = pd.read_csv( input, sep='\t')
figure, axis = plt.subplots()

# branch according to option
if   type == 'histogram' : df.hist( ax=axis )
elif type == 'boxplot'   : df.boxplot( ax=axis )
else : 
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <input file> <histogram|boxplot> <output file>\n" )
	exit()

# save and done
figure.savefig( output )
exit()