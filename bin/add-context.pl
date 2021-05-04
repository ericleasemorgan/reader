#!/usr/bin/env perl

# add-context.pl - given the name of a study carrel, update its home page with provenance (metadata)
# usage: ./bin/add-context.pl carrel > /export/reader/carrels/carrel/index.html

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNU Public License

# May  25, 2020 - written elsewhere but put into place here for Project CORD
# June 13, 2020 - tweeked template


# configure
use constant CONTEXTS => './etc/contexts';
use constant CARRELS  => '/export/reader/carrels';

# require
use strict;

# get input
my $carrel = $ARGV[ 0 ];
if ( ! $carrel ) { die "Usage: $0 <carrel>\n" }

# open the context file, and process each field
my $file = CONTEXTS . "/$carrel.txt";
open CONTEXT, "< $file" or die "Can't open $file ($!)\n";
my %metadata = ();
while ( <CONTEXT> ) {

	# parse & update
	chop;
	my ( $name, $value ) = split( /\t/, $_ );
	$metadata{ $name }   = $value;
	
}
close CONTEXT;

# slurp up the template and do the necessary substitutions
my $metadata =  &template();
$metadata    =~ s/##SCOPENOTE##/$metadata{ 'SCOPENOTE' }/e;
$metadata    =~ s/##CREATOR##/$metadata{ 'CREATOR' }/e;
$metadata    =~ s/##EMAIL##/$metadata{ 'EMAIL' }/eg;
$metadata    =~ s/##CREATIONDATE##/$metadata{ 'CREATIONDATE' }/e;

# slurp up the HTML and do the necessary substitutions
my $html =  CARRELS . "/$carrel/index.htm";
$html    =  &slurp( $html );
$html    =~ s/Study carrel/$metadata{ 'LONGNAME' }/e;
$html    =~ s/<!--##METADATA##-->/$metadata/e;

# output and done
print $html;
exit;


sub template {

	return <<EOF
<p>##SCOPENOTE##</p>
<p style='text-align: right'>##CREATOR## &lt;<a href='mailto:##EMAIL##'>##EMAIL##</a>&gt;<br />##CREATIONDATE##</p>
EOF

}

sub slurp {

	my $f = shift;
	open ( F, $f ) or die "Can't open $f: $!\n";
	my $r = do { local $/; <F> };
	close F;
	return $r;

}

