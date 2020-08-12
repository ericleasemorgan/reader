#!/usr/bin/env python

# txt2keywords-cord.sh - given a file, output a tab-delimited list of keywords

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June     26, 2018 - first cut
# June     24, 2018 - lemmatized output
# December 23, 2019 - started using Textacy
# March    18, 2020 - eliminated words less than three characters long; ought to explore stop words


# configure
NGRAMS  = 1
TOPN    = 0.005
MAXIMUM = 3000000 # arbitrary
WRD     ='./cord/wrd'

# require
from textacy.ke.yake import yake
import os
import spacy
import sys
import textacy.preprocessing

# sanity check
if len( sys.argv ) < 2 :
	exit('Usage: ' + sys.argv[ 0 ] + " [<file1> [<file2> ...]]\n" )

def process_file(key, input_filename, output_filename):
	# open the given file and unwrap it
	text = ''
	with open( input_filename, 'r' ) as f : text = f.read()

	text = textacy.preprocessing.normalize.normalize_quotation_marks( text )
	text = textacy.preprocessing.normalize.normalize_hyphenated_words( text )
	text = textacy.preprocessing.normalize.normalize_whitespace( text )

	doc = model( text )

	with open( output_filename, 'w') as handle:
		# output a header
		print( "id\tkeyword", file=handle )

		# process and output each keyword and done; can't get much simpler
		for keyword, score in ( yake( doc, ngrams=NGRAMS, topn=TOPN ) ) :

			if ( len( keyword ) < 3 ) : continue
			print( "\t".join( [ key, keyword ] ), file=handle )

# initialize model
model = spacy.load( 'en', max_length=MAXIMUM )

# process each given file
for file_name in sys.argv[ 1: ] :

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
