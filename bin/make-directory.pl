#!/usr/bin/env perl

# make-directory.pl - given a few pre-configurations, output a HTML directory of study carrels
# usage: ./bin/make-directory.pl > /export/reader/carrels/INDEX.HTM

# Eric Lease Morgan <emorgan@nd.edu.
# May 26, 2020 - first move to Project CORD


# configure
use constant TEMPLATE => './etc/directory.htm';
use constant TABLE    => './etc/table.tsv';
use constant VIEW     => "<a href='./##SHORTNAME##/'>view</a>";
use constant DOWNLOAD => "<a href='./##SHORTNAME##/study-carrel.zip'>download</a>";

# require
use strict;

# initialize
my $table = TABLE;
my @rows  = ();

# open the data file and process each line; build a list of rows
open TSV, "< $table" or die "Can't open $table ($!)\n";
while ( <TSV> ) {

	# parse
	chop;
	my( $shortname, $date, $keyword, $items, $words, $flesch, $size ) = split( "\t", $_ );
	
	# build a link to the given study carrel
	my $view     =  VIEW;
	$view        =~ s/##SHORTNAME##/$shortname/eg;
	my $download =  DOWNLOAD;
	$download    =~ s/##SHORTNAME##/$shortname/eg;
	
	# build the row and update the list of them
	my $row = "<tr><td>$shortname ($view, $download)</td><td>$date</td><td>$keyword</td><td class='right'>$items</td><td class='right'>$words</td><td  class='right'>$flesch</td><td class='right'>$size</td></tr>";
	push( @rows, $row );
	
}

# sort the rows by name, slurp up the template, substitute, and output
my $rows =  join( "\n", sort( @rows ) );
my $html =  &slurp( TEMPLATE );
$html    =~ s/##ROWS##/$rows/e;
print $html;

# done
exit;


sub slurp {

	my $f = shift;
	open ( F, $f ) or die "Can't open $f: $!\n";
	my $r = do { local $/; <F> };
	close F;
	return $r;

}