#!/usr/bin/env python

# txt2keywords.sh - given a file, output a tab-delimited list of keywords

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License


# June     26, 2018 - first cut
# June     24, 2018 - lemmatized output
# December 23, 2019 - started using Textacy
# March    18, 2020 - eliminated words less than three characters long; ought to explore stop words

# Charlie Harper <crh92@case.edu>

# June 	   10, 2020 - converted model from yake to scake to improve keywords

# configure
TOPN   = 0.005

# require
import textacy.preprocessing
from textacy.ke.scake import scake
from textacy.ke.yake import yake
import spacy
import os
import sys


# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <file>\n" )
	quit()

# initialize
file = sys.argv[ 1 ]

# open the given file and unwrap it
with open(file) as f:
	text = f.read()

text = textacy.preprocessing.normalize.normalize_quotation_marks( text )
text = textacy.preprocessing.normalize.normalize_hyphenated_words( text )
text = textacy.preprocessing.normalize.normalize_whitespace( text )

# compute the identifier
id = os.path.basename( os.path.splitext( file )[ 0 ] )

# initialize model
maximum = len( text ) + 1
model   = spacy.load( 'en_core_web_sm', max_length=maximum )
doc     = model( text )

# output a header
print( "id\tkeyword" )

#list to keep track of already found keywords and avoid duplicates
keywords = []

# process and output each keyword with yake, will produce unigrams
for keyword, score in ( yake( doc,  topn=TOPN ) ) :
	if keyword not in keywords:
		print( "\t".join( [ id, keyword ] ) )
		keywords.append(keyword)

# process and output each keyword with scake, will typically produce keyphrases
# removing lemmatization with normalize=None seems to produce better results
for keyword, score in ( scake( doc, normalize=None, topn=TOPN ) ) :
	if keyword not in keywords:
		print( "\t".join( [ id, keyword ] ) )
		keywords.append(keyword)

exit()
