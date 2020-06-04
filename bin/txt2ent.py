#!/usr/bin/env python

# txt2ent.py - given a plain text file, output a tab-delimited file of named entitites

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 1, 2018 - first cut, or there abouts

# Charlie Harper <crh92@case.edu>
# June 6, 2020 - added language models for biomedical text

# require
from nltk import *
import os
import re
import scispacy
import spacy
import sys

#list of models to use in NER
MODELS = ['en_core_web_lg', 'en_ner_craft_md', 'en_ner_jnlpba_md', 'en_ner_bc5cdr_md']

# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <file>\n" )
	quit()

# initialize
file = sys.argv[ 1 ]


# limit ourselves to a few processors only
#os.system( "taskset -pc 0-1 %d > /dev/null" % os.getpid() )

# open the given file and unwrap it
text = open( file, 'r' ).read()
text = re.sub( '\r', '\n', text )
text = re.sub( '\n+', ' ', text )
text = re.sub( '^\W+', '', text )
text = re.sub( '\t', ' ',  text )
text = re.sub( ' +', ' ',  text )

# begin output, the header
print( "\t".join( [ 'id', 'sid', 'eid', 'entity', 'type' ] ) )

# parse the text into sentences and process each one
key = os.path.splitext( os.path.basename( file ) )[0]


e = 0
for model in MODELS:
	nlp  = spacy.load(model)
	doc = nlp(text)
	for s, sentence in enumerate(doc.sents, 1):
		for entity in sentence.ents:
			e+=1
			print( "\t".join([key, str(s), str(e), entity.text, entity.label_ ]))

quit()
