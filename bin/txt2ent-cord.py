#!/usr/bin/env python

# txt2ent-cord.py - given a plain text file, output a tab-delimited file of named entitites

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 1, 2018 - first cut, or there abouts
# May 26, 202 by Jiali Cheng <cheng.jial@husky.neu.edu> - migrating to Project CORD


# configure
MODEL = 'en_ner_bionlp13cg_md'
ENT='./cord/ent'

# require
from nltk import *
import os
import re
import scispacy
import spacy
import sys

# sanity check
if len( sys.argv ) < 2 :
	sys.exit("Usage: " + sys.argv[ 0 ] + " <file1> [<file2> ... ]\n")


def process_file(key, input_filename, output_filename):
	# open the given file and unwrap it
	text = ''
	with open(input_filename, 'r') as f:
		text = f.read()

	# consolidate all whitespace runs into a single space
	text = re.sub( r'\W+', ' ', text )

	with open(output_filename, 'w') as w:
		# begin output, the header
		print( "\t".join( [ 'id', 'sid', 'eid', 'entity', 'type' ] ), file=w )

		# parse the text into sentences and process each one
		s = 0
		for sentence in sent_tokenize( text ) :

			# (re-)initialize and increment
			s += 1
			e = 0
			sentence = nlp( sentence )

			# process each entity
			for entity in sentence.ents : 

				e += 1
				print( "\t".join( [ key, str( s ), str( e ), entity.text, entity.label_ ] ), file=w )

# initialize
nlp  = spacy.load( MODEL, disable=['tagger'] )
for file_name in sys.argv[1:]:
	key = os.path.splitext( os.path.basename( file_name ) )[0]
	output_file = os.path.join(ENT, key + ".ent")
	if os.path.isfile(output_file):
		# skip if the output file has already been computed
		continue
	process_file(key, file_name, output_file)

