#!/usr/bin/env python

# search.py - query a semantic (word2vec) index

# Eric Lease Morgan <eric_morgan@infomotions.com>
# October 17, 2018 - first documentation


# configure
VECTORS = './etc/reader.vec'
N   = 10

# require
from gensim.models import KeyedVectors
import sys

# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <word>\n" )
	exit()


# load the index
index = KeyedVectors.load( VECTORS, mmap = 'r' )

# search and output
for word, score in index.most_similar( positive = sys.argv[ 2 ], topn = N ) :
	print( "\t".join( [ word, str( score ) ] ) )

# done
exit()
