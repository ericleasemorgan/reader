#!/afs/crc.nd.edu/user/e/emorgan/bin/perl

# carrel2zip.pl - given a directory name, zip it

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame, distributed under a GNU Public License

# July 14, 2018 - first investigations


# configure
use constant ETC     => 'etc';
use constant CARRELS => '/afs/crc.nd.edu/user/e/emorgan/local/reader/carrels';

# require
use Archive::Zip;
use File::Basename;
use strict;

# sanity check
my $name = $ARGV[ 0 ];
if ( ! $name ) { die "Usage: $0 <name>\n" }

# initialize
my $etc     = ETC;
my $carrels = CARRELS;
my $zip     = Archive::Zip->new();

# do the work
$zip->addTree( "$carrels/$name", $name );
$zip->writeToFileNamed( "$carrels/$name/$etc/$name.zip" );

# done
exit;


