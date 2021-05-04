#!/usr/bin/env perl

# wrd2sql-cord.sh - given a TSV file of keywords, output a set of SQL INSERT statements
# usage: mkdir -p ./cord/sql-wrd; find ./cord/wrd -name "*.wrd" | parallel --will-cite ./bin/wrd2sql-cord.pl

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 25, 2020 - copying to CORD


# configure
use constant SQLWRD   => './cord/sql-wrd';
use constant TEMPLATE => "INSERT INTO wrd ( 'document_id', 'keyword' ) VALUES ( '##DOCUMENTID##', '##KEYWORD##' );";

# require
use strict;
use File::Basename;

# get input
my $tsv = $ARGV[ 0 ];
if ( ! $tsv ) { die "Usage: $0 <wrd>\n" }

# extract document_id; I wish they had given me a key
my $key        =  basename( $tsv ,  ( '.wrd' ) );
my @parts      =  split( '-', $key );
my $documentid =  $parts[ 1 ];
$documentid    =~ s/^0+//;

# debug
warn "$key\n";

# generate output file
my $output = SQLWRD . "/$key.sql";

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
	my ( $id, $keyword ) = split( '\t', $_ );
	
	# escape
	$keyword =~ s/'/''/g;
	
	# build INSERT statement
	my $insert =  TEMPLATE;
	$insert    =~ s/##DOCUMENTID##/$documentid/e;
	$insert    =~ s/##KEYWORD##/$keyword/e;
		
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

