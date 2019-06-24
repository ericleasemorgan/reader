#!/usr/bin/env python

# txt2keywords.sh - given a file, output a tab-delimited list of keywords

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 26, 2018 - first cut
# June 24, 2018 - lemmatized output


# configure
RATIO = 0.01

# require
from gensim.summarization import keywords
import sys, re, os

# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <file>\n" )
	quit()

# initialize
file = sys.argv[ 1 ]

# open the given file and unwrap it
text = open( file, 'r' ).read()
text = re.sub( '\r', '\n', text )
text = re.sub( '\n+', ' ', text )
text = re.sub( '^\W+', '', text )
text = re.sub( '\t', ' ',  text )
text = re.sub( ' +', ' ',  text )

# compute the identifier
id = os.path.basename( os.path.splitext( file )[ 0 ] )

# output a header
print( "id\tkeyword" )

# process each keyword; can't get much simpler
for keyword in keywords( text, ratio=RATIO, split=True, lemmatize=True ) : print( "\t".join( ( id, keyword ) ) )

# done
quit()
