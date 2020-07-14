#!/usr/bin/env python

# txt2keywords-cord.sh - given a file, output a tab-delimited list of keywords

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June     26, 2018 - first cut
# June     24, 2018 - lemmatized output
# December 23, 2019 - started using Textacy
# March    18, 2020 - eliminated words less than three characters long; ought to explore stop words


# configure
NGRAMS = 1
TOPN   = 0.005

# require
from textacy.ke.yake import yake
import os
import spacy
import sys
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
doc     = model( text )

# output a header
print( "id\tkeyword" )

# process and output each keyword and done; can't get much simpler
for keyword, score in ( yake( doc, ngrams=NGRAMS, topn=TOPN ) ) :

	if ( len( keyword ) < 3 ) : continue
	print( "\t".join( [ id, keyword ] ) )
	
exit()
