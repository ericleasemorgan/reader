#!/usr/bin/env python

# txt2keywords-cord.sh - given a file, output a tab-delimited list of keywords

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June     26, 2018 - first cut
# June     24, 2018 - lemmatized output
# December 23, 2019 - started using Textacy
# March    18, 2020 - eliminated words less than three characters long; ought to explore stop words
# November 21, 2020 - changed (upgraded) model


# configure
NGRAMS  = 1
TOPN    = 0.005
WRD     = './cord/wrd'
MODEL   = 'en_core_web_lg'

# require
from textacy.ke.yake import yake
import os
import spacy
import sys
import re

# sanity check
if len( sys.argv ) < 2 : exit('Usage: ' + sys.argv[ 0 ] + " [<file1> [<file2> ...]]" )

# return maximum size of a set of files
def get_maximum_size( files ) :
	
	# initialize
	maximum = 0
	
	# process each file
	for file in files :

		# get the size, compare, and conditionally update
		size = os.stat( file ).st_size
		if size > maximum : maximum = size
		
	# increase by one and done
	maximum += 1
	return maximum

def process_file(key, input_filename, output_filename):
	
	# open the given file and unwrap it
	text = ''
	with open( input_filename, 'r' ) as f : text = f.read()

	# consolidate whitespace
	text = re.sub( r'\n+', ' ', text )

	doc = nlp( text )

	with open( output_filename, 'w') as handle:
		# output a header
		print( "id\tkeyword", file=handle )

		# process and output each keyword and done; can't get much simpler
		for keyword, score in ( yake( doc, ngrams=NGRAMS, topn=TOPN ) ) :

			if ( len( keyword ) < 3 ) : continue
			print( "\t".join( [ key, keyword ] ), file=handle )

# initailize
files = sys.argv[ 1: ]

# determine the maximum size  of our files and initialize our model; might benefit from "disabling" something
maximum = get_maximum_size( files )
nlp     = spacy.load( MODEL, max_length=maximum )

# process each given file
for file_name in files :

	# get the key and compute the output file name
	key         = os.path.splitext( os.path.basename( file_name ) )[0]
	output_file = os.path.join( WRD, key + ".wrd" )
	
	# don't do the work if it has already been done
	if os.path.isfile( output_file ) : continue

	# try to do the work
	try : process_file( key, file_name, output_file )
	
	# output unsuccessful tries
	except ValueError as err : print( key, err )

# done
exit
