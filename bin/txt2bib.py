#!/usr/local/anaconda/bin/python

# txt2bib.sh - given a file, output a tab-delimited bibliographic characteristics, sort of

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 26, 2018 - first cut


# configure
COUNT=125
RATIO=0.05

# require
from textatistic import Textatistic
from gensim.summarization import summarize
import sys, re, os

# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <file>\n" )
	quit()

# read input
file = sys.argv[ 1 ]

# compute the identifier
id = os.path.basename( os.path.splitext( file )[ 0 ] )

# open the given file and unwrap it
text = open( file, 'r' ).read()
text = re.sub( '\r', '\n', text )
text = re.sub( '\n+', ' ', text )
text = re.sub( ' +', ' ', text )
text = re.sub( '^\s+', '', text )

# get all document statistics and summary
statistics = Textatistic( text )
summary = summarize( text, word_count=COUNT, split=False )
summary = re.sub( '\n+', ' ', summary )
summary = re.sub( '- ', '', summary )
summary = re.sub( '\s+', ' ', summary )

# parse out only the desired statistics
words     = statistics.word_count
sentences = statistics.sent_count
flesch    = statistics.flesch_score

# debug
#print( statistics.counts )
#print( statistics.scores )
#print (summary)

# output header, data, and then done
print( "\t".join( ( 'id', 'words', 'sentences', 'flesch', 'summary' ) ) )
print( "\t".join( ( (str(id ), str(words), str(sentences), str(flesch), summary ) ) ) )
exit
