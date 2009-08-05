#!/usr/bin/perl
use warnings;
use strict;
use open ':std', ':utf8';

use Net::Google::AuthSub;
use Data::Dumper;
use LWP::UserAgent;
use HTTP::Request::Common;
use HTTP::Headers;
use XML::FeedPP;
use File::Slurp qw/slurp/;

use constant {
	GSERVICE => "cp",
};

sub check_response {
	my ($response, $error) = @_;

	if (!$response->is_success) {
		my $e = defined $error ? "$error: " : "";

		die "$e".$response->error;
	}
}

sub authenticate {
	my ($username, $password) = @_;

	my $auth = Net::Google::AuthSub->new(service => GSERVICE);
	my $response = $auth->login($username, $password);

	check_response($response, "Can't authenticate");

	return $auth->auth_params;
}

sub readcred {
	my ($file) = @_;

	my $content = slurp $file
		or die "Can't open $file: $!";

	my %h = eval $content;

	die "Can't parse config file: $@"
		if $@;

	my ($user, $password) = @h{qw/user password/};

	die "Config file must have defined user and password key"
		unless defined $user and defined $password;

	return ($user, $password);
}

my $cfgfile = shift @ARGV || $ENV{HOME}."/.gcontacs2ma.conf";
my ($user, $password) = readcred $cfgfile;
my $ua = LWP::UserAgent->new;

$ua->env_proxy;
$ua->default_headers(HTTP::Headers->new(
	authenticate($user, $password),
	GData_Version => '3.0'
));

my $response = $ua->request(GET "http://www.google.com/m8/feeds/contacts/default/full?max-results=999999");
check_response($response, "Can't fetch contacts");

my $content = $response->decoded_content;
my $feed = XML::FeedPP::Atom->new($content);

foreach my $item ($feed->get_item) {
	my ($title, $email) = 
		($item->title, $item->get('gd:email/@address'));

	next
		unless defined $email;

	my $aliasname = join ('', map {ucfirst} split(/\s+/, lc($title)));
	print "alias $aliasname $title $email\n";
	
}


