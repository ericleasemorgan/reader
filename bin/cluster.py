#!/usr/bin/env python

# cluster.py - given a directory of plain text files as well as type of visualization, cluster a set of documents
# see --> https://de.dariah.eu/tatom/working_with_text.html

# Eric Lease Morgan <emorgan@nd.edu>
# October 17, 2017 - first cut; cool, again!


# configure
MAXIMUM   = 0.95
MINIMUM   = 2
STOPWORDS = 'english'
EXTENSION = '.txt'
DIRECTORY = './txt'

# require
from mpl_toolkits.mplot3d import Axes3D
from scipy.cluster.hierarchy import ward, dendrogram
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.manifold import MDS
from sklearn.metrics.pairwise import cosine_similarity
import matplotlib.pyplot as plt
import numpy as np
import os
import sys

# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <dendrogram|cube>\n" )
	quit()

# get input
visualization = sys.argv[ 1 ]

# initialize & compute
filenames  = [ os.path.join( DIRECTORY, filename ) for filename in os.listdir( DIRECTORY ) ]
vectorizer = TfidfVectorizer( input='filename', max_df=MAXIMUM, min_df=MINIMUM, stop_words=STOPWORDS )
matrix     = vectorizer.fit_transform( filenames ).toarray()
distance   = 1 - cosine_similarity( matrix )
keys       = [ os.path.basename( filename ).replace( EXTENSION, '' ) for filename in filenames ] 

# branch according to configuration; visualize
if visualization == 'dendrogram' :
	linkage_matrix = ward( distance )
	dendrogram( linkage_matrix, orientation="right", labels=keys )
	plt.tight_layout() 

elif visualization == 'cube' :
	mds = MDS( n_components=3, dissimilarity="precomputed", random_state=1 )
	pos = mds.fit_transform( distance )
	fig = plt.figure()
	ax  = fig.add_subplot( 111, projection='3d' )
	ax.scatter( pos[ :, 0 ], pos[ :, 1 ], pos[ :, 2 ] )
	for x, y, z, s in zip( pos[ :, 0 ], pos[ :, 1 ], pos[ :, 2 ], keys ) : ax.text( x, y, z, s )

# error
else :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <dendrogram|cube>\n" )
	quit()

# output and done
plt.show()
exit()



