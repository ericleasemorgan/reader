#!/usr/bin/env perl

# many2carrel.pl - given a type and a query, output a stream of TSV to be queued for "carrelizing"

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# July 31, 2020 - first investigations


# configure
use constant OUTPUT  => '/export/reader/queue/todo';
use constant EMAIL   => 'emorgan@nd.edu';
use constant AUTHOR  => 'author-##NAME##	##DATE##	##TIME##	##EMAIL##	( ( * NOT ( pdf_json:nan ) ) OR ( * NOT ( pmc_json:nan ) ) ) AND authors:"##QUERY##"';
use constant JOURNAL => 'journal-##NAME##	##DATE##	##TIME##	##EMAIL##	( ( * NOT ( pdf_json:nan ) ) OR ( * NOT ( pmc_json:nan ) ) ) AND facet_journal:"##QUERY##"';
use constant KEYWORD => 'keyword-##NAME##	##DATE##	##TIME##	##EMAIL##	( ( * NOT ( pdf_json:nan ) ) OR ( * NOT ( pmc_json:nan ) ) ) AND keywords:"##QUERY##"';

# require
use strict;

# sanity check
my $type  = $ARGV[ 0 ];
my $query = $ARGV[ 1 ];
if ( ! $type || ! $query ) {
	warn "Usage: $0 <authors|journals|keywords|entity> <query>\n";
	exit;
}

# initialize
my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime();
my $date  = sprintf ( "%02d-%02d-%02d", $year+1900, $mon+1, $mday );
my $time  = sprintf ( "%02d:%02d", $hour, $min );
my $email = EMAIL;
my $tsv   = '';

# author search
if ( $type eq 'author' ) {

	# parse query; assume author is in the form of last, first initial
	my $name = lc( $query );
	$name =~ s/[[:punct:]]//g;
	$name =~ s/ /_/g;
	
	# build tsv
	$tsv =  AUTHOR;
	$tsv =~ s/##DATE##/$date/e;
	$tsv =~ s/##TIME##/$time/e;
	$tsv =~ s/##EMAIL##/$email/e;
	$tsv =~ s/##QUERY##/$query/e;
	$tsv =~ s/##NAME##/$name/e;
	
}

# journal title searches
elsif ( $type eq 'journal' ) {

	# parse query
	my $name = lc( $query );
	$name =~ s/[[:punct:]]//g;
	$name =~ s/ /_/g;
	
	# build tsv
	$tsv =  JOURNAL;
	$tsv =~ s/##DATE##/$date/e;
	$tsv =~ s/##TIME##/$time/e;
	$tsv =~ s/##EMAIL##/$email/e;
	$tsv =~ s/##QUERY##/$query/e;
	$tsv =~ s/##NAME##/$name/e;

}

# keyword searches
elsif ( $type eq 'keyword' ) {

	# parse query
	my $name = lc( $query );
	$name =~ s/[[:punct:]]//g;
	$name =~ s/ /_/g;
	
	# build tsv
	$tsv =  KEYWORD;
	$tsv =~ s/##DATE##/$date/e;
	$tsv =~ s/##TIME##/$time/e;
	$tsv =~ s/##EMAIL##/$email/e;
	$tsv =~ s/##QUERY##/$query/e;
	$tsv =~ s/##NAME##/$name/e;

}

# error
else {

	warn "Usage: $0 <authors|journals|keyword|entity> <query>\n";
	exit;
}

# output
warn "$tsv\n";
my $output = OUTPUT . '/'. ( split( "\t", $tsv ) )[ 0 ] . '.tsv';
open( TSV, " > $output" ) or die "Can't open $output ($!). Call Eric\n";
print TSV "$tsv\n";
close TSV;

# done
exit;