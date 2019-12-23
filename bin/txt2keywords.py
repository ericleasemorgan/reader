#!/usr/bin/env python

# txt2keywords.sh - given a file, output a tab-delimited list of keywords

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June     26, 2018 - first cut
# June     24, 2018 - lemmatized output
# December 23, 2019 - started using Textacy


# configure
NGRAMS = 1
TOPN   = 0.003

# require
from textacy.ke.yake import yake
import spacy
import sys, os
import textacy.preprocessing

# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <file>\n" )
	quit()

# initialize
file = sys.argv[ 1 ]

# open the given file and unwrap it
text = open( file ).read()
text = textacy.preprocessing.normalize.normalize_quotation_marks( text )
text = textacy.preprocessing.normalize.normalize_hyphenated_words( text )
text = textacy.preprocessing.normalize.normalize_whitespace( text )

# compute the identifier
id = os.path.basename( os.path.splitext( file )[ 0 ] )

# initialize model
maximum = len( text ) + 1
model   = spacy.load( 'en', max_length=maximum )

# model the data; this needs to be improved
doc = model( text )

# output a header
print( "id\tkeyword" )

# process and output each keyword and done; can't get much simpler
for keyword, score in ( yake( doc, ngrams=NGRAMS, topn=TOPN ) ) : print( "\t".join( [ id, keyword ] ) )
exit()
