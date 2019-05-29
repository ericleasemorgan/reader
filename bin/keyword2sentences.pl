#!/usr/bin/env perl

# keyword2sentences.pl - given a keyword, output all the sentences where it is a keyword

# configure
use constant DATABASE => './etc/reader.db';
use constant DRIVER   => 'SQLite';

# require
use DBI;
use strict;

# sanity check
my $keyword = $ARGV[ 0 ];
if ( ! $keyword ) { die "Usage $0 <keyword>\n" }

# initialize
my $driver    = DRIVER; 
my $database  = DATABASE;
my $dbh       = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;
binmode( STDOUT, ':utf8' );

# find all documents having the given keyword
my $sql    = "select id from wrd where keyword is LOWER('$keyword');";
my $handle = $dbh->prepare( $sql );
$handle->execute() or die $DBI::errstr;

# process each document
my @sentences = ();
while( my $document = $handle->fetchrow_hashref ) {

	# parse
	my $did = $$document{ 'id' };
	
	# find all sentences with the given keyword
	my $sql       = "select sid from pos where token is '$keyword' and id is '$did';";
	my $subhandle = $dbh->prepare( $sql );
	$subhandle->execute() or die $DBI::errstr;
	
	# process each sentence
	while( my $sentence = $subhandle->fetchrow_hashref ) {
	
		# parse
		my $sid = $$sentence{ 'sid' };
		
		# find all tokens with the given sentence
		my $sql          = "select token from pos where sid is '$sid' and id is '$did';";
		my $subsubhandle = $dbh->prepare( $sql );
		$subsubhandle->execute() or die $DBI::errstr;
		
		# process each token; build a sentence
		my @sentence = ();
		while( my $token = $subsubhandle->fetchrow_hashref ) { push( @sentence, $$token{ 'token' } ) }
		
		# normalize
		my $sentence = join( ' ', @sentence );
		$sentence =~ s/ ([[:punct:]])/$1/g;
		$sentence =~ s/("|') /$1/g;

		# update
		push( @sentences, join( ' ', $sentence ) );
		
	}		

}

# output and done
foreach ( @sentences ) { print "$_\n" }
exit;

