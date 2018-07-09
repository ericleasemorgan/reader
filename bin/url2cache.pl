#!/usr/bin/env perl

# configure
use constant MIME    => ( 'application/xml' => 'xml', 'application/atom+xml' => 'xml', 'image/png' => 'png', 'application/rss+xml' => 'xml', 'text/xml' => 'xml', 'image/jpeg' => 'jpg', 'text/csv' => 'csv', 'text/plain' => 'txt', 'text/html' => 'html', 'image/gif' => 'gif', 'application/pdf' => 'pdf' );
use constant TIMEOUT => 10;

# require
use LWP::UserAgent;
use strict;
require './lib/reader.pl';

# read input
my $url       = $ARGV[ 0 ];
my $directory = $ARGV[ 1 ];
my $item      = $ARGV[ 2 ];

# validate input
if ( ! $url || ! $directory || $item < 0 ) { die "Usage: $0 <url> <directory> <item>\n" }

# initialize
my %mime   = MIME;
my $client = LWP::UserAgent->new;
$client->timeout( TIMEOUT );

# don't process particular types of urls
exit if ( $url =~ /^mailto/ || $url =~ /\.css$/ || $url =~ /\.js$/ );

# peek at the document
my $response = $client->head( $url );

# found something
if ( $response->is_success ) {

	# extract mime type and map it to a local extension
	my $type      = ( $response->content_type )[ 0 ];
	my $extension = $mime{ $type };
	
	# if found
	if ( $extension ) {
	
		# get the content at the other end of the url
		my $response = $client->get( $url );

		# check, again
		if ( $response->is_success ) {
		
			# build file name
			my $filename = &make_filename( $url, $directory, $item, $extension );
			
			# check for html
			if ( $extension eq 'html' ) {
			
				# get html and convert relative urls to absolute
				my $html = &make_absolute( $response->decoded_content, $response->base );

				# save
				open OUTPUT, " > $filename" or die "Can't open $filename ($!). Call Eric. \n";
				binmode( OUTPUT, ":utf8" );
				print OUTPUT $html;
				close OUTPUT;
		
				# return possible additional work
				if ( $item == 0 ) { 
					
					foreach my $url ( &extract_links( $filename ) ) { print "$url\n" }
					
				}
			
			}
			
			# process everything else
			else {
							
				# just save
				open OUTPUT, " > $filename" or die "Can't open $filename ($!). Call Eric. \n";
				binmode( OUTPUT, ":utf8" );
				print OUTPUT $response->decoded_content;
				close OUTPUT;

			}
						
		}
		
	}
	
	else { warn "Warning: Unprocessed MIME-type($type) . Ignorning. Call Eric?\n"; }
	
}

else { die $response->status_line }