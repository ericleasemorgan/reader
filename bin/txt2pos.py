#!/afs/crc.nd.edu/user/e/emorgan/local/anaconda/bin/python

# txt2pos.py - given a plain text file, output a tab-delimited file of parts-of-speech

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 1, 2018 - first cut, or there abouts


# require
from nltk import *
import os
import re
import spacy
import sys

# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <file>\n" )
	quit()

# initialize
file = sys.argv[ 1 ]
nlp  = spacy.load( 'en' )

# limit ourselves to a few processors only
os.system( "taskset -pc 0-1 %d > /dev/null" % os.getpid() )

# open the given file and unwrap it
handle = open( file, 'r' )
text   = handle.read()
text   = re.sub( '\r', '\n', text )
text   = re.sub( '\n+', ' ', text )
text   = re.sub( ' +', ' ', text )
text   = re.sub( '^\W+', '', text )

# initialize output, the header
print( "\t".join( [ 'id', 'sid', 'tid', 'token', 'lemma', 'pos' ] ) )

# parse the text into sentences and process each one
s         = 0
key       = os.path.splitext( os.path.basename( file ) )[0]
sentences = sent_tokenize( text )
for sentence in nlp.pipe( sentences, n_threads=1 ) :
		
	# increment
	s += 1 
	t  = 0
	
	# process each token
	for token in sentence : 
	
		# increment and output
		t += 1
		print( "\t".join( [ key, str( s ), str( t ), token.text, token.lemma_, token.tag_ ] ) )
	
# done
quit()
