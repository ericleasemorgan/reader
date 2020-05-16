#!/usr/bin/env perl

# search.pl - command-line interface to search a solr instance

# Eric Lease Morgan <emorgan@nd.edu>
# April 30, 2019 - first cut; based on earlier work
# May    2, 2019 - added classification and files (urls)
# July 8, 2019 - added author, title, and date


# configure
use constant FACETFIELD => ( );
use constant SOLR       => 'http://localhost:8983/solr/cord';
use constant ROWS       => 999;

# require
use strict;
use WebService::Solr;

# get input; sanity check
my $type  = $ARGV[ 0 ];
my $query = $ARGV[ 1 ];
if ( ! $type || ! $query ) { die "Usage: $0 <list|SQL> <query>\n" }

# initialize
my $solr   = WebService::Solr->new( SOLR );

# build the search options
my %search_options = ();
$search_options{ 'facet.field' } = [ FACETFIELD ];
$search_options{ 'facet' }       = 'true';
$search_options{ 'rows' }        = ROWS;

# search
my $response = $solr->search( "$query", \%search_options );

# get the total number of hits
my $total = $response->content->{ 'response' }->{ 'numFound' };

# get number of hits returned
my @hits = $response->docs;

if ( $type eq 'list' ) {

	# start the output
	print "Your search found $total item(s) and " . scalar( @hits ) . " item(s) are displayed.\n\n";

	# loop through each document
	for my $doc ( $response->docs ) {

		# parse
		my $document_id = $doc->value_for( 'document_id' );
		my $title       = $doc->value_for( 'title' );
		my $abstract    = $doc->value_for( 'abstract' );
	
		# output
		print "  document id: $document_id\n";
		print "        title: $title\n";
		print "     abstract: $abstract\n";
		print "\n";

	}
	
}
	
elsif ( $type eq 'sql' ) {

	# initialize
	my @document_ids = ();
	
	# loop through each document
	for my $doc ( $response->docs ) {

		# parse
		my $document_id = $doc->value_for( 'document_id' );
		push( @document_ids, "document_id='$document_id'" )
		
	}
	
	my $where = join( " OR ", @document_ids );
	print $where;
	

}

else { die "Usage: $0 <list|SQL> <query>\n" }

# done
exit;

