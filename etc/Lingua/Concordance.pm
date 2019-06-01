package Lingua::Concordance;

# Concordance.pm - keyword-in-context (KWIC) search interface

# Eric Lease Morgan <eric_morgan@infomotions.com>
# June     7, 2009 - first investigations
# June     8, 2009 - tweaked _by_match; still doesn't work quite right
# August  29, 2010 - added scale, positions, and map methods
# August  31, 2010 - removed \r & \t from input, duh!
# October 31, 2010 - removed syntax error from synopsis


# configure defaults
use constant RADIUS  => 20;
use constant SORT    => 'none';
use constant ORDINAL => 1;
use constant SCALE   => 10;

# include
use strict;
use warnings;
use Math::Round;

# define
our $VERSION = '0.04';


sub new {

	# get input
	my ( $class ) = @_;
	
	# initalize
	my $self = {};
	
	# set defaults
	$self->{ radius }  = RADIUS;
	$self->{ sort }    = SORT;
	$self->{ ordinal } = ORDINAL;
	$self->{ scale }   = SCALE;
	
	# return
	return bless $self, $class;
	
}


sub text {

	# get input
	my ( $self, $text ) = @_;
	
	# check...
	if ( $text ) {
	
		# clean...
		$text =~ s/\t/ /g;
		$text =~ s/\r/ /g;
		$text =~ s/\n/ /g;
		$text =~ s/ +/ /g;
		$text =~ s/\b--\b/ -- /g;
		
		# set
		$self->{ text } = $text;
		
	}
	
	# return
	return $self->{ text };
	
}


sub query {

	# get input; check & set; return
	my ( $self, $query ) = @_;
	if ( $query ) { $self->{ query } = $query }
	return $self->{ query };
	
}


sub scale {

	# get input; check & set; return
	my ( $self, $scale ) = @_;
	if ( $scale ) { $self->{ scale } = $scale }
	return $self->{ scale };
	
}


sub map {

	# get input
	my ( $self ) = shift;

	# initialize 
	my %map       = ();
	my $scale     = $self->scale;
	my @positions = $self->positions;
	my $length    = length( $self->text );
	
	for ( my $i = 1; $i <= $scale; $i++ ) { $map{ round(( $i * ( 100 / $scale ))) } = 0 }
	my @locations = sort { $a <=> $b } keys %map;
	
	# process each position
	foreach ( @positions ) {
		
		# calculate postion as a percentage of length
		my $position = round(( $_ * 100 ) / $length );	
	
		# map the position to a location on the scale; this is the cool part
		my $location = 0;
		for ( my $i = 0; $i <= $#locations; $i++ ) {
		
			if ( $position >= 0 and $position <= $locations[ $i ] ) {
			
				$location = $locations[ $i ];
				last;
			
			}
			elsif ( $position > $locations[ $i ] and $position <= $locations[ $i + 1 ] ) { $location = $locations[ $i + 1 ] }
			elsif ( $position <= 100 ) { $location = 100 }
		
		}
	
		# increment
		$map{ $location }++;
		
	}

	# done
	return \%map;
	
}


sub positions {

	my ( $self ) = @_;
	my @p = ();
	my $query = $self->{ query };
	my $text  = $self->{ text };	
	while ( $text =~ m/$query/gi ) { push @p, pos $text }
	return @p;

}


sub radius {

	# get input; check & set; return
	my ( $self, $radius ) = @_;
	if ( $radius ) { $self->{ radius } = $radius }
	return $self->{ radius };
	
}


sub ordinal {

	# get input; check & set; return
	my ( $self, $ordinal ) = @_;
	if ( $ordinal ) { $self->{ ordinal } = $ordinal }
	return $self->{ ordinal };
	
}


sub sort {

	# get input; check & set; return
	my ( $self, $sort ) = @_;
	if ( $sort ) { $self->{ sort } = $sort }
	return $self->{ sort };
	
}


sub lines {

	# get input
	my ( $self ) = shift;
	
	# declare
	my @lines        = ();
	my @sorted_lines = ();
	
	# define
	my $text     = $self->text;
	my $query    = $self->query;
	my $radius   = $self->radius;
	my $width    = 2 * $self->radius;
	my $ordinal  = $self->ordinal;
		
	# cheat; because $1, below, is not defined at compile time?
	no warnings;

	# gete the matching lines
	while ( $text =~ /$query/gi ) {
	
		my $match   = $1;
		my $pos     = pos( $text );
		my $start   = $pos - $self->radius - length( $match );
		my $extract = '';
		
		if ( $start < 0 ) {
		
			$extract = substr( $text, 0, $width + $start + length( $match ));
			$extract = ( " " x -$start ) . $extract;
			
		}
		
		else {
		
			$extract = substr( $text, $start, $width + length( $match ));
			my $deficit = $width + length( $match ) - length( $extract );
			if ( $deficit > 0 ) { $extract .= ( " " x $deficit ) }
		
		}
		
		push @lines, $extract;
	
	}
	
	# brach according to sorting preference
	if ( $self->sort eq 'left' ) {
	
		foreach ( sort { _by_left( $self, $a, $b ) } @lines ) { push @sorted_lines, $_ }

	}
	
	elsif ( $self->sort eq 'right' ) {
	
		foreach ( sort { _by_right( $self, $a, $b ) } @lines ) { push @sorted_lines, $_ }

	}
	
	elsif ( $self->sort eq 'match' ) {
	
		foreach ( sort { _by_match( $self, $a, $b ) } @lines ) { push @sorted_lines, $_ }

	}
	
	else { @sorted_lines = @lines }
	
	# done
	return @sorted_lines;
	
}


sub _by_left {

	# get input; find left word, compare, return
	my ( $self, $a, $b ) = @_;
	return lc( _on_left( $self, $a )) cmp lc( _on_left( $self, $b )); 
	
}


sub _on_left {

	# get input; remove punctuation; get left string; split; return ordinal word
	my ( $self, $s ) = @_;
	my @words = split( /\s+/, &_remove_punctuation( $self, substr( $s, 0, $self->radius )));
	return $words[ scalar( @words ) - $self->ordinal - 1 ];

}


sub _remove_punctuation {
	
	my ( $self, $s ) = @_;
	$s = lc( $s );
	$s =~ s/[^-a-z ]//g;
	$s =~ s/--+/ /g;
	$s =~ s/-//g;
	$s =~ s/\s+/ /g;
	return $s;

}


sub _by_right {

	# get input; find right word, compare, return
	my ( $self, $a, $b ) = @_;
	return lc( _on_right( $self, $a )) cmp lc( _on_right( $self, $b )); 
	
}


sub _on_right {

	# get input; remove punctuation; get right string; split; return ordinal word
	my ( $self, $s ) = @_;
	my @words = split( /\s+/, &_remove_punctuation( $self, substr( $s, -$self->radius )));
	return $words[ $self->ordinal ];

}


sub _by_match {

	my ( $self, $a, $b ) = @_;		
	return substr( $a, length( $a ) - $self->radius ) cmp substr( $b, length( $b ) - $self->radius );
	
}


=head1 NAME

Lingua::Concordance - Keyword-in-context (KWIC) search interface


=head1 SYNOPSIS

  # require
  use Lingua::Concordance;

  # initialize
  $concordance = Lingua::Concordance->new;
  $concordance->text( 'A long time ago, in a galaxy far far away...' );
  $concordance->query( 'far' );

  # do the work
  foreach ( $concordance->lines ) { print "$_\n" }

  # modify the query and map (graph) it
  $concordance->query( 'i' );
  $map = $concordance->map;
  foreach ( sort { $a <=> $b } keys %map ) { print "$_\t", $$map{ $_ }, "\n" }


=head1 DESCRIPTION

Given a scalar (such as the content of a plain text electronic book or journal article) and a regular expression, this module implements a simple keyword-in-context (KWIC) search interface -- a concordance. Its purpuse is two-fold. First, it is intended to return lists of lines from a text containing the given expression. Second, it is intended to map the general location in the text where the expression appears. For example, the first half of the text, the last third, the third quarter, etc. See the Discussion section, below, for more detail.


=head1 METHODS


=head2 new

Create a new, empty concordance object:

  $concordance = Lingua::Concordance->new;


=head2 text

Set or get the value of the concordance's text attribute where the input is expected to be a scalar containing some large amount of content, like an electronic book or journal article:

  # set text attribute
  $concordance->text( 'Call me Ishmael. Some years ago- never mind how long...' );

  # get the text attribute
  $text = $concordance->text;

Note: The scalar passed to this method gets internally normalized, specifically, all carriage returns are changed to spaces, and multiple spaces are changed to single spaces.


=head2 query

Set or get the value of the concordance's query attribute. The input is expected to be a regular expression but a simple word or phrase will work just fine:

  # set query attribute
  $concordance->query( 'Ishmael' );

  # get query attribute
  $query = $concordance->query;

See the Discussion section, below, for ways to make the most of this method through the use of powerful regular expressions. This is where the fun it.


=head2 radius

Set or get the length of each line returned from the lines method, below. Each line will be padded on the left and the right of the query with the number of characters necessary to equal the value of radius. This makes it easier to sort the lines:

  # set radius attribute
  $concordance->radius( $integer );

  # get radius attribute
  $integer = $concordance->query;
	
For terminal-based applications it is usually not reasonable to set this value to greater than 30. Web-based applications can use arbitrarily large numbers. The internally set default value is 20.


=head2 sort

Set or get the type of line sorting:

  # set sort attribute
  $concordance->sort( 'left' );

  # get sort attribute
  $sort = $concordance->sort;
	
Valid values include:

=over

* none - the default value; sorts lines in the order they appear in the text -- no sorting

* left - sorts lines by the (ordinal) word to the left of the query, as defined the ordinal method, below

* right - sorts lines by the (ordinal) word to the right of the query, as defined the ordinal method, below

* match - sorts lines by the value of the query (mostly)

=back

This is good for looking for patterns in texts, such as collocations (phrases, bi-grams, and n-grams). Again, see the Discussion section for hints.


=head2 ordinal

Set or get the number of words to the left or right of the query to be used for sorting purposes. The internally set default value is 1:

  # set ordinal attribute
  $concordance->ordinal( 2 );

  # get ordinal attribute
  $integer = $concordance->ordinal;

Used in combination with the sort method, above, this is good for looking for textual patterns. See the Discussion section for more information.


=head2 lines

Return a list of lines from the text matching the query. Our reason de existance:

  # get the line containing the query
  @lines = $concordance->lines;


=head2 positions

Return an array of integers representing the locations (offsets) of the query in the text.

  # get positions of queries in a text
  @positions = $concordance->positions;


=head2 scale

Set or get the scale for mapping query locations to positions between 0 and 100. 

  # set the scale
  $concordance->scale( 5 );

  # get the scale
  $scale = $concordance->scale;

This number is used to initialize a scale from 0 to 100 where scale is a percentage of the whole text. A value of 2 will divide the text into two halves. A value of 3 will divide the text into three parts, all equal to 33% of the text's length. A value of 5 will create five equal parts all equal to 20% of the text. 

The default is 10.


=head2 map

Returns a reference to a hash where the keys are integers representing locations on a scale between 0 and 100, inclusive. The values are the number of matched queries located at that position.

  # map the query to percentages of the text
  $map = $concordance->map;

  # list the sections of the text where the query appears
  foreach ( sort { $a <=> $b } keys %map ) { print "$_\t", $$map{ $_ }, "\n" }

The output of this method is intended to facilitate the graphing of matched queries on a bar chart where the hash's keys represent ranges along the X-axis and the values represent points up and down the Y-axis. The script in this distribution named bin/concordance.pl illustrates how to do this with a Perl module caled Text::BarGraph.


=head1 DISCUSSION

[Elaborate upon a number of things here such as but not limited to: 1) the history of concordances and concordance systems, 2) the usefulness of concordances in the study of literature, 3) how to expoit regular expressions to get the most out of a text and finding interesting snipettes, and 4) how the module might be implemented in scripts and programs.]


=head1 BUGS

The internal _by_match subroutine, the one used to sort results by the matching regular expression, does not work exactly as expected. Instead of sorting by the matching regular expression, it sorts by the string exactly to the right of the matched regular expression. Consquently, for queries such as 'human', it correctly matches and sorts on human, humanity, and humans, but matches such as Humanity do not necessarily come before humanity.


=head1 TODO

=over

* Write Discussion section.

* Implement error checking.

* Fix the _by_match bug.

* Enable all of the configuration methods (text, query, radius, sort, and ordinal) to be specified in the constructor.

* Require the text and query attributes to be specified as a part of the constructor, maybe.

* Remove line-feed characters while normalizing text to accomdate Windows-based text streams, maybe.

* Write an example CGI script, to accompany the distribution's terminal-based script, demonstrating how the module can be implemented in a Web interface.

* Write a full-featured terminal-based script enhancing the one found in the distribution.

=back

=head1 CHANGES

=over

* June 9, 2009 - initial release

* August 29, 2010 - added the postions, scale, and map methods

* October 31, 2010 - removed syntax error from synopsis ("Thank you, Pankaj Mehra.")

=back

=head1 ACKNOWLEDGEMENTS

The module implementes, almost verbatim, the concordance programs and subroutines described in Bilisoly, R. (2008). Practical text mining with Perl. Wiley series on methods and applications in data mining. Hoboken, N.J.: Wiley. pgs: 169-185. "Thanks Roger. I couldn't have done it without your book!"


=head1 AUTHOR

Eric Lease Morgan <eric_morgan@infomotions.com>

=cut

# return true or die
1;
