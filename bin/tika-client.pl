#!/usr/bin/env perl

# tika-client.pl - given a file, return plain text; a wrapper around tika

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, distributed under a GNU Public License

# November 18, 2017 - first cut; in Pittsburgh on my way to Lancaster


# configure
use constant URL    => 'http://localhost:8080/tika/';
use constant BUFFER => 1024000;

# sanity check
my $file = $ARGV[ 0 ];
if ( ! $file ) { die "Usage: $0 <file>\n" }

# require
use HTTP::Request;
use LWP::UserAgent;
use strict;

# initialize
my $ua = LWP::UserAgent->new;

# create a request and fill it out
my $request = HTTP::Request->new( PUT => URL );
$request->header( 'Accept' => 'text/plain' );
$request->content( &slurp( $file ) );

# send the request and output the response
my $response = $ua->request( $request );
print $response->content;

# done
exit;


# get a file in one go
sub slurp {

	my $f = shift;
	my $d = '';
	
	open DATA, " < $f" or die "Can't open $f ($!).\n";
	read DATA, $d, BUFFER;
	close DATA;
	
	return $d;
	
}

