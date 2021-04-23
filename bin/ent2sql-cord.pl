#!/usr/bin/env perl

# ent2sql-cord.sh - given a TSV file of keywords, output a set of SQL INSERT statements
# usage: mkdir -p ./cord/sql-ent; find ./cord/ent -name "*.ent" | parallel --will-cite ./bin/ent2sql-cord.pl

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 26, 2020 - copying to CORD


# configure
use constant SQLENT   => './cord/sql-ent';
use constant TEMPLATE => "INSERT INTO ent ( 'document_id', 'sid', 'eid', 'entity', 'type' ) VALUES ( '##DOCUMENTID##', '##SID##', '##EID##', '##ENTITY##', '##TYPE##' );";

# require
use strict;
use File::Basename;

# get input
my $tsv = $ARGV[ 0 ];
if ( ! $tsv ) { die "Usage: $0 <ent>\n" }

# extract document_id; I wish they had given me a key
my $key        =  basename( $tsv ,  ( '.ent' ) );
my @parts      =  split( '-', $key );
my $documentid =  $parts[ 1 ];
$documentid    =~ s/^0+//;

# debug
warn "$key\n";

# generate output file
my $output = SQLENT . "/$key.sql";

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
	my ( $id, $sid, $eid, $entity, $type ) = split( '\t', $_ );
	
	# escape
	$entity =~ s/'/''/g;
	
	# build INSERT statement
	my $insert =  TEMPLATE;
	$insert    =~ s/##DOCUMENTID##/$documentid/e;
	$insert    =~ s/##SID##/$sid/e;
	$insert    =~ s/##EID##/$eid/e;
	$insert    =~ s/##ENTITY##/$entity/e;
	$insert    =~ s/##TYPE##/$type/e;
		
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

