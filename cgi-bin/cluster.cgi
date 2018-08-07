#!/usr/local/anaconda/bin/python

# cluster.cgi- given a directory of plain text files as well as type of visualization, cluster a set of documents
# see --> https://de.dariah.eu/tatom/working_with_text.html

# Eric Lease Morgan <emorgan@nd.edu>

# May   22, 2018 - first cut as a CGI script
# August 7, 2018 - started moving to Distant Reader


# configure
MAXIMUM    = 0.95
MINIMUM    = 2
STOPWORDS  = 'english'
EXTENSION  = '.txt'
DIRECTORY  = '../carrels/##ID##/txt'
IMAGE      = '../tmp/cluster.jpg'

# require
from mpl_toolkits.mplot3d import Axes3D
from scipy.cluster.hierarchy import ward, dendrogram
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.manifold import MDS
from sklearn.metrics.pairwise import cosine_similarity
import matplotlib
matplotlib.use( 'Agg' )
import matplotlib.pyplot as plt
import numpy as np
import os
import sys
import cgi
import cgitb

# initialize
cgitb.enable()
print( 'Content-Type: text/html\n' )
input = cgi.FieldStorage()

# check for input; build default page
if "graphic" not in input or "id" not in input :

	print ( '''<html><head><title>Distant Reader - Cluster</title><meta name="viewport" content="width=device-width, initial-scale=1.0"><link rel="stylesheet" href="/reader/etc/style.css"></head><body><div class="header"><h1>Distant Reader - Cluster</h1></div><div class="col-3 col-m-3 menu"><ul><li><a href="/reader/home.html">Home</a></li><li><a href="/reader/about/">About</a></li></ul></div><div class="col-9 col-m-9"><p>Visualize (cluster) the given study carrel in one of two ways:</p><form method="GET" action="/reader/cgi-bin/cluster.cgi">ID: <input type="text" name="id" /><br />Image: <input type="radio" name="graphic" value="cube" checked> cube</input> <input type="radio" name="graphic" value="dendrogram"> dendrogram</input><br /><input type="submit" value="Cluster" /></form><div class="footer"><p style="text-align: right">Eric Lease Morgan &amp; Team Distant Reader<br />August 7, 2018</p></div></div></body></html>''' )

# do the work
else :

	# initialize & compute
	graphic    = input[ 'graphic' ].value
	directory  = DIRECTORY.replace( '##ID##', input[ 'id' ].value )	
	filenames  = [ os.path.join( directory, filename ) for filename in os.listdir( directory ) ]
	vectorizer = TfidfVectorizer( input='filename', max_df=MAXIMUM, min_df=MINIMUM, stop_words=STOPWORDS )
	matrix     = vectorizer.fit_transform( filenames ).toarray()
	distance   = 1 - cosine_similarity( matrix )
	keys       = [ os.path.basename( filename ).replace( EXTENSION, '' ) for filename in filenames ] 

	# branch according to configuration; visualize
	if graphic == 'dendrogram' :
		linkage_matrix = ward( distance )
		dendrogram( linkage_matrix, orientation="right", labels=keys )
		plt.tight_layout() 
	
	elif graphic == 'cube' :
		mds = MDS( n_components=3, dissimilarity="precomputed", random_state=1 )
		pos = mds.fit_transform( distance )
		fig = plt.figure()
		ax  = fig.add_subplot( 111, projection='3d' )
		ax.scatter( pos[ :, 0 ], pos[ :, 1 ], pos[ :, 2 ] )
		for x, y, z, s in zip( pos[ :, 0 ], pos[ :, 1 ], pos[ :, 2 ], keys ) : ax.text( x, y, z, s )

	# output
	plt.savefig( IMAGE )
	print( '''<html><head><title>Distant Reader - Cluster</title><meta name="viewport" content="width=device-width, initial-scale=1.0"><link rel="stylesheet" href="/english/etc/style.css"></head><body><div class="header"><h1>Distant Reader - Cluster</h1></div><div class="col-3 col-m-3 menu"><ul><li><a href="/reader/home.html">Home</a></li><li><a href="/reader/about/">About</a></li></ul></div><div class="col-9 col-m-9"><img src='http://cds.crc.nd.edu/reader/tmp/cluster.jpg'/><div class="footer"><p style="text-align: right">Eric Lease Morgan &amp; Team Distant Reader<br />August 7, 2018</p></div></div></body></html>''' )

# done
exit()



