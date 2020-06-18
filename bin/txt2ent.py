#!/usr/bin/env python

# txt2ent.py - given a plain text file, output a tab-delimited file of named entitites

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 1, 2018 - first cut, or there abouts
# May 26, 202 by Jiali Cheng <cheng.jial@husky.neu.edu> - migrating to Project CORD
# June 6, 2020 - added language models for biomedical text; Charlie Harper <crh92@case.edu> 
# June 8, 2020 - added maximum length to accommodate large files


# configure
MODELS = [ 'en_ner_jnlpba_md', 'en_ner_craft_md', 'en_core_web_sm', 'en_ner_bc5cdr_md' ]

# require
from nltk import *
import os
import re
import scispacy
import spacy
import sys

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

# loop through each model
e = 0
for model in MODELS :

	maximum = len( text ) + 1
	sys.stderr.write( 'model:' + model + "\n" )
	nlp  = spacy.load( model, max_length=maximum )
	doc = nlp(text)
	for s, sentence in enumerate( doc.sents, 1 ):
		for entity in sentence.ents:
			e+=1
			print( "\t".join([key, str(s), str(e), entity.text, entity.label_ ]))

# done
quit()
