package Lingua::EN::Ngram;

# Ngram.pm - Extract and count words and phrases from texts

# Eric Lease Morgan <eric_morgan@infomotions.com>
# September 12, 2010 - first investigations; based on Lingua::EN::Bigram
# November  25, 2010 - added non-Latin characters; Happy Thanksgiving!
# March     28, 2018 - removed lower-casing the text; why did I do lower case previously? 


# include
use strict;
use warnings;

# define
our $VERSION = '0.03';


sub new {

	# get input
	my ( $class, %options ) = @_;
	
	# initialize
	my $self = {};

	# process optional options
	if ( %options ) {
	
		# check for one and only one argument
		my @keys = keys %options;
		if ( scalar @keys != 1 ) { die "This method -- new -- can only take one and only one option (text or file)." }
		
		# initalize from text
		if ( $options{ 'text' } ) { $self->{ text } = $options{ 'text' } }
	
		# initialize from file
		elsif ( $options{ 'file' } ) {
		
			# slurp
			my $file = $options{ 'file' };
			open F, $file or die "The file argument ($file) passed to this method is invalid: $!\n";
			my $text = do { local $/; <F> };
			close F;
			
			# do the work
			$self->{ text } = $text;
			
		}
		
		# invalid option
		else { die "This method -- new -- can only take one option, text or file." }
		
	}
		
	# return
	return bless $self, $class;
	
}


sub text {

	# get input
	my ( $self, $text ) = @_;
	
	# set
	if ( $text ) { $self->{ text } = $text }
	
	# return
	return $self->{ text };
	
}


sub ngram {

	# get input
	my ( $self, $n ) = @_;

	# sanity check
	if ( ! $n ) { die "This method -- ngram -- requires an integer as an argument." }
	if ( $n =~ /\D/ ) { die "This method -- ngram -- requires an integer as an argument." }
	
	# initalize
	my $text = $self->text;
	$text =~ tr/a-zA-Zà-ƶÀ-Ƶ'()\-,.?!;:/\n/cs;
	$text =~ s/([,.?!:;()\-])/\n$1\n/g;
	$text =~ s/\n+/\n/g;
	my @words = split /\n/, $text;

	my @ngrams = ();
	my %count  = ();
	no warnings;

	# process each word
	for ( my $i = 0; $i <= $#words; $i++ ) {
	
		# repeat n number of times
		my $tokens = '';
		for ( my $j = $i; $j < $i + $n; $j++ ) { $tokens .= $words[ $j ] . ' ' }
		
		# remove the trailing space
		chop $tokens;
		
		# build the ngram and count
		$ngrams[ $i ] = $tokens;
		$count{ $ngrams[ $i ] }++;
		
	}
	
	# done
	return \%count;

}


sub tscore {

	# get input
	my ( $self ) = shift;
	
	# get all the words
	my $text = $self->text;
	$text =~ tr/a-zA-Z'()\-,.?!;:/\n/cs;
	$text =~ s/([,.?!:;()\-])/\n$1\n/g;
	$text =~ s/\n+/\n/g;
	my @words = split /\n/, $text;

	# count the words
	my %word_count = ();
	for ( my $i = 0; $i <= $#words; $i++ ) { $word_count{ $words[ $i ] }++ }
	
	# get all the bigrams
	my @bigrams = ();
	for ( my $i = 0; $i < $#words; $i++ ) {
	
		# repeat n number of times
		my $tokens = '';
		for ( my $j = $i; $j < $i + 2; $j++ ) { $tokens .= $words[ $j ] . ' ' }
		
		# remove the trailing space
		chop $tokens;
		
		# build the ngram
		$bigrams[ $i ] = $tokens;
		
	}

	# count the bigrams
	my %bigram_count = ();
	for ( my $i = 0; $i < $#words; $i++ ) { $bigram_count{ $bigrams[ $i ] }++ }

	# calculate t-score
	my %tscore = ();
	for ( my $i = 0; $i < $#words; $i++ ) {

		$tscore{ $bigrams[ $i ] } = ( $bigram_count{ $bigrams[ $i ] } - 
	                                  $word_count{ $words[ $i ] } * 
	                                  $word_count{ $words[ $i + 1 ] } / 
	                                  ( $#words + 1 ) ) / sqrt( $bigram_count{ $bigrams[ $i ] } );

	}
	
	# done
	return \%tscore;
	
}


sub intersection {

	# get input
	my ( $self, %options ) = @_;

	# initialize
	my %intersections = ();
	my %ngrams        = ();
	my @counts        = ();
	my $objects       = '';
	my $length        = 0;
	no warnings;
	
	# sanity checks
	if ( ! %options ) { die 'This method -- interesection -- requires two options: corpus and length.' }
	else {
	
		if ( scalar keys %options != 2 ) { die 'This method -- interesection -- requires two options: corpus and length.' }
		elsif ( ! $options{ 'corpus' } or ! $options{ 'length' } ) { die 'This method -- interesection -- requires two options: corpus and length.' }
		else {
		
			$objects = $options{ 'corpus' };
			if ( ref( $objects ) ne 'ARRAY' )  { die 'The corpus option passed to the interesections method must be an array reference.' }
		
			$length = $options{ 'length' };
			if ( $length =~ /\D/ ) { die "The length option passed to the intersections method mus be an integer." }

		}
	
	}
	
	
	# process each object
	for ( my $i = 0; $i <= $#$objects; $i++ ) {
			
		# count each ngram
		my $count  = $$objects[ $i ]->ngram( $length );
		foreach ( keys %$count ) { $ngrams{ $_ }++ }
		
		# save counts for later reference; all puns intended
		$counts[ $i ] = $count;
					
	}
	
	# process each ngram
	foreach ( keys %ngrams ) {

		# check for intersection; ngram in all total number of objects
		if ( $ngrams{ $_ } == ( $#$objects + 1 )) {
		
			# calculate total occurances
			my $total = 0;
			for ( my $i = 0; $i <= $#$objects; $i++ ) { $total += $counts[ $i ]{ $_ }}
			
			# update result
			$intersections{ $_ } = $total;
   
		}

	}

	# done
	return \%intersections;
	
}


=head1 NAME

Lingua::EN::Ngram - Extract n-grams from texts and list them according to frequency and/or T-Score


=head1 SYNOPSIS

  # initalize
  use Lingua::EN::Ngram;
  $ngram = Lingua::EN::Ngram->new( file => './etc/walden.txt' );

  # calculate t-score; t-score is only available for bigrams
  $tscore = $ngram->tscore;
  foreach ( sort { $$tscore{ $b } <=> $$tscore{ $a } } keys %$tscore ) {

    print "$$tscore{ $_ }\t" . "$_\n";

  }

  # list trigrams according to frequency
  $trigrams = $ngram->ngram( 3 );
  foreach my $trigram ( sort { $$trigrams{ $b } <=> $$trigrams{ $a } } keys %$trigrams ) {

      print $$trigrams{ $trigram }, "\t$trigram\n";

  }


=head1 DESCRIPTION

This module is designed to extract n-grams from texts and list them according to frequency and/or T-Score.

To elaborate, the purpose of Lingua::EN::Ngram is to: 1) pull out all of the ngrams (multi-word phrases) in a given text, and 2) list these phrases according to their frequency. Using this module is it possible to create lists of the most common phrases in a text as well as order them by their probable occurance, thus implying significance. This process is useful for the purposes of textual analysis and "distant reading".

The two-word phrases (bigrams) are also listable by their T-Score. The T-Score, as well as a number of the module's other methods, is calculated as per Nugues, P. M. (2006). An introduction to language processing with Perl and Prolog: An outline of theories, implementation, and application with special consideration of English, French, and German. Cognitive technologies. Berlin: Springer.

Finally, the intersection method enables the developer to find ngrams common in an arbitrary number of texts. Use this to look for common themes across a corpus.


=head1 METHODS


=head2 new

Create a new Lingua::EN::Ngram object:

  # initalize
  $ngram = Lingua::EN::Ngram->new;


=head2 new( text => $scalar )

Create a new Lingua::EN::Ngram object whose contents equal the content of a scalar:

  # initalize with scalar
  $ngram = Lingua::EN::Ngram->new( text => 'All good things must come to an end...' );


=head2 new( file => $scalar )

Create a new Lingua::EN::Ngram object whose contents equal the content of a file:

  # initalize with file
  $ngram = Lingua::EN::Ngram->new( file => './etc/rivers.txt' );


=head2 text

Set or get the text to be analyzed:

  # fill Lingua::EN::Ngram object with content 
  $ngram->text( 'All good things must come to an end...' );

  # get the Lingua::EN::Bigram object's content 
  $text = $ngram->text;


=head2 tscore

Return a reference to a hash whose keys are a bigram and whose values are a T-Score -- a probabalistic calculation determining the significance of the bigram occuring in the text:

  # get t-score
  $tscore = $ngrams->tscore;

  # list bigrams according to t-score
  foreach ( sort { $$tscore{ $b } <=> $$tscore{ $a } } keys %$tscore ) {

	  print "$$tscore{ $_ }\t" . "$_\n";

  }

T-Score can only be computed against bigrams.


=head2 ngram( $scalar )

Return a hash reference whose keys are ngrams of length $scalar and whose values are the number of times the ngrams appear in the text:

  # create a list of trigrams
  $trigrams = $ngrams->ngram( 3 );

  # display frequency
  foreach ( sort { $$trigrams{ $b } <=> $$trigrams{ $a } } keys %$trigrams ) {

    print $$trigrams{ $_ }, "\t$_\n";

  }

This method requires a single parameter and that parameter must be an integer. For example, to get a list of bigrams, pass 2 to ngram. To get a list of quadgrams, pass 4.


=head2 intersection( corpus => [ @array ], length => $scalar )

Return a hash reference whose keys are ngrams of length $scalar and whose values are the number of times the ngrams appear in a corpus of texts:

  # build corpus
  $walden = Lingua::EN::Ngram->new( file => './etc/walden.txt' );
  $rivers = Lingua::EN::Ngram->new( file => './etc/rivers.txt' );
  $corpus = Lingua::EN::Ngram->new;

  # compute intersections
  $intersections = $corpus->intersection( corpus => [ ( $walden, $rivers ) ], length => 5 );

  # display frequency
  foreach ( sort { $$intersections{ $b } <=> $$intersections{ $a }} keys %$intersections ) {

    print $$intersections{ $_ }, "\t$_\n";

  }

The value of corpus must be an array reference, and each element must be Lingua::EN::Ngram objects. The value of length must be an integer.


=head1 DISCUSSION

Given the increasing availability of full text materials, this module is intended to help "digital humanists" apply mathematical methods to the analysis of texts. For example, the developer can extract the high-frequency words using the ngram method and allow the user to search for those words in a concordance. The use of ngram( 2 ) simply returns the frequency of bigrams in a text, but the tscore method can order them in a more finely tuned manner.

Consider using T-Score-weighted bigrams as classification terms to supplement the "aboutness" of texts. Concatonate many texts together and look for common phrases written by the author. Compare these commonly used phrases to the commonly used phrases of other authors.

All ngrams return by the ngram method include punctuation. This is intentional. Developers may need want to remove ngrams containing such values from the output. Similarly, no effort has been made to remove commonly used words -- stop words -- from the methods. Consider the use of Lingua::StopWords, Lingua::EN::StopWords, or the creation of your own stop word list to make output more meaningful. The distribution came with a script (bin/ngrams.pl) demonstrating how to remove puncutation from the displayed output. Another script (bin/intesections.pl) demonstrates how to extract and count ngrams across two texts.

Finally, this is not the only module supporting ngram extraction. See also Text::NSP.


=head1 TODO

There are probably a number of ways the module can be improved:

=over

* the distribution's license should probably be changed to the Perl Aristic License

* the addition of alternative T-Score calculations would be nice

* make sure the module works with character sets beyond ASCII (done, I think, as of version 0.02)

=back


=head1 CHANGES

=over

* March 28, 2018 (version 0.03) - removed lower casing of letters and install ngrams script

* November 25, 2010 (version 0.02) - added non-Latin characters

* September 12, 2010 (version 0.01) - initial release but an almost complete rewrite of Lingua::EN::Bigram



=back

=head1 ACKNOWLEDGEMENTS

T-Score, as well as a number of the module's methods, is calculated as per Nugues, P. M. (2006). An introduction to language processing with Perl and Prolog: An outline of theories, implementation, and application with special consideration of English, French, and German. Cognitive technologies. Berlin: Springer.


=head1 AUTHOR

Eric Lease Morgan <eric_morgan@infomotions.com>

=cut

# return true or die
1;
