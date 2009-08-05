#!/usr/bin/perl

=head1 CONFIGURATION
 
Configuration is saved in ~/.gendomainpw in simple format key = value:

	password = MyP4$w0rd
	retlen = 16

This will set shared password, which is used with domain to generate password of length
maximaly retlen. "password" is a must, "retlen" have default of 16.
Comments are lines begining with "#".

=head1 USING

Run this program with domains as arguments, password will be generated for every domain.
Domain names are also lowercased so you can enter domains with any case or their combination.

=head1 AUTHOR

Premysl "Anydot" Hruby, dfenze@gmail.com, 2008

=head1 LICENSE

beerware

=cut

use warnings;
use strict;

use Digest::SHA qw/sha512_hex/;

my %config = (retlen => 16);

sub readconfig {
	my $home = $ENV{HOME};

	open my $fh, "<", "$home/.gendomainpw"
		or die ("Can't open config file");
	
	while (<$fh>) {
		chomp;
		next if /\s*#/;
		/^(\S+)\s*=\s*(\S+)\s*/
			or die ("Error in configuration file");

		$config{$1} = $2;
	}

	die ("password is not defined")
		unless $config{password};
}

readconfig;

my ($password, $retlen) = ($config{password}, $config{retlen});

while (my $domain = shift) {
	$domain = lc($domain);
	my $password = substr(sha512_hex("$password:$domain"), 0, $retlen);
	
	print "$domain: $password\n";
}
