#!/usr/bin/perl
use strict;
use warnings;

### configuration file format
# {
# 	default => {
# 		'options' => 'which are global',
# 		'another' => 'option',
# 	},
# 	'imap:server.name' => {
# 		default => {
# 			'options' => 'specific to this server',
# 			'Pass' => 'password', ## etc, see man isync
# 		},
# 		remoteBox => localBox,
# 		......
# 		,
# 	},
# 	'imaps:securedserver' => {
# 		......
# 	}

my $config;

{
	local $/;
	$config = <>;
}

my $c = eval($config) or die ($@);

if (defined $c->{default}) {
	my @default = %{$c->{default}};

	while (@default) {
		my ($key, $value) = splice @default, 0, 2;

		print "$key $value\n";
	}
	print "\n";
	delete $c->{default};
}

foreach my $host (keys %$c) {
	my $server = $c->{$host};
	my $serverConf = '';

	if (defined $server->{default}) {
		my @default = %{$server->{default}};

		while (@default) {
			my ($key, $value) = splice @default, 0, 2;

			$serverConf .= "$key $value\n";
		}
		
		delete $server->{default};
	}

	foreach my $remoteBox (keys %$server) {
		my $localBox = $server->{$remoteBox};

		print "Mailbox $localBox\nBox $remoteBox\nHost $host\n$serverConf\n";
	}
}

