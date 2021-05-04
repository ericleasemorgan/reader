#!/usr/bin/env perl

# list-questions.pl - given a document identifier, list all questions


# configure
use constant DATABASE => './etc/reader.db';
use constant DRIVER   => 'SQLite';
use constant SIZE     => 1;

# require
use DBI;
use strict;

# sanity check
my $did = $ARGV[ 0 ];
if ( ! $did ) { die "Usage $0 <identifier>\n" }

# initialize
my $driver    = DRIVER; 
my $database  = DATABASE;
my $dbh       = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;

$did =~ s/'/''/g;

# find all documents having the given keyword
my $sql    = "select sid from pos where pos is '.' AND token IS '?' AND id IS '$did' order by sid;";

my $handle = $dbh->prepare( $sql );
$handle->execute() or die $DBI::errstr;

# process each document
my @sentences = ();
while( my $result = $handle->fetchrow_hashref ) {
			
	# parse
	my $sid = $$result{ 'sid' };

	# find all tokens with the given sentence
	my $sql       = "select token from pos where sid is '$sid' and id is '$did';";
	my $subhandle = $dbh->prepare( $sql );
	$subhandle->execute() or die $DBI::errstr;

	# process each token; build a sentence
	my @sentence = ();
	while( my $token = $subhandle->fetchrow_hashref ) { 
		push( @sentence, $$token{ 'token' } )
	}

	my $sentence = join( ' ', @sentence );
	$sentence =~ s/ ([[:punct:]])/$1/g;
	$sentence =~ s/("|') /$1/g;
	push( @sentences, $sentence )
	
}

# output and done
foreach my $sentence ( sort( @sentences ) ) {

	#next if ( length( $sentence ) > SIZE );
	print join( "\t", ( $did, $sentence ) ), "\n";
	
}

# done
exit;

