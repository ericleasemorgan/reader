#!/afs/crc.nd.edu/user/e/emorgan/bin/perl

# carrel2zip.pl - given a directory name, zip it

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, distributed under a GNU Public License

# July 14, 2018 - first investigations


# configure
use constant ETC => 'etc';

# require
use Archive::Zip;
use File::Basename;
use strict;

# sanity check
my $directory = $ARGV[ 0 ];
if ( ! $directory ) { die "Usage: $0 <directory>\n" }

# initialize
my $etc    = ETC;
my $carrel = basename( $directory );
my $zip    = Archive::Zip->new();

# do the work
$zip->addTree( $directory, $carrel );
$zip->writeToFileNamed( "$directory/$etc/$carrel.zip" );

# done
exit;


