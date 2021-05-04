#!/usr/bin/env python

# topic-model.py - given a directory of plain text files, compute t topics with d dimensions
# see -> https://scikit-learn.org/stable/auto_examples/applications/plot_topics_extraction_with_nmf_lda.html#sphx-glr-auto-examples-applications-plot-topics-extraction-with-nmf-lda-py

# Eric Lease Morgan <emorgan@nd.edu>
# June 8, 2019 - re-wrote to use LDA; output pie chart
# July 9, 2020 - added customized stop word list


# pre-require and configure
import os
READERCORD_HOME = os.environ[ 'READERCORD_HOME' ]


# configure
STOPWORDS = READERCORD_HOME + '/etc/stopwords.txt'

# require
from sklearn.decomposition import LatentDirichletAllocation
from sklearn.feature_extraction.text import CountVectorizer
import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd
import sys

# make sane; check for input
if len( sys.argv ) < 4 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <directory> <topics> <dimensions> [outfile]\n" )
	exit()

# get input
directory  = sys.argv[ 1 ]
topics     = int( sys.argv[ 2 ] )
dimensions = int( sys.argv[ 3 ] )

# slurp up stopwords
handle    = open( STOPWORDS, 'r' )
stopwords = handle.read().split( '\n' )
handle.close()

# initialize
filenames  = [ os.path.join( directory, filename ) for filename in os.listdir( directory ) ]
vectorizer = CountVectorizer( input = 'filename', stop_words=stopwords )
model      = LatentDirichletAllocation( n_components=topics, learning_method='batch', random_state = 1 )


# count & tabulate all words in all files, and then create the model
vectors = vectorizer.fit_transform( filenames )
model.fit( vectors )

# extract features and associate modeled topics with documents
features  = vectorizer.get_feature_names()
documents = pd.DataFrame( model.transform( vectors ) )

# create a dictionary of results
results = {}
for index, matrix in enumerate( model.components_ ):
	totals           = int( np.sum( matrix ) )
	words            = " ".join( [ features[ i ] for i in matrix.argsort()[ :-dimensions - 1:-1 ] ] )
	results[ index ] = [ totals, words ]

# stuff the results into a dataframe, which is easier to manipulate
df = pd.DataFrame.from_dict( results, orient='index', columns = [ 'totals', 'words' ] )

# create lists document identifiers (keys) sorted by topic scores
keys = {}
for index, row in df.iterrows() :
	documents.sort_values( by=[ index ], ascending=False, inplace=True )
	keys[ index ] = ';'.join( [ filenames[ key ] for key in list( documents.index.values ) ] )

# update the dataframe, sort, and output
df[ 'keys' ] = keys.values()
df.sort_values( by=[ 'totals' ], ascending = False, inplace=True )
print( df.to_csv( header=False, sep='\t' ) )

# conditionally visualize
if len( sys.argv ) == 5:
	outfile = sys.argv[ 4 ]
	figure, axis = plt.subplots( figsize=( 6, 6 ) )
	axis.pie( df[ 'totals' ], startangle = 0 )
	axis.legend( title = "Topics", labels = df[ 'words' ] )
	figure.savefig( outfile )

# done
exit()

