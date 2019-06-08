#!/usr/bin/env python

# topic-model.py - given a directory of plain text files, compute t topics with d dimensions
# see -> https://scikit-learn.org/stable/auto_examples/applications/plot_topics_extraction_with_nmf_lda.html#sphx-glr-auto-examples-applications-plot-topics-extraction-with-nmf-lda-py

# Eric Lease Morgan <emorgan@nd.edu>
# June 8, 2019 - re-wrote to use LDA; output pie chart


# configure
DIRECTORY  = './txt'
TOPICS     = 5
DIMENSIONS = 5

# require
from sklearn.decomposition import LatentDirichletAllocation
from sklearn.feature_extraction.text import CountVectorizer
import matplotlib.pyplot as plt
import numpy as np
import os
import pandas as pd

# initialize the vectors
filenames  = [ os.path.join( DIRECTORY, filename ) for filename in os.listdir( DIRECTORY ) ]
vectorizer = CountVectorizer( input = 'filename', stop_words='english' )
vectors    = vectorizer.fit_transform( filenames )

# create the model
model = LatentDirichletAllocation( n_components=TOPICS, learning_method='batch', random_state = 1 )
model.fit( vectors )

# extract the features
features = vectorizer.get_feature_names()

# create a dictionary of results
results = {}
for index, matrix in enumerate( model.components_ ):
	index = index + 1
	score = int( np.sum( matrix ) )
	words = " ".join( [ features[ i ] for i in matrix.argsort()[ :-DIMENSIONS - 1:-1 ] ] )
	results[ index ] = [ score, words ]

# stuff the results into a sorted dataframe, which is easier to manipulate
df = pd.DataFrame.from_dict(results, orient='index', columns = [ 'score', 'words' ] )
df = df.sort_values( by=[ 'score' ] )

# visualize
figure, axis = plt.subplots(figsize=(6, 6))
axis.pie( df[ 'score' ], startangle = 90 )
axis.legend( title = "Topics", labels = df[ 'words' ] )
figure.savefig( './chart.png' )

# done
exit()

