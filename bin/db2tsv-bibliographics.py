#!/usr/bin/env python

# db2tsv-bibliographics.py - dump bibliographics as a TSV file

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# September 15, 2019 - first cut
# July      25, 2020 - added abstract, url, and doi


# configure
DATABASE = './etc/reader.db'
QUERY    = 'SELECT * FROM bib ORDER BY author'
HEADER   = 'id\tauthor\ttitle\tdate\twords\tsentences\tpages\tflesch\tcache\ttxt\tsummary\tabstract\turl\tdoi'

# require
from sqlalchemy import create_engine
import pandas as pd
import sys

# initialize
engine         = create_engine( 'sqlite:///' + DATABASE )
bibliographics = pd.read_sql_query( QUERY, engine )

# begin output
print( HEADER )

for index, row in bibliographics.iterrows() :

	# parse
	id        = bibliographics.at[ index, 'id' ]
	author    = bibliographics.at[ index, 'author' ]          if bibliographics.at[ index, 'author' ]   else ''
	title     = bibliographics.at[ index, 'title' ]           if bibliographics.at[ index, 'title' ]    else ''
	date      = bibliographics.at[ index, 'date' ]            if bibliographics.at[ index, 'date' ]     else ''
	words     = str( bibliographics.at[ index, 'words' ] )    if bibliographics.at[ index, 'words' ]    else ''
	flesch    = str( bibliographics.at[ index, 'flesch' ] )   if bibliographics.at[ index, 'flesch' ]   else ''
	sentences = str( bibliographics.at[ index, 'sentence' ] ) if bibliographics.at[ index, 'sentence' ] else ''
	pages     = str( bibliographics.at[ index, 'pages' ] )    if bibliographics.at[ index, 'pages' ]    else ''
	cache     = bibliographics.at[ index, 'cache' ]           if bibliographics.at[ index, 'cache' ]    else ''
	txt       = bibliographics.at[ index, 'txt' ]             if bibliographics.at[ index, 'txt' ]      else ''
	summary   = bibliographics.at[ index, 'summary' ]         if bibliographics.at[ index, 'summary' ]  else ''
	abstract  = bibliographics.at[ index, 'abstract' ]        if bibliographics.at[ index, 'abstract' ] else ''
	url       = bibliographics.at[ index, 'url' ]             if bibliographics.at[ index, 'url' ]      else ''
	doi       = bibliographics.at[ index, 'doi' ]             if bibliographics.at[ index, 'doi' ]      else ''
	
	# debug
	sys.stderr.write( '         id: {}\n'.format( id ) )
	sys.stderr.write( '     author: {}\n'.format( author ) )
	sys.stderr.write( '      title: {}\n'.format( title ) )
	sys.stderr.write( '       date: {}\n'.format( date ) )
	sys.stderr.write( '      words: {}\n'.format( words ) )
	sys.stderr.write( '  sentences: {}\n'.format( sentences ) )
	sys.stderr.write( '      pages: {}\n'.format( pages ) )
	sys.stderr.write( '     flesch: {}\n'.format( flesch ) )
	sys.stderr.write( '      cache: {}\n'.format( cache ) )
	sys.stderr.write( '        txt: {}\n'.format( txt ) )
	sys.stderr.write( '    summary: {}\n'.format( summary ) )
	sys.stderr.write( '   abstract: {}\n'.format( abstract ) )
	sys.stderr.write( '        url: {}\n'.format( url ) )
	sys.stderr.write( '        doi: {}\n'.format( doi ) )
	sys.stderr.write( '\n' )

	# output
	print( '\t'.join( [ id, author, title, date, words, sentences, pages, flesch, cache, txt, summary, abstract, url, doi ] ) )

# done
exit()
	
	