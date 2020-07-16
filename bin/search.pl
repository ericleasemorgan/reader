#!/usr/bin/env perl

# search.pl - command-line interface to search a solr instance

# Eric Lease Morgan <emorgan@nd.edu>
# April 30, 2019 - first cut; based on earlier work
# May    2, 2019 - added classification and files (urls)
# July   8, 2019 - added author, title, and date
# May   21, 2019 - migrating to Reader CORD
# June   7, 2020 - implement id output, for scalability


# configure
use constant FACETFIELD => ( 'facet_journal', 'year' );
use constant FIELDS     => 'id,title,doi,url,date,journal';
use constant SOLR       => 'http://solr-01:8983/solr/cord';
use constant ROWS       => 40000;

# require
use strict;
use WebService::Solr;

# get input; sanity check
my $type  = $ARGV[ 0 ];
my $query = $ARGV[ 1 ];
if ( ! $type || ! $query ) { die "Usage: $0 <list|SQL|ids> <query>\n" }

# initialize
my $solr   = WebService::Solr->new( SOLR );
binmode( STDOUT, ':utf8' );

# build the search options
my %search_options = ();
$search_options{ 'facet.field' } = [ FACETFIELD ];
$search_options{ 'fl' }          = FIELDS;
$search_options{ 'facet' }       = 'true';
$search_options{ 'rows' }        = ROWS;

# search
my $response = $solr->search( "$query", \%search_options );

# build a list of journal facets
my @facet_journal = ();
my $journal_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ facet_journal } );
foreach my $facet ( sort { $$journal_facets{ $b } <=> $$journal_facets{ $a } } keys %$journal_facets ) { push @facet_journal, $facet . ' (' . $$journal_facets{ $facet } . ')'; }

# year
my @facet_year = ();
my $year_facets = &get_facets( $response->facet_counts->{ facet_fields }->{ year } );
foreach my $facet ( sort { $$year_facets{ $b } <=> $$year_facets{ $a } } keys %$year_facets ) { push @facet_year, $facet . ' (' . $$year_facets{ $facet } . ')'; }

# get the total number of hits
my $total = $response->content->{ 'response' }->{ 'numFound' };

# get number of hits returned
my @hits = $response->docs;

if ( $type eq 'list' ) {

	# start the output
	print "Your search found $total item(s) and " . scalar( @hits ) . " item(s) are displayed.\n\n";
	print '     year facets: ', join( '; ', @facet_year ), "\n\n";
	print '  journal facets: ', join( '; ', @facet_journal ), "\n\n";

	# loop through each document
	for my $doc ( $response->docs ) {

		# parse
		my $document_id = $doc->value_for( 'id' );
		my $title       = $doc->value_for( 'title' );
		my $date        = $doc->value_for( 'date' );
		#my $abstract    = $doc->value_for( 'abstract' );
		my $journal     = $doc->value_for( 'journal' );
		my $url         = $doc->value_for( 'url' );
		my $doi         = $doc->value_for( 'doi' );
	
		# output
		print "  document id: $document_id\n";
		print "        title: $title\n";
		#print "     abstract: $abstract\n";
		print "      journal: $journal\n";
		print "          url: $url\n";
		print "          doi: $doi\n";
		print "         date: $date\n";
		print "\n";

	}
	
}
	
elsif ( $type eq 'sql' ) {

	# initialize
	my @document_ids = ();
	
	# loop through each document
	for my $doc ( $response->docs ) {

		# parse
		my $document_id = $doc->value_for( 'id' );
		push( @document_ids, "document_id='$document_id'" )
		
	}
	
	my $where = join( " OR ", @document_ids );
	print $where;
	

}

elsif ( $type eq 'ids' ) {

	# initialize
	my @document_ids = ();
	
	# loop through each document
	for my $doc ( $response->docs ) {

		# parse
		my $document_id = $doc->value_for( 'id' );
		push( @document_ids, $document_id . " " )
		
	}
	
	# sort and output
	@document_ids = sort { $a <=> $b } @document_ids;
	print @document_ids;

}

else { die "Usage: $0 <list|SQL|ids> <query>\n" }

# done
exit;


# convert an array reference into a hash
sub get_facets {

	my $array_ref = shift;
	
	my %facets;
	my $i = 0;
	foreach ( @$array_ref ) {
	
		my $k = $array_ref->[ $i ]; $i++;
		my $v = $array_ref->[ $i ]; $i++;
		next if ( ! $v );
		$facets{ $k } = $v;
	 
	}
	
	return \%facets;
	
}


