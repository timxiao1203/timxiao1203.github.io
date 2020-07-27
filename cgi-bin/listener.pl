#!/usr/bin/perl

#print "Content-type: text/html\n\n"; 


open(LOG, '>>', '/home/users/web/b1391/ipg.timyxiao71752/cgi-bin/listener.log');

use CGI qw(:standard);
my $cgi = CGI->new();
my $query = 'cmd=_notify-validate&';
$query .= join('&', map { $_.'='.$cgi->param($_) } $cgi->param());



$curTime = localtime ($^T);

#printf (LOG "<%s>: request %s\n", $curTime, $REQ );
#printf (LOG "<%s>: pre-arg %s\n", $curTime, $query );


# add 'cmd'
#$query .= '&cmd=_notify-validate';


# post back to PayPal system to validate
# tmp disable for test
#
use LWP::UserAgent;


$PP_Server='ipnpb.paypal.com';

#$PP_Server='ipnpb.sandbox.paypal.com';


printf (LOG "<%s>: server %s\n", $curTime, $PP_Server);

$ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 1,SSL_version => 'SSLv23:!TLSv12' });
$req = HTTP::Request->new('POST', 'https://'.$PP_Server.'/cgi-bin/webscr');

$req->content_type('application/x-www-form-urlencoded');
$req->header(Host => $PP_Server);
$req->content($query);
$res = $ua->request($req);


printf (LOG "<%s>: arg %s\n", $curTime, $query );

@pairs = split(/&/, $query);
$count = 0;
foreach $pair (@pairs) 
{
	($name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	$variable{$name} = $value;
	$count++;
}

#log all information
#
#printf (LOG "<%s>: ", $curTime);
#foreach $key (keys(%variable))
#{
#	printf (LOG "%s = %s", $key, $variable{$key});
#}
#printf (LOG "\n");



if ($res->is_error) 
{
	print "Content-type: text/html\n\n"; 
 	printf (LOG "<%s>: HTTP error\n", $curTime);
}
elsif ($res->content eq 'VERIFIED')
{
	# check that txn_id has not been previously processed
	# will be checked in database
	#
	
	# check that receiver_email is an email address in your PayPal account
	# will checked in database
	#
 
	# process payment
	#
	# check the payment_status=Completed
 	# log in database anyway
	#
	if ($payment_status ne 'Completed')
	{
		$str = 'http://142.112.80.48:80/cgi-bin/paypal.pl'.'?'.$query;
		$uaNew = LWP::UserAgent->new();
		$reqNew = HTTP::Request->new('GET', $str);
		$resNew = $uaNew->request($reqNew);
		print "Content-type: text/html\n\n";
		#printf (LOG "<%s>: %s\n", $curTime, $str);
		printf (LOG "<%s>: payment status %s\n", $curTime, $payment_status);
	}
}
elsif ($res->content eq 'INVALID') 
{
	print "Content-type: text/html\n\n"; 
	printf (LOG "<%s>: ATT: receiving INVALID content\n", $curTime);	
}
else 
{
	print "Content-type: text/html\n\n"; 
	printf (LOG "<%s>: ATT: wrong protocol.\n", $curTime);
}


close (LOG);
exit;


