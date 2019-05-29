#!/usr/bin/env perl

use strict;

my $file      = $ARGV[ 0 ];
my $directory = $ARGV[ 1 ];
if ( ! $file or ! $directory ) { die "Usage: $0 <file> <directory>\n" }

open INPUT, " < $file " or die "Can't open input ($!)\n";
my $item = 0;

while ( <INPUT> ) {

	chop;
	my $line = $_;
	$item++;
	open OUTPUT, " > $directory/item-$item.txt" or die "Can't open output\n";
	print OUTPUT $line;
	close OUTPUT;

}

close INPUT;
exit;
