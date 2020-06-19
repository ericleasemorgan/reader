#!/usr/bin/env perl

# search2queue.cgi - given a few inputs, add a carrel configuration to the queue

# Eric Lease Morgan <emorgan@nd.edu>
# (c) University of Notre Dame; distributed under a GNPU Public License

# June 2, 2020 - first investigations


# configure
use constant TODO => '/export/cord/queue/todo';

# require
use CGI;
use CGI::Carp qw( fatalsToBrowser );
use strict;

# initialize
my $cgi       = CGI->new;
my $html      = '';
my $shortname = $cgi->param( 'shortname' );
my $email     = $cgi->param( 'email' );
my $query     = $cgi->param( 'query' );
my $confirm   = $cgi->param( 'confirm' );
my $queue     = $cgi->param( 'queue' );

# display home page
if ( ! $shortname | ! $email | ! $query ) {

	# initialize and update the HTML; simple
	$html =  &template;
	$html =~ s/##QUERY##/$query/e;

}

# confirm input
elsif ( $confirm ) {

	# initialize and update the HTML; simple
	$html = &confirm;
	$html =~ s/##SHORTNAME##/$shortname/eg;
	$html =~ s/##EMAIL##/$email/eg;
	$html =~ s/##QUERY##/$query/eg;

}

# do the work
elsif ( $queue ) {

	# initialize some more
	my $date = '2020-05-28';
	my $time = '12:00';
    my $todo = TODO . "/$shortname.tsv";
    
	# update the queue
	open QUEUE, " > $todo" or die "Can't open $todo ($!). Call Eric.\n";
	print QUEUE join( "\t", ( $shortname, $date, $time, $email, $query ) ), "\n";
	close QUEUE;
	
	# initialize and update the HTML
	$html = &queue;
	$html =~ s/##SHORTNAME##/$shortname/eg;

}

# done
print $cgi->header( -type => 'text/html', -charset => 'utf-8');
print $html;
exit;


sub template {

		return <<EOF
<html>
<head>
	<title>Project CORD - search2queue</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link rel="stylesheet" href="./etc/style.css">
	<style>
		.item { margin-bottom: 1em }
	</style>
</head>
<body>
<div class="header">
	<h1>Project CORD - search2queue</h1>
</div>

<div class="col-3 col-m-3 menu">
  <ul>
		<li><a href="./">Home</a></li>
		<li><a href="./search2queue.cgi">Queue a carrel's creation</a></li>
 </ul>
</div>

<div class="col-9 col-m-9">

	<p>Use this form to queue the creation of a study carrel with the results of a Solr query.</p>
	
	<form method='GET' action='./search2queue.cgi'>
	<table>
		<tr>
			<td style='text-align:right'>Short name:</td>
			<td><input type='text' name='shortname' size='50' autofocus="autofocus" /></tdb>
		</tr>
		<tr>
			<td style='text-align:right'>Email address:</td>
			<td><input type='text' name='email' size='50' /></td>
		</tr>
		<tr>
			<td style='text-align:right'>Solr query:</td>
			<td><textarea name="query" rows='4' cols="48">##QUERY##</textarea></td>
		</tr>
			<td style='text-align:right'>Action</td>
			<td><input type='submit' name='confirm' value='Configure (Step #1 of 2)' /></td>
		<tr>
	</table>
	
	</form>

	<div class="footer">
		<p style='text-align: right'>
		Eric Lease Morgan &amp; Team Project CORD<br />
		June 2, 2020
		</p>
	</div>

</div>

</body>
</html>
EOF

}


sub confirm {

		return <<EOF
<html>
<head>
	<title>Project CORD - search2queue</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link rel="stylesheet" href="./etc/style.css">
	<style>
		.item { margin-bottom: 1em }
	</style>
</head>
<body>
<div class="header">
	<h1>Project CORD - search2queue</h1>
</div>

<div class="col-3 col-m-3 menu">
  <ul>
		<li><a href="./">Home</a></li>
		<li><a href="./search2queue.cgi">Queue a carrel's creation</a></li>
 </ul>
</div>

<div class="col-9 col-m-9">

	<p>Below is a confirmation of the work.</p>
	
	<table>
		<tr>
			<td style='text-align:right'><strong>Short name</strong>:</td>
			<td>##SHORTNAME##</tdb>
		</tr>
		<tr>
			<td style='text-align:right'><strong>Email address</strong>:</td>
			<td>##EMAIL##</td>
		</tr>
		<tr>
			<td style='text-align:right'><strong>Solr query</strong>:</td>
			<td>##QUERY##</td>
		</tr>
	</table>

	<p>If this is correct, then queue it, and your carrel will be initialized momentarily. If not, then please go back.</p>

	<form method='GET' action='./search2queue.cgi'>
	<input type='hidden' name='shortname' value='##SHORTNAME##' />
	<input type='hidden' name='email' value='##EMAIL##' />
	<input type='hidden' name='query' value='##QUERY##' />
	<table>
		</tr>
			<td style='text-align:right'>Action</td>
			<td><input type='submit' name='queue' value='Queue (Step #2 of 2)' /></td>
		<tr>
	</table>
	</form>
	
	
	<div class="footer">
		<p style='text-align: right'>
		Eric Lease Morgan &amp; Team Project CORD<br />
		June 2, 2020
		</p>
	</div>

</div>

</body>
</html>
EOF

}


sub queue {

		return <<EOF
<html>
<head>
	<title>Project CORD - search2queue</title>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<link rel="stylesheet" href="./etc/style.css">
	<style>
		.item { margin-bottom: 1em }
	</style>
</head>
<body>
<div class="header">
	<h1>Project CORD - search2queue</h1>
</div>

<div class="col-3 col-m-3 menu">
  <ul>
		<li><a href="./">Home</a></li>
		<li><a href="./search2queue.cgi">Queue a carrel's creation</a></li>
 </ul>
</div>

<div class="col-9 col-m-9">

	<p>Your carrel has been queued for creation.</p>

	<p>Our system looks for items in the queue every 60 seconds or so. When it sees that there is more work to do, it will initialize the carrel and submit it for creation. Once submitted, it takes another 120 seconds or so for a newly created computer to spin up. When that is done you ought to be able to use your Web browser to monitor and then use the carrel.</p>
	<p>Please wait between 60 and 180 seconds or so, and then see: <a href='http://cord.distantreader.org/carrels/##SHORTNAME##/'>http://cord.distantreader.org/carrels/##SHORTNAME##/</a>. You can go there right now, but you will probably get an error message.</p>

	<p>Thank you for your submission!</p>
	
	<div class="footer">
		<p style='text-align: right'>
		Eric Lease Morgan &amp; Team Project CORD<br />
		June 2, 2020
		</p>
	</div>

</div>

</body>
</html>
EOF

}

