#!/usr/bin/env python

# file2bib.py - given a file name, output metadata as a TSV file

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# July       6, 2019 - first working version
# July       7, 2019 - combined with txt2bib.py
# September  1, 2019 - added cache and txt fields
# September 11, 2019 - looked for previously created bibliographic data
# December  23, 2019 - started using Textacy


# configure
COUNT    = 150
RATIO    = 0.05
CACHE    = './cache'
TXT      = './txt'
DATABASE = './etc/reader.db'

# require
from gensim.summarization import summarize
from sqlalchemy import create_engine
from tika import detector
from tika import language
from tika import parser
import pandas as pd
import spacy
import sys, re, os
import textacy
import textacy.preprocessing

# sanity check
if len( sys.argv ) != 2 :
	sys.stderr.write( 'Usage: ' + sys.argv[ 0 ] + " <file>\n" )
	exit()

# initialize
author     = ''
file       = sys.argv[ 1 ]
title      = os.path.splitext( os.path.basename( file ) )[ 0 ]
extension  = os.path.splitext( os.path.basename( file ) )[ 1 ]
id         = title
date       = ''
pages      = ''
txt        = TXT + '/' + id + '.txt'
cache      = CACHE + '/' + id + extension
engine     = create_engine( 'sqlite:///' + DATABASE )

# extract mime-type, just in case
mimetype = detector.from_file( file )

# extract metadata
parsed = parser.from_file( file )
metadata = parsed[ "metadata" ] 

# get (possible) pre-existing bibliographic values
escape = id.replace( "'", "''" )
query          = 'SELECT id, author, title, date FROM bib where id is "{}"'.format( escape )
bibliographics = pd.read_sql_query( query, engine, index_col='id' )

# parse author
if ( bibliographics.loc[ escape ,'author'] ) : author = bibliographics.loc[ escape,'author']
else :
	if 'creator' in metadata :
		author = metadata[ 'creator' ]
		if ( isinstance( author, list ) ) : author = author[ 0 ]
	
# title
if ( bibliographics.loc[ id ,'title'] ) : title = bibliographics.loc[ id, 'title']
else :
	if 'title' in metadata :
		title = metadata[ 'title' ]
		if ( isinstance( title, list ) ) : title = title[ 0 ]
		title = ' '.join( title.split() )
	
# date
if ( bibliographics.loc[ id ,'date'] ) : date = bibliographics.loc[ id, 'date']
else :
	if 'date' in metadata :
		date = metadata[ 'date' ]
		date = date[:date.find( 'T' ) ]

# number of pages
if 'xmpTPg:NPages' in metadata : pages = metadata[ 'xmpTPg:NPages' ]

# debug
sys.stderr.write( "         id: " + id + "\n" )
sys.stderr.write( "     author: " + author + "\n" )
sys.stderr.write( "      title: " + title + "\n" )
sys.stderr.write( "       date: " + date + "\n" )
sys.stderr.write( "      pages: " + pages + "\n" )
sys.stderr.write( "  extension: " + extension + "\n" )
sys.stderr.write( "        txt: " + txt + "\n" )
sys.stderr.write( "      cache: " + cache + "\n" )
sys.stderr.write( "\n" )

for key in sorted( metadata.keys() ) :
	value = metadata[ key ]
	sys.stderr.write( str( key ) + "\t" + str( value ) + "\n" )

# open the given file and unwrap it
text = parsed[ "content" ] 
text = textacy.preprocessing.normalize.normalize_quotation_marks( text )
text = textacy.preprocessing.normalize.normalize_hyphenated_words( text )
text = textacy.preprocessing.normalize.normalize_whitespace( text )

# get all document statistics and summary
summary    = summarize( text, word_count=COUNT, split=False )
summary    = re.sub( '\n+', ' ', summary )
summary    = re.sub( '- ', '', summary )
summary    = re.sub( '\s+', ' ', summary )

# initialize model
maximum = len( text ) + 1
model   = spacy.load( 'en_core_web_sm', max_length=maximum )

# model the data; this needs to be improved
doc = model( text )

# parse out only the desired statistics
statistics = textacy.text_stats.TextStats( doc )
words      = statistics.n_words 
sentences  = statistics.n_sents 
syllables  = statistics.n_syllables
flesch     = int( textacy.text_stats.flesch_reading_ease( syllables, words, sentences ) )

# output header, data, and then done
print( "\t".join( ( 'id', 'author', 'title', 'date', 'pages', 'extension', 'mime', 'words', 'sentences', 'flesch', 'summary', 'cache', 'txt' ) ) )
print( "\t".join( ( (str( id ), author, title, date, pages, extension, mimetype, str( words ), str( sentences ), str( flesch ), summary, cache, txt ) ) ) )

# done
exit()

