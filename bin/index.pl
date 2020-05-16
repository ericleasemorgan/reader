#!/usr/bin/env perl

# index.pl - make the content searchable

# Eric Lease Morgan <emorgan@nd.edu>
# May 17, 2019 - first investigations


# configure
use constant DATABASE => './etc/cord.db';
use constant DRIVER   => 'SQLite';
use constant SOLR     => 'http://localhost:8983/solr/cord';
use constant QUERY    => "SELECT * FROM documents ORDER BY document_id;";

# require
use DBI;
use strict;
use WebService::Solr;

# initialize
my $solr      = WebService::Solr->new( SOLR );
my $driver    = DRIVER; 
my $database  = DATABASE;
my $dbh       = DBI->connect( "DBI:$driver:dbname=$database", '', '', { RaiseError => 1 } ) or die $DBI::errstr;
binmode( STDOUT, ':utf8' );

# find bibliographics
my $handle = $dbh->prepare( QUERY );
$handle->execute() or die $DBI::errstr;

# process each bibliographic item
while( my $documents = $handle->fetchrow_hashref ) {
	
	# parse the easy stuff
	my $document_id = $$documents{ 'document_id' };
	my $title       = $$documents{ 'title' };
	my $abstract    = $$documents{ 'abstract' };
		
	# debug; dump
	warn "  document_id: $document_id\n";
	warn "        title: $title\n";
	warn "     abstract: $abstract\n";
	warn "\n";
		
	# create data
	my $solr_document_id = WebService::Solr::Field->new( 'document_id' => $document_id );
	my $solr_title       = WebService::Solr::Field->new( 'title'       => $title );
	my $solr_abstract    = WebService::Solr::Field->new( 'abstract'    => $abstract );

	# fill a solr document with simple fields
	my $doc = WebService::Solr::Document->new;
	$doc->add_fields( $solr_document_id, $solr_title, $solr_abstract );

	# save/index
	$solr->add( $doc );

}

# done
exit;

