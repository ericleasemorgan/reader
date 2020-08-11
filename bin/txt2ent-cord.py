#!/usr/bin/env python

# txt2ent-cord.py - given a plain text file, output a tab-delimited file of named entitites

# Don Brower <dbrower@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July    1, 2018 - first cut (or there abouts) by Eric Morgan
# August 11, 2020 - completely re-written to exploit a parallel processing; requires a lot of RAM


# configure
MODEL = 'en_ner_bionlp13cg_md'
ENT   = './cord/ent'

# require
import os
import re
import scispacy
import spacy
import sys

# sanity check
if len( sys.argv ) < 2 : sys.exit( "Usage: " + sys.argv[ 0 ] + " <file1> [<file2> ... ]" )

# extract named entities and output them to a file; the hard work gets done here
def process_file( key, input_filename, output_filename):
	
	# open the given file and unwrap it
	text = ''
	with open( input_filename, 'r' ) as f : text = f.read()

	# consolidate whitespace
	text = re.sub( r'\W+', ' ', text )

	# create output file
	with open( output_filename, 'w' ) as handle :

		# begin output, the header
		print( "\t".join( [ 'id', 'sid', 'eid', 'entity', 'type' ] ), file=handle )

		# initialize the model and model the text; might benefit from "disabling" something
		maximum = len( text ) + 1
		nlp     = spacy.load( MODEL, max_length=maximum )
		doc     = nlp( text )
		
		# process each sentence in the document
		for s, sentence in enumerate( doc.sents, 1 ) :
		
			# re-initialize
			e = 0
			
			# process each entity in the given sentence
			for entity in sentence.ents :
				
				# increment and output
				e += 1
				print( "\t".join( [key, str(s), str(e), entity.text, entity.label_ ] ), file=handle )


# process each given file
for file_name in sys.argv[ 1: ] :

	# get the key and compute the output file name
	key         = os.path.splitext( os.path.basename( file_name ) )[0]
	output_file = os.path.join( ENT, key + ".ent" )
	
	# don't do the work if it has already been done
	if os.path.isfile( output_file ) : continue

	# try to do the work
	try : process_file( key, file_name, output_file )
	
	# output unsuccessful tries
	except ValueError as err : print( key, err )

# done
exit
