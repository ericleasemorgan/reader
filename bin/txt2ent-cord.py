#!/usr/bin/env python

# txt2ent-cord.py - given a plain text file, output a tab-delimited file of named entitites

# Don Brower <dbrower@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July    1, 2018 - first cut (or there abouts) by Eric Morgan
# August 11, 2020 - completely re-written to exploit a parallel processing; requires a lot of RAM


# configure
MODELS = [ 'en_ner_jnlpba_md', 'en_ner_craft_md', 'en_core_web_sm', 'en_ner_bc5cdr_md' ]
ENT   = './cord/ent'

# require
import os
import re
import scispacy
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

# extract named entities and output them to a file; the hard work gets done here
def process_file( key, input_filename, output_filename):
	
	# open the given file and unwrap it
	text = ''
	with open( input_filename, 'r' ) as f : text = f.read()

	# consolidate whitespace and get the length of the document
	text = re.sub( r'\W+', ' ', text )
	size = len( text ) + 1

	# create output file
	with open( output_filename, 'w' ) as handle :

		# begin output, the header
		print( "\t".join( [ 'id', 'sid', 'eid', 'entity', 'type' ] ), file=handle )

		# process each model
		for model in MODELS:
		
			# debug
			#sys.stderr.write( 'model:' + model + "\n" )
			
			# load the model and model the text
			nlp            = spacy.load( model)
			nlp.max_length = size
			doc = nlp( text )
		
			# process each sentence in the document
			for s, sentence in enumerate( doc.sents, 1 ) :
		
				# re-initialize
				e = 0
			
				# process each entity in the given sentence
				for entity in sentence.ents :
				
					# increment and output
					e += 1
					print( "\t".join( [key, str(s), str(e), entity.text, entity.label_ ] ), file=handle )


# initailize
files = sys.argv[ 1: ]

# determine the maximum size  of our files and initialize our model; might benefit from "disabling" something
#maximum = get_maximum_size( files )
#nlp     = spacy.load( MODEL, max_length=maximum )

# process each given file
for input_file in files :

	# get the key and compute the output file name
	key         = os.path.splitext( os.path.basename( input_file ) )[0]
	output_file = os.path.join( ENT, key + ".ent" )
	
	# don't do the work if it has already been done
	if os.path.isfile( output_file ) : continue

	# try to do the work
	try : process_file( key, input_file, output_file )
	
	# output unsuccessful tries
	except ValueError as err : print( key, err )

# done
exit
