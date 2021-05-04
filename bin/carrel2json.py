#!/usr/bin/env python

# carrel2json.py - given the short name of a Distant Reader study carrel, output a JSON file denoting relationships between parts-of-speech

# originally written by Team JAMS (Aarushi Bisht, Cheng Jial, Mel Mashiku, and Shivam Rastogi) as a function call for the PEARC '19 Hack-a-thon
# re-written as a script by Eric Lease Morgan <emorgan@nd.edu>

# August  7, 2019 - first documentation
# August 17, 2019 - in preparation of creating an additional repository, removed harvesting of content


# configure
PUNCTUATION = '!"#$%&()*+,-./:;<=>?@[\\]^_`{|}~\t\n'
POS         = 'NN'
WEIGHT      = 0

# require
from itertools import combinations
import glob
import json
import numpy as np
import os
import pandas as pd
import sys

# define
def remove_puncutation( word ) :
	for p in PUNCTUATION :
		if p in word : return ''
	return word

# slurp up the study carrel
for path in glob.glob( './pos/*.pos' ) :
	try    : df = pd.read_csv( path, sep='\t' )
	except : continue
	else   : break

noun       = df[ df[ 'pos' ] == POS ]
number     = noun.lemma.value_counts()
clean_noun = list( set( [ remove_puncutation( word ) for word in noun.lemma ] ) )

try    : clean_noun.remove('')
except : pass
noun = noun[ noun[ 'lemma' ].isin( clean_noun ) ]

result = pd.DataFrame( list( combinations( clean_noun, 2 ) ), columns=[ 'token1', 'token2' ] )
result[ 'weight' ] = np.zeros( result.shape[ 0 ] )
result = result.loc[ result.index[ : result.shape[ 0 ] ] ]

# count
for i in noun.sid.unique() :
	temp       = noun[ noun[ 'sid' ] == i ]
	temp_lemma = list(set(combinations(temp.lemma.values, 2)))
	for i in temp_lemma :
		value_to_be_add = result[ ( result[ 'token1' ] == i[ 0 ] ) & ( result[ 'token2' ] == i[ 1 ] ) ]
		result.loc[ value_to_be_add.index, 'weight' ] += 1
		value_to_be_add = result[ ( result[ 'token1' ] == i[ 1 ] ) & ( result[ 'token2' ]==i[ 0 ] ) ]
		result.loc[ value_to_be_add.index, 'weight' ] += 1

clean_result  = result[ result[ 'weight' ] > WEIGHT ]
data          = {}
data['nodes'] = []
data['links'] = []

for token in clean_noun :
	size = int( number.loc[ token ] )
	if size > 0 : data[ 'nodes' ].append( { "id":token, "group":1, "size": size } )
for row in clean_result.iterrows() : data[ 'links' ].append( { "source" : row[ 1 ].token1, "target":row[ 1 ].token2, "value":row[ 1 ].weight } )

# output and done
print( json.dumps( data, indent=2 ) )
exit()
