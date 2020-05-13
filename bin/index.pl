#!/usr/bin/env perl

# index.pl - make the content searchable

# Eric Lease Morgan <emorgan@nd.edu>
# May 17, 2019 - first investigations

# configure
use constant DATABASE => 'etc/reader.db';
use constant DRIVER   => 'SQLite';
use constant SOLR     => 'http://localhost:8983/solr/covid';
use constant QUERY    => 'SELECT * FROM bib ORDER BY id;';
use constant TXT      => './txt';
use constant LIBRARY  => './library';

# require
use DBI;
use strict;
use WebService::Solr;

my $carrel = $ARGV[ 0 ];
if ( ! $carrel ) { die "Usage: $0 <carrel>\n" }

# initialize
my $solr      = WebService::Solr->new( SOLR );
my $driver    = DRIVER; 
my $database  = LIBRARY . "/$carrel/" . DATABASE;
my $txt       = LIBRARY . "/$carrel/" . TXT;
my $dbh       = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;
binmode( STDOUT, ':utf8' );

# find bibliographics
my $handle = $dbh->prepare( QUERY );
$handle->execute() or die $DBI::errstr;

# process each bibliographic item
while( my $bibliographics = $handle->fetchrow_hashref ) {
	
	# parse the easy stuff
	my $bid       = $$bibliographics{ 'id' };
	my $author    = $$bibliographics{ 'author' };
	my $title     = $$bibliographics{ 'title' };
	my $date      = $$bibliographics{ 'date' };
	my $words     = $$bibliographics{ 'words' };
	my $sentence  = $$bibliographics{ 'sentence' };
	my $summary   = $$bibliographics{ 'summary' };
	my $flesch    = $$bibliographics{ 'flesch' };
	my $extension = $$bibliographics{ 'extension' };

	# get and normalize the full text
	my $fulltext = &slurp( "$txt/$bid.txt" );
	$fulltext    =~ s/\r//g;
	$fulltext    =~ s/\n/ /g;
	$fulltext    =~ s/ +/ /g;
	$fulltext    =~ s/[^\x09\x0A\x0D\x20-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]//go;
		
	# get keywords
	my @keywords       = ();
	my @facet_keywords = ();
	my $subhandle = $dbh->prepare( qq(SELECT keyword FROM wrd WHERE id='$bid' ORDER BY keyword;) );
	$subhandle->execute() or die $DBI::errstr;
	while( my @keyword = $subhandle->fetchrow_array ) { push @keywords, $keyword[ 0 ] }

	# get people
	my @persons       = ();
	my @facet_persons = ();
	my $subhandle = $dbh->prepare( qq(SELECT DISTINCT( entity ) FROM ent WHERE type IS 'PERSON' AND id IS '$bid' ORDER BY entity;) );
	$subhandle->execute() or die $DBI::errstr;
	while( my @person = $subhandle->fetchrow_array ) { push @persons, $person[ 0 ] }

	# debug; dump
	warn "     carrel: $carrel\n";
	warn "        bid: $bid\n";
	warn "     author: $author\n";
	warn "      title: $title\n";
	warn "       date: $date\n";
	warn "      words: $words\n";
	warn "   sentence: $sentence\n";
	warn "     flesch: $flesch\n";
	warn "    summary: $summary\n";
	warn "  extension: $extension\n";
	warn " keyword(s): " . join( '; ', @keywords ) . "\n";
	warn "  person(s): " . join( '; ', @persons ) . "\n";
	#warn "  full text: $fulltext\n";
	warn "\n";
		
	# create data
	my $solr_bid       = WebService::Solr::Field->new( 'bid'       => $bid );
	my $solr_carrel    = WebService::Solr::Field->new( 'carrel'    => $carrel );
	my $solr_flesch    = WebService::Solr::Field->new( 'flesch'    => $flesch );
	my $solr_fulltext  = WebService::Solr::Field->new( 'fulltext'  => $fulltext );
	my $solr_sentences = WebService::Solr::Field->new( 'sentences' => $sentence );
	my $solr_summary   = WebService::Solr::Field->new( 'summary'   => $summary );
	my $solr_words     = WebService::Solr::Field->new( 'words'     => $words );
	my $solr_author    = WebService::Solr::Field->new( 'author'    => $author );
	my $solr_title     = WebService::Solr::Field->new( 'title'     => $title );
	my $solr_date      = WebService::Solr::Field->new( 'date'      => $date );
	my $solr_extension = WebService::Solr::Field->new( 'extension' => $extension );

	# fill a solr document with simple fields
	my $doc = WebService::Solr::Document->new;
	$doc->add_fields( $solr_bid, $solr_carrel, $solr_flesch, $solr_fulltext, $solr_sentences, $solr_summary, $solr_words, $solr_author, $solr_title, $solr_date, $solr_extension );

	# add complex fields
	foreach ( @keywords ) { $doc->add_fields( ( WebService::Solr::Field->new( 'facet_keyword' => $_ ) ) ) }
	foreach ( @keywords ) { $doc->add_fields( ( WebService::Solr::Field->new( 'keyword'       => $_ ) ) ) }
	foreach ( @persons )  { $doc->add_fields( ( WebService::Solr::Field->new( 'person'        => $_ ) ) ) }
	foreach ( @persons )  { $doc->add_fields( ( WebService::Solr::Field->new( 'facet_person'  => $_ ) ) ) }

	# save/index
	#$solr->add( $doc );

}

# done
exit;


sub slurp {

	my $f = shift;
	open ( F, $f ) or die "Can't open $f: $!\n";
	my $r = do { local $/; <F> };
	close F;
	return $r;

}