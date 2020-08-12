#!/usr/bin/env python

# txt2pos-cord.py - given a plain text file, output a tab-delimited file of named entitites

# Don Brower <dbrower@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# August 12, 2020 - by Eric but rooted in Don's good work


# configure
MODEL = 'en_core_web_sm'
POS   = './cord/pos'

# require
import os
import re
import spacy
import sys

# sanity check
if len( sys.argv ) < 2 : sys.exit( "Usage: " + sys.argv[ 0 ] + " <file1> [<file2> ... ]" )

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

# extract parts-of-speech and output them to a file; the hard work gets done here
def process_file( key, input_filename, output_filename):
	
	# open the given file and unwrap it
	text = ''
	with open( input_filename, 'r' ) as f : text = f.read()
	text = re.sub( r'\n+', ' ', text )

	# create output file
	with open( output_filename, 'w' ) as handle :

		# begin output, the header
		print( "\t".join( [ 'id', 'sid', 'tid', 'token', 'lemma', 'pos' ] ), file=handle )

		# apply the model to the text
		doc = nlp( text )
		
		# process each sentence in the document
		for s, sentence in enumerate( doc.sents, 1 ) :
					
			# process each token in the given sentence
			for t, token in enumerate( nlp( sentence.text ), 1 ) :
				
				# output
				print( "\t".join( [key, str(s), str(t), token.text, token.lemma_, token.tag_ ] ), file=handle )


# initailize
files = sys.argv[ 1: ]

# determine the maximum size  of our files and initialize our model; might benefit from "disabling" something
maximum = get_maximum_size( files )
nlp     = spacy.load( MODEL, max_length=maximum )

# process each given file
for input_file in files :

	# get the key and compute the output file name
	key         = os.path.splitext( os.path.basename( input_file ) )[0]
	output_file = os.path.join( POS, key + ".pos" )
	
	# don't do the work if it has already been done
	if os.path.isfile( output_file ) : continue

	# try to do the work
	try : process_file( key, input_file, output_file )
	
	# output unsuccessful tries
	except ValueError as err : print( key, err )

# done
exit
