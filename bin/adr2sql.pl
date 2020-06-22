#!/usr/bin/env perl

# adr2sql.sh - given a TSV file of keywords, output a set of SQL INSERT statements
# usage: mkdir -p ./tmp/sql-adr; find ./adr -name "*.adr" | parallel --will-cite /export/reader/bin/adr2sql.pl

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 22, 2020 - re-wrote in Perl and now a whole lot faster; "Thanks Bill Duper!"


# configure
use constant SQLADR   => './tmp/sql-adr';
use constant TEMPLATE => "INSERT INTO adr ( 'id', 'address' ) VALUES ( '##ID##', '##ADDRESS##' );";

# require
use strict;
use File::Basename;

# get input
my $tsv = $ARGV[ 0 ];
if ( ! $tsv ) { die "Usage: $0 <adr>\n" }

# extract document_id; I wish they had given me a key
my $key        =  basename( $tsv ,  ( '.adr' ) );
my @parts      =  split( '-', $key );
my $documentid =  $parts[ 1 ];
$documentid    =~ s/^0+//;

# debug
warn "$key\n";

# generate output file
my $output = SQLADR . "/$key.sql";

# if the output already exists, then exit; don't repeat our work
if ( -f $output ) { exit }

# slurp up my data and parse
my @records = split( "\n", &slurp( $tsv ) );

# initialize
my $i   = 0;
my $sql = '';

# process each record
foreach ( @records ) {
   
	# increment and check for header
	$i++;
	next if ( $i == 1 );
	
	# parse
	my ( $id, $address ) = split( '\t', $_ );
	
	# escape
	$address =~ s/'/''/g;
	
	# build INSERT statement
	my $insert =  TEMPLATE;
	$insert    =~ s/##ID##/$documentid/e;
	$insert    =~ s/##ADDRESS##/$address/e;
		
	# update
	$sql .= "$insert\n";
		
}

# output
open( OUTPUT, "> $output" ) or die "Can't open $output ($!). Call Eric.\n";
print OUTPUT $sql;
close( OUTPUT );

# done
exit;


sub slurp {

	my $f = shift;
	open ( F, $f ) or die "Can't open $f: $!\n";
	my $r = do { local $/; <F> };
	close F;
	return $r;

}

