#!/usr/bin/env perl

# ent2sql.sh - given a TSV file of keywords, output a set of SQL INSERT statements
# usage: mkdir -p ./tmp/sql-pos; find ./pos -name "*.pos" | parallel --will-cite /export/reader/bin/pos2sql.pl

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# June 22, 2020 - re-wrote in Perl and now a whole lot faster; "Thanks Bill Duper!"


# configure
use constant SQLPOS   => './tmp/sql-pos';
use constant TEMPLATE => "INSERT INTO pos ( 'id', 'sid', 'tid', 'token', 'lemma', 'pos' ) VALUES ( '##ID##', '##SID##', '##TID##', '##TOKEN##', '##LEMMA##', '##POS##' );";

# require
use strict;
use File::Basename;

# get input
my $tsv = $ARGV[ 0 ];
if ( ! $tsv ) { die "Usage: $0 <pos>\n" }

# extract document_id; I wish they had given me a key
my $key        =  basename( $tsv ,  ( '.pos' ) );
my @parts      =  split( '-', $key );
my $documentid =  $parts[ 1 ];
#$documentid    =~ s/^0+//;
$documentid    = $key;

# debug
warn "$key\n";

# generate output file
my $output = SQLPOS . "/$key.sql";

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
	my ( $id, $sid, $tid, $token, $lemma, $pos ) = split( '\t', $_ );
	
	# escape
	$token =~ s/'/''/g;
	$lemma =~ s/'/''/g;
	
	# build INSERT statement
	my $insert =  TEMPLATE;
	$insert    =~ s/##ID##/$documentid/e;
	$insert    =~ s/##SID##/$sid/e;
	$insert    =~ s/##TID##/$tid/e;
	$insert    =~ s/##TOKEN##/$token/e;
	$insert    =~ s/##LEMMA##/$lemma/e;
	$insert    =~ s/##POS##/$pos/e;
		
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

