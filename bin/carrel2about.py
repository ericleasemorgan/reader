#!/usr/bin/env python

# about.py - summarize the contents of a study carrel

# Eric Lease Morgan <emorgan@nd.ed>
# (c) University of Notre Dame; distributed under GNU Public License

# June      11, 2019 - first documentation
# July      21, 2019 - switching to Python
# July      30, 2019 - hacking at PEARC '19
# September  1, 2019 - began linking to cached files
# September 14, 2019 - fixed unigrams & bigrams; Yoda says, "Really ugly, they are."
# June       4, 2020 - added additional entity types
# June      26, 2020 - removed lower-casing of proper nouns, but the values themselves seem bogus
# July       9, 2020 - removed (some) stopword from the output


# configure
CLOUD      = '/export/reader/bin/cloud.py'
CLOUDCOUNT = 150
CORPUS     = './etc/reader.txt'
COUNT      = 50
DATABASE   = './etc/reader.db'
DIRECTORY  = './txt'
NGRAMS     = '/export/reader/bin/ngrams.pl'
PLOTFLESCH = '/export/reader/bin/plot-flesch.sh'
PLOTSIZES  = '/export/reader/bin/plot-sizes.sh'
TOPICMODEL = '/export/reader/bin/topic-model.py'
TEMPLATE   = '/export/reader/etc/about.htm'
STOPWORDS  = '/export/reader/etc/stopwords.txt'
PROVENANCE = './provenance.tsv'

# require
from sqlalchemy import create_engine
import pandas as pd
import subprocess
import sys
import os
import re

# define
def id2bibliographics( id, engine ) :
	'''Given an id and an SQL engine, return a dictionary of bibliographics'''
	
	# initialize
	bibliographics = {}
	
	id = id.replace( "'", "''" )
	sys.stderr.write( id + "\n" )
	
	# search
	query = "SELECT * FROM bib where id is '{}'".format( id )
	result = pd.read_sql_query( query, engine )
	
	# update
	bibliographics.update( { "author"    : result.at[ 0, 'author' ] } )
	bibliographics.update( { "cache"     : result.at[ 0, 'cache' ] } )
	bibliographics.update( { "date"      : result.at[ 0, 'date' ] } )
	bibliographics.update( { "extension" : result.at[ 0, 'extension' ] } )
	bibliographics.update( { "flesch"    : result.at[ 0, 'flesch' ] } )
	bibliographics.update( { "genre"     : result.at[ 0, 'genre' ] } )
	bibliographics.update( { "id"        : result.at[ 0, 'id' ] } )
	bibliographics.update( { "mime"      : result.at[ 0, 'mime' ] } )
	bibliographics.update( { "sentences" : result.at[ 0, 'sentence' ] } )
	bibliographics.update( { "title"     : result.at[ 0, 'title' ] } )
	bibliographics.update( { "txt"       : result.at[ 0, 'txt' ] } )
	bibliographics.update( { "words"     : result.at[ 0, 'words' ] } )

	# done
	return bibliographics


def model2dataframe( model ) :
	'''Transform the output of topic-model.py into a data frame'''
	
	# remove bogus carriage returns
	model = model.rstrip()
	
	# create a list of dictionaries
	rows = []
	for topic in model.split( '\n' ) :
		fields = topic.split( '\t' )
		row = { 'id': fields[ 0 ], 'score':fields[ 1 ], 'words':fields[ 2 ], 'files':fields[ 3 ] }
		rows.append( row )
	
	# create and format the dataframe
	df = pd.DataFrame( rows )
	df = df[ [ 'id', 'score', 'words', 'files' ] ]
	df = df.set_index('id')
	
	# done
	return( df )


def addBibliographics( df, engine ) :
	'''Update a data frame with columns of bibliographic data'''
	
	# initialize
	authors = []
	titles  = []
	dates   = []
	caches  = []

	# process each row in the given dataframe
	for index, row in df.iterrows() :
		
		# re-initialize
		author = []
		title  = []
		date   = []
		cache  = []
		
		# process each file
		for id in row[ 'files'].split( ';' ) :
			
			# parse
			id, extention = os.path.splitext( id )
			id            = os.path.basename( id )
			
			id.replace( "'", "''" )

			query = 'SELECT author, title, date, cache FROM bib where id is "{}"'.format( id )

			# search, and conditionally update
			result = pd.read_sql_query( query, engine )
			
			# update with empty values
			if ( result.empty ) :
			
				author.append( '' )
				title.append( '' )
				date.append( '' )
				cache.append( '' )
				
			# update with found values
			else :
			
				if ( result.iloc[ 0, 0 ] ) : author.append( result.iloc[ 0, 0 ] )
				else : author.append( '' )
					
				if ( result.iloc[ 0, 1 ] ) : title.append( result.iloc[ 0, 1 ] )
				else : title.append( '' )
					
				if ( result.iloc[ 0, 2 ] ) : date.append( result.iloc[ 0, 2 ] )
				else : date.append( '' )
											
				if ( result.iloc[ 0, 3 ] ) : cache.append( result.iloc[ 0, 3 ] )
				else : cache.append( '' )
											
		# update
		authors.append( '|'.join( author ) )
		titles.append( '|'.join( title ) )
		dates.append( '|'.join( date ) )
		caches.append( '|'.join( cache ) )

	# add bibliographic columns to the dataframe and done
	df['authors'] = authors 
	df['titles']  = titles 
	df['dates']   = dates 
	df['caches']   = caches 
	return( df )


def readModel( directory, engine, t, d, f ) :
	'''Given a directory, database engine, number of topics, number of dimensions, and number of files, return topics and bibliographics'''
	
	# model the data, stuff the results into a dataframe, and add bibliographics
	model = subprocess.check_output( [ TOPICMODEL, directory, str( t ), str( d ) ] ).decode( 'utf-8' )
	df    = addBibliographics( model2dataframe( model ), engine )
	
	# initialize
	words  = []
	files  = []
	titles = []
	
	# process each topic in the DataFrame
	for index, row in df.iterrows() :

		words.append( row[ 'words' ] )
		
		items = row[ 'caches' ]
		items = items.split( '|' )
		files.append( items[ 0:f ] )
		
		items = row[ 'titles' ]
		items = items.split( '|' )
		titles.append( items[ 0:f ] )

	# done
	return words, files, titles
	
	
# initialize
engine = create_engine( 'sqlite:///' + DATABASE )

# initialize stopwords
handle    = open( STOPWORDS, 'r' )
stopwords = handle.read().split( '\n' )
handle.close()

# read/parse provenance
handle     = open( PROVENANCE, 'r' )
provenance = handle.read()
handle.close()
provenance           = provenance.split( '\t' )
nameOfCarrel         = provenance[ 0 ]
dateOfCreation       = provenance[ 1 ]
timeOfCreation       = provenance[ 2 ]
emailOfCreator       = provenance[ 3 ]
queryAgainstDatabase = provenance[ 4 ]

# number of items
numberOfItems = pd.read_sql_query( 'SELECT COUNT( id ) FROM bib', engine )
numberOfItems = f'{numberOfItems.iloc[ 0, 0 ]:,}'

# sum of words
sumOfWords = pd.read_sql_query( 'SELECT SUM( words ) FROM bib', engine )
sumOfWords = f'{sumOfWords.iloc[ 0, 0 ]:,}'

# average size in words
averageSizeInWords = pd.read_sql_query( 'SELECT AVG( words ) FROM bib', engine )
averageSizeInWords = f'{int( averageSizeInWords.iloc[ 0, 0 ] ):,}'

# average readability score
averageReadabilityScore = pd.read_sql_query( 'SELECT AVG( flesch ) FROM bib', engine )
averageReadabilityScore = int( averageReadabilityScore.iloc[ 0, 0 ] )

# plot sizes and readability
if( not os.path.exists( './figures/sizes-histogram.png' ) )  : subprocess.run( [ PLOTSIZES,  'histogram', './figures/sizes-histogram.png'  ] ) 
if( not os.path.exists( './figures/sizes-boxplot.png' ) )    : subprocess.run( [ PLOTSIZES,  'boxplot',   './figures/sizes-boxplot.png'    ] ) 
if( not os.path.exists( './figures/flesch-histogram.png' ) ) : subprocess.run( [ PLOTFLESCH, 'histogram', './figures/flesch-histogram.png' ] ) 
if( not os.path.exists( './figures/flesch-boxplot.png' ) )   : subprocess.run( [ PLOTFLESCH, 'boxplot',   './figures/flesch-boxplot.png'   ] ) 

# nouns
nouns = pd.read_sql_query( "select lower(token) as 'noun', count(lower(token)) as frequency from pos where pos is 'NN' or pos is 'NNS' group by lower(token) order by frequency desc", engine )
nouns = nouns[ ~nouns[ 'noun' ].isin( stopwords ) ]
if ( not os.path.exists( './tsv/nouns.tsv' ) ) : nouns.to_csv( './tsv/nouns.tsv', sep='\t', columns=[ 'noun', 'frequency' ], index=False )
if ( not os.path.exists( './figures/nouns.png' ) ) :
	data = nouns[ 0:CLOUDCOUNT ]
	data.to_csv( './tmp/nouns.tsv', columns=[ 'noun', 'frequency' ], header=False, sep='\t', index=False )
	subprocess.run( [ CLOUD, './tmp/nouns.tsv', 'white', './figures/nouns.png' ] )
nouns = nouns[ 'noun' ].iloc[ : COUNT ].tolist()

# verbs
verbs = pd.read_sql_query( "select lower(token) as 'verb', count(lower(lemma)) as frequency from pos where pos like 'VB%%' group by lower(lemma) order by frequency desc", engine )
verbs = verbs[ ~verbs[ 'verb' ].isin( stopwords ) ]
if ( not os.path.exists( './tsv/verbs.tsv' ) ) : verbs.to_csv( './tsv/verbs.tsv', sep='\t', columns=[ 'verb', 'frequency' ], index=False )
if ( not os.path.exists( './figures/verbs.png' ) ) :
	data = verbs[ 0:CLOUDCOUNT ]
	data.to_csv( './tmp/verbs.tsv', columns=[ 'verb', 'frequency' ], header=False, sep='\t', index=False )
	subprocess.run( [ CLOUD, './tmp/verbs.tsv', 'white', './figures/verbs.png' ] )
verbs = verbs[ 'verb' ].iloc[ : COUNT ].tolist()

# adjectives
adjectives = pd.read_sql_query( "select lower(token) as 'adjective', count(lower(token)) as frequency from pos where pos like 'J%%' group by lower(token) order by frequency desc", engine )
adjectives = adjectives[ ~adjectives[ 'adjective' ].isin( stopwords ) ]
if ( not os.path.exists( './tsv/adjectives.tsv' ) ) : adjectives.to_csv( './tsv/adjectives.tsv', sep='\t', columns=[ 'adjective', 'frequency' ], index=False )
if ( not os.path.exists( './figures/adjectives.png' ) ) :
	data = adjectives[ 0:CLOUDCOUNT ]
	data.to_csv( './tmp/adjectives.tsv', columns=[ 'adjective', 'frequency' ], header=False, sep='\t', index=False )
	subprocess.run( [ CLOUD, './tmp/adjectives.tsv', 'white', './figures/adjectives.png' ] )
adjectives = adjectives[ 'adjective' ].iloc[ : COUNT ].tolist()


# adverbs
adverbs = pd.read_sql_query( "select lower(token) as 'adverb', count(lower(token)) as frequency from pos where pos like 'R%%' group by lower(token) order by frequency desc", engine )
adverbs = adverbs[ ~adverbs[ 'adverb' ].isin( stopwords ) ]
if ( not os.path.exists( './tsv/adverbs.tsv' ) ) : adverbs.to_csv( './tsv/adverbs.tsv', sep='\t', columns=[ 'adverb', 'frequency' ], index=False )
if ( not os.path.exists( './figures/adverbs.png' ) ) :
	data = adverbs[ 0:CLOUDCOUNT ]
	data.to_csv( './tmp/adverbs.tsv', columns=[ 'adverb', 'frequency' ], header=False, sep='\t', index=False )
	subprocess.run( [ CLOUD, './tmp/adverbs.tsv', 'white', './figures/adverbs.png' ] )
adverbs = adverbs[ 'adverb' ].iloc[ : COUNT ].tolist()

# pronouns
pronouns = pd.read_sql_query( "select lower(token) as 'pronoun', count(lower(token)) as frequency from pos where pos like 'PR%%' group by lower(token) order by frequency desc", engine )
propepronounsrNouns = pronouns[ ~pronouns[ 'pronoun' ].isin( stopwords ) ]
if ( not os.path.exists( './tsv/pronouns.tsv' ) ) : pronouns.to_csv( './tsv/pronouns.tsv', sep='\t', columns=[ 'pronoun', 'frequency' ], index=False )
if ( not os.path.exists( './figures/pronouns.png' ) ) :
	data = pronouns[ 0:CLOUDCOUNT ]
	data.to_csv( './tmp/pronouns.tsv', columns=[ 'pronoun', 'frequency' ], header=False, sep='\t', index=False )
	subprocess.run( [ CLOUD, './tmp/pronouns.tsv', 'white', './figures/pronouns.png' ] )
pronouns = pronouns[ 'pronoun' ].iloc[ : COUNT ].tolist()

# proper nouns
properNouns = pd.read_sql_query( "select token as 'proper', count(token) as frequency from pos where pos like 'NNP%%' group by token order by frequency desc", engine )
properNouns = properNouns[ ~properNouns[ 'proper' ].isin( stopwords ) ]
if ( not os.path.exists( './tsv/proper-nouns.tsv' ) ) : properNouns.to_csv( './tsv/proper-nouns.tsv', sep='\t', columns=[ 'proper', 'frequency' ], index=False )
if ( not os.path.exists( './figures/proper-nouns.png' ) ) :
	data = properNouns[ 0:CLOUDCOUNT ]
	data.to_csv( './tmp/proper-nouns.tsv', columns=[ 'proper', 'frequency' ], header=False, sep='\t', index=False )
	subprocess.run( [ CLOUD, './tmp/proper-nouns.tsv', 'white', './figures/proper-nouns.png' ] )
properNouns = properNouns[ 'proper' ].iloc[ : COUNT ].tolist()

# keywords
keywords = pd.read_sql_query( "select lower( keyword ) as 'keyword', count( keyword ) as frequency from wrd group by lower( keyword ) order by frequency desc", engine )
keywords = keywords[ ~keywords[ 'keyword' ].isin( stopwords ) ]
if ( not os.path.exists( './tsv/keywords.tsv' ) ) : keywords.to_csv( './tsv/keywords.tsv', sep='\t', columns=[ 'keyword', 'frequency' ], index=False )
if ( not os.path.exists( './figures/keywords.png' ) ) :
	data = keywords[ 0:CLOUDCOUNT ]
	data.to_csv( './tmp/keywords.tsv', columns=[ 'keyword', 'frequency' ], header=False, sep='\t', index=False )
	subprocess.run( [ CLOUD, './tmp/keywords.tsv', 'white', './figures/keywords.png' ] )
keywords = keywords[ 'keyword' ].iloc[ : COUNT ].tolist()

# grammers; noun-verb
if ( not os.path.exists( './tsv/noun-verb.tsv' ) ) :
	nounVerb = pd.read_sql_query( "SELECT ( LOWER( t.token || ' ' || c.token )) AS sentence, COUNT( LOWER( t.token || ' ' || c.token ) ) AS frequency FROM pos AS t JOIN pos AS c ON c.tid=t.tid+1 AND c.sid=t.sid AND c.id=t.id WHERE t.lemma IN (select lemma from pos where pos like 'NN%%' or pos like 'PR%%' group by lemma order by count(lemma) desc limit 30) AND c.lemma in (select lemma from pos where pos like 'V%%' group by lemma order by count(lemma) desc limit 30) GROUP BY sentence ORDER BY frequency DESC, ( LOWER( t.token || ' ' || c.token ) )", engine )
	nounVerb[ [ 'noun', 'verb' ] ] = nounVerb.sentence.str.split( ' ', expand=True )
	nounVerb.to_csv( './tsv/noun-verb.tsv', columns=[ 'noun', 'verb', 'frequency' ], sep='\t', index=False )

# adjective-noun
if ( not os.path.exists( './tsv/adjective-noun.tsv' ) ) :
	adjectiveNoun = pd.read_sql_query( "SELECT ( LOWER( t.token || ' ' || c.token )) AS sentence, COUNT( LOWER( t.token || ' ' || c.token ) ) AS frequency FROM pos AS t JOIN pos AS c ON c.tid=t.tid+1 AND c.sid=t.sid AND c.id=t.id WHERE t.lemma IN (select lemma from pos where pos like 'J%%' group by lemma order by count(lemma) desc limit 30) AND c.lemma in (select lemma from pos where pos like 'N%%' group by lemma order by count(lemma) desc limit 30) GROUP BY sentence ORDER BY frequency DESC, ( LOWER( t.token || ' ' || c.token ) )", engine )
	adjectiveNoun[ [ 'adjective', 'noun' ] ] = adjectiveNoun.sentence.str.split( ' ', expand=True )
	adjectiveNoun.to_csv( './tsv/adjective-noun.tsv', columns=[ 'adjective', 'noun', 'frequency' ], sep='\t', index=False )

# named-entities
if ( not os.path.exists( './tsv/entities.tsv' ) ) :
	entities = pd.read_sql_query( "select lower(entity) as entity, type, count(lower(entity)) as frequency from ent where (type is 'TAXON' or type is 'DISEASE' or type is 'CHEMICAL' or type is 'PERSON' or type is 'GPE' or type is 'LOC' or type is 'ORG') group by entity order by frequency desc", engine )
	entities.to_csv( './tsv/entities.tsv', columns=[ 'entity', 'type', 'frequency' ], sep='\t', index=False )

# unigrams; really ugly!
unigrams = subprocess.check_output( [ NGRAMS, CORPUS, '1' ] ).decode( 'utf-8' )
if ( not os.path.exists( './tsv/unigrams.tsv' ) ) :
	handle = open( './tsv/unigrams.tsv', 'w' ) 
	handle.write( "unigram\tfrequency\n" ) 
	handle.write( unigrams ) 
	handle.close()
if ( not os.path.exists( './figures/unigrams.png' ) ) :	
	data = unigrams.split( '\n' )
	handle   = open( './tmp/unigrams.tsv', 'w' )
	handle.write( '\n'.join( data[ 0:CLOUDCOUNT ] ) ) 
	handle.close()
	subprocess.run( [ CLOUD, './tmp/unigrams.tsv', 'white', './figures/unigrams.png' ] )
data     = unigrams
unigrams = []
for unigram in data.split( '\n' ) :
	fields = unigram.split( '\t' )
	unigrams.append( fields[ 0 ] )
pattern      = '|'.join( unigrams[ 0:2 ] )
command      = "grep -HicE '" + pattern + "' ./txt/*.txt | sort -r -n -t ':' -k2 | head -n3 | cut -d ':' -f1"
unigramfiles = subprocess.check_output( command, shell=True ).decode( 'utf-8' )
unigramlinks = [ 'None', 'None', 'None' ]
for item, file in enumerate( unigramfiles.rstrip().split( '\n' ) ) :
	id = os.path.splitext( os.path.basename( file ) )[ 0 ]
	bibliographics = id2bibliographics( id, engine )
	cache = bibliographics.get('cache')
	title = bibliographics.get('title')
	link = "<a href='{}'>{}</a>".format( cache, title )
	unigramlinks[ item ] = link

# bigrams; just as ugly
bigrams = subprocess.check_output( [ NGRAMS, CORPUS, '2' ] ).decode( 'utf-8' )
if ( not os.path.exists( './tsv/bigrams.tsv' ) ) :
	handle = open( './tsv/bigrams.tsv', 'w' ) 
	handle.write( "bigram\tfrequency\n" ) 
	handle.write( bigrams ) 
	handle.close() 
if ( not os.path.exists( './figures/bigrams.png' ) ) :	
	data = bigrams.split( '\n' )
	handle  = open( './tmp/bigrams.tsv', 'w' )
	handle.write( '\n'.join( data[ 0:CLOUDCOUNT ] ) ) 
	handle.close()
	subprocess.run( [ CLOUD,  './tmp/bigrams.tsv', 'white', './figures/bigrams.png' ] )
data     = bigrams
bigrams = []
for bigram in data.split( '\n' ) :
	fields = bigram.split( '\t' )
	bigrams.append( fields[ 0 ] )
pattern      = '|'.join( bigrams[ 0:2 ] )
command      = "grep -HicE '" + pattern + "' ./txt/*.txt | sort -r -n -t ':' -k2 | head -n3 | cut -d ':' -f1"
bigramfiles = subprocess.check_output( command, shell=True ).decode( 'utf-8' )
bigramlinks = [ 'None', 'None', 'None']
for item, file in enumerate( bigramfiles.rstrip().split( '\n' ) ) :
	id = os.path.splitext( os.path.basename( file ) )[ 0 ]
	bibliographics = id2bibliographics( id, engine )
	cache = bibliographics.get('cache')
	title = bibliographics.get('title')
	link = "<a href='{}'>{}</a>".format( cache, title )
	bigramlinks[ item ]= link 

# trigrams
if ( not os.path.exists( './tsv/trigrams.tsv' ) ) :
	handle = open( './tsv/trigrams.tsv', 'w' ) 
	handle.write( "trigram\tfrequency\n" ) 
	handle.write( subprocess.check_output( [ NGRAMS, CORPUS, '3' ] ).decode( 'utf-8' ) ) 
	handle.close() 

# quadgrams
if ( not os.path.exists( './tsv/quadgrams.tsv' ) ) :
	handle = open( './tsv/quadgrams.tsv', 'w' ) 
	handle.write( "quadgram\tfrequency\n" ) 
	handle.write( subprocess.check_output( [ NGRAMS, CORPUS, '4' ] ).decode( 'utf-8' ) ) 
	handle.close() 

# topic model
topicSingleWords, topicSingleFiles, topicSingleTitles          = readModel( DIRECTORY, engine, 1, 1, 1 )
topicTripleWords, topicTripleFiles, topicTripleTitles          = readModel( DIRECTORY, engine, 3, 1, 1 )
topicQuintupleWords, topicQuintupleFiles, topicQuintupleTitles = readModel( DIRECTORY, engine, 5, 3, 1 )
subprocess.check_output( TOPICMODEL + ' ./txt 5 3 ./figures/topics.png', shell=True )

# debug
sys.stderr.write( '                number of items: ' + str( numberOfItems )           + '\n' )
sys.stderr.write( '                   sum of words: ' + str( sumOfWords )              + '\n' )
sys.stderr.write( '          average size in words: ' + str( averageSizeInWords )      + '\n' )
sys.stderr.write( '      average readability score: ' + str( averageReadabilityScore ) + '\n' )
sys.stderr.write( '\n' )
sys.stderr.write( '                          nouns: ' + '; '.join( nouns )       + '\n' )
sys.stderr.write( '                          verbs: ' + '; '.join( verbs )       + '\n' )
sys.stderr.write( '                     adjectives: ' + '; '.join( adjectives )  + '\n' )
sys.stderr.write( '                        adverbs: ' + '; '.join( adverbs )     + '\n' )
sys.stderr.write( '                       pronouns: ' + '; '.join( pronouns )    + '\n' )
sys.stderr.write( '                   proper nouns: ' + '; '.join( properNouns ) + '\n' )
sys.stderr.write( '                       keywords: ' + '; '.join( keywords )    + '\n' )
sys.stderr.write( '\n' )
sys.stderr.write( '       one topic; one dimension: ' + '; '.join( topicSingleWords )                                         + '\n' )
sys.stderr.write( '                        file(s): ' + ', '.join( [ '; '.join( files ) for files in topicSingleFiles ] )     + '\n' )
sys.stderr.write( '                      titles(s): ' + ' | '.join( [ '; '.join( titles ) for titles in topicSingleTitles ] ) + '\n' )
sys.stderr.write( '\n' )
sys.stderr.write( '    three topics; one dimension: ' + '; '.join( topicTripleWords )                                         + '\n' )
sys.stderr.write( '                        file(s): ' + ', '.join( [ '; '.join( files ) for files in topicTripleFiles ] )     + '\n' )
sys.stderr.write( '                      titles(s): ' + ' | '.join( [ '; '.join( titles ) for titles in topicTripleTitles ] ) + '\n' )
sys.stderr.write( '\n' )
sys.stderr.write( '  five topics; three dimensions: ' + '; '.join( topicQuintupleWords )                                         + '\n' )
sys.stderr.write( '                        file(s): ' + ', '.join( [ '; '.join( files ) for files in topicQuintupleFiles ] )     + '\n' )
sys.stderr.write( '                      titles(s): ' + ' | '.join( [ '; '.join( titles ) for titles in topicQuintupleTitles ] ) + '\n' )
sys.stderr.write( '\n' )

# open the template and do the substitutions
with open( TEMPLATE, 'r' ) as handle : html = handle.read()
html = html.replace( '##NAMEOFCARREL##',          str( nameOfCarrel ) )
html = html.replace( '##DATEOFCREATION##',          str( dateOfCreation ) )
html = html.replace( '##TIMEOFCREATION##',          str( timeOfCreation ) )
html = html.replace( '##EMAILOFCREATOR##',          str( emailOfCreator ) )
html = html.replace( '##QUERYAGAINSTDATABASE##',          str( queryAgainstDatabase ) )
html = html.replace( '##NUMBEROFITEMS##',          str( numberOfItems ) )
html = html.replace( '##SUMOFWORDS##',             str( sumOfWords ) )
html = html.replace( '##AVERAGESIZEINWORDS##',     str( averageSizeInWords)  )
html = html.replace( '##AVERAGEREADABILITSCORE##', str( averageReadabilityScore ) )
html = html.replace( '##FREQUENTUNIGRAMS##',       ', '.join( unigrams[ 0:50 ] ) )
html = html.replace( '##FREQUENTBIGRAMS##',        ', '.join( bigrams[ 0:50 ] ) )
html = html.replace( '##KEYWORDS##',               ', '.join( keywords ) )
html = html.replace( '##NOUNS##',                  ', '.join( nouns ) )
html = html.replace( '##VERBS##',                  ', '.join( verbs ) )
html = html.replace( '##PROPER##',                 ', '.join( properNouns ) )
html = html.replace( '##PRONOUNS##',               ', '.join( pronouns ) )
html = html.replace( '##ADJECTIVES##',             ', '.join( adjectives ) )
html = html.replace( '##ADVERBS##',                ', '.join( adverbs ) )
html = html.replace( '##TOPICSSINGLEWORD##',       topicSingleWords[ 0 ] )
html = html.replace( '##TOPICSSINGLEFILE##',       topicSingleFiles[ 0 ][ 0 ] )
html = html.replace( '##TOPICSSINGLETITLE##',      topicSingleTitles[ 0 ][ 0 ] )
html = html.replace( '##TOPICSTRIPLEWORD01##',     topicTripleWords[ 0 ] )
html = html.replace( '##TOPICSTRIPLEWORD02##',     topicTripleWords[ 1 ] )
html = html.replace( '##TOPICSTRIPLEWORD03##',     topicTripleWords[ 2 ] )
html = html.replace( '##TOPICSTRIPLEFILE01##',     topicTripleFiles[ 0 ][ 0 ] )
html = html.replace( '##TOPICSTRIPLEFILE02##',     topicTripleFiles[ 1 ][ 0 ] )
html = html.replace( '##TOPICSTRIPLEFILE03##',     topicTripleFiles[ 2 ][ 0 ] )
html = html.replace( '##TOPICSTRIPLETITLE01##',    topicTripleTitles[ 0 ][ 0 ] )
html = html.replace( '##TOPICSTRIPLETITLE02##',    topicTripleTitles[ 1 ][ 0 ] )
html = html.replace( '##TOPICSTRIPLETITLE03##',    topicTripleTitles[ 2 ][ 0 ] )
html = html.replace( '##TOPICSQUINWORDS01##',      ', '.join( topicQuintupleWords[ 0 ].split( ' ' ) ) )
html = html.replace( '##TOPICSQUINWORDS02##',      ', '.join( topicQuintupleWords[ 1 ].split( ' ' ) ) )
html = html.replace( '##TOPICSQUINWORDS03##',      ', '.join( topicQuintupleWords[ 2 ].split( ' ' ) ) )
html = html.replace( '##TOPICSQUINWORDS04##',      ', '.join( topicQuintupleWords[ 3 ].split( ' ' ) ) )
html = html.replace( '##TOPICSQUINWORDS05##',      ', '.join( topicQuintupleWords[ 4 ].split( ' ' ) ) )
html = html.replace( '##TOPICSQUINFILE01##',       topicQuintupleFiles[ 0 ][ 0 ] )
html = html.replace( '##TOPICSQUINFILE02##',       topicQuintupleFiles[ 1 ][ 0 ] )
html = html.replace( '##TOPICSQUINFILE03##',       topicQuintupleFiles[ 2 ][ 0 ] )
html = html.replace( '##TOPICSQUINFILE04##',       topicQuintupleFiles[ 3 ][ 0 ] )
html = html.replace( '##TOPICSQUINFILE05##',       topicQuintupleFiles[ 4 ][ 0 ] )
html = html.replace( '##TOPICSQUINTITLE01##',      topicQuintupleTitles[ 0 ][ 0 ] )
html = html.replace( '##TOPICSQUINTITLE02##',      topicQuintupleTitles[ 1 ][ 0 ] )
html = html.replace( '##TOPICSQUINTITLE03##',      topicQuintupleTitles[ 2 ][ 0 ] )
html = html.replace( '##TOPICSQUINTITLE04##',      topicQuintupleTitles[ 3 ][ 0 ] )
html = html.replace( '##TOPICSQUINTITLE05##',      topicQuintupleTitles[ 4 ][ 0 ] )
html = html.replace( '##FREQUENTUNIGRAMLINK01##',  unigramlinks[ 0 ] )
html = html.replace( '##FREQUENTUNIGRAMLINK02##',  unigramlinks[ 1 ] )
html = html.replace( '##FREQUENTUNIGRAMLINK03##',  unigramlinks[ 2 ] )
html = html.replace( '##FREQUENTBIGRAMLINK01##',   bigramlinks[ 0 ] )
html = html.replace( '##FREQUENTBIGRAMLINK02##',   bigramlinks[ 1 ] )
html = html.replace( '##FREQUENTBIGRAMLINK03##',   bigramlinks[ 2 ] )

# output and done
print( html )
exit()
