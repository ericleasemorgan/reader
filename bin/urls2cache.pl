#!/usr/bin/env perl

# url2cache.pl - given a URL, cache the remote content in a "study carrel"

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame and distributed under a GNU Public License

# July 10, 2018 - first cut


# configure
use constant MIME    => ( 'application/xml' => 'xml', 'application/atom+xml' => 'xml', 'image/png' => 'png', 'application/rss+xml' => 'xml', 'text/xml' => 'xml', 'image/jpeg' => 'jpg', 'text/csv' => 'csv', 'text/plain' => 'txt', 'text/html' => 'html', 'image/gif' => 'gif', 'application/pdf' => 'pdf' );
use constant TIMEOUT => 10;

# require
use LWP::UserAgent;
use strict;
require '/export/reader/lib/reader.pl';

# read input
my $url       = $ARGV[ 0 ];
my $directory = $ARGV[ 1 ];

# validate input
if ( ! $url || ! $directory ) { die "Usage: $0 <url> <directory>\n" }

# initialize
my %mime   = MIME;
my $client = LWP::UserAgent->new;
$client->timeout( TIMEOUT );

# don't process particular types of urls
exit if ( $url =~ /^mailto/ );

# peek at the document
my $response = $client->head( $url );

# found something
if ( $response->is_success ) {

	# extract mime type and map it to a local extension
	my $type      = ( $response->content_type )[ 0 ];
	my $extension = $mime{ $type };
	
	# if found
	if ( $extension ) {
			
		# build file name
		my $filename = &make_filename( $url, $directory, $extension );
		warn "filename: $filename\n";
		
		# check for html
		if ( $extension eq 'html' ) {
		
			# get html and convert relative urls to absolute
			my $html = &make_absolute( $response->decoded_content, $response->base );
			
			# actually do the work but cheat with a more robust application; wget++
			`wget -t 5 -k "$url" -O "$filename"`;
				
		}
		
		# process everything else
		else {
						
			# actually do the work but cheat with a more robust application; wget++
			`wget -t 5 "$url" -O "$filename"`;

		}
								
	}
	
	else { warn "Warning: Unprocessed MIME-type($type) . Ignorning. Call Eric?\n"; }
	
}

else { die $response->status_line }