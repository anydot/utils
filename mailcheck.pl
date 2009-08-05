#!/usr/bin/perl
use strict;
use warnings;

### read configfile
my $cfg;

open my $cfgf, "<", $ENV{"HOME"}."/.mailcheck.conf" or die "Can't open configfile";
$cfg = do {local $/; <$cfgf>};
close $cfgf;

my $config = eval "{$cfg}";
die $@
	if $@;
###

my $mail = $config->{mail};
my $flaggedall = $config->{flaggedall};

my $out;

foreach my $mbox (keys %{$config->{mbox}}) {
	my ($flagged, $unread);

	next unless -d "$mail/$mbox";
	next unless -d "$mail/$mbox/cur";
	next unless -d "$mail/$mbox/new";

	$flagged = grep {-f and /:2,\w*F\w*$/} glob("$mail/$mbox/cur/*"); ## count only files which are flagged
	$unread  = grep {-f                  } glob("$mail/$mbox/new/*"); ## count new mails

	next
		unless $unread or $flagged;

	$out .= $config->{mbox}->{$mbox};
	$out .= "[$flagged]" if $flagged  ;
	$out .= "($unread)"  if $unread   ;
	$out .= " "                       ;
}

if ($flaggedall) {
	opendir my $dir, $mail or
		die "Can't open directory $mail: $!";
	
	while (my $mbox = readdir $dir) {
		next
			unless -d "$mail/$mbox";
		next
			if $config->{mbox}->{$mbox};

		my $flagged = grep {-f and /:2,\w*F\w*$/} glob("$mail/$mbox/cur/*"); ## count only files which are flagged

		next
			unless $flagged;

		$out .= "$mbox\[$flagged\] ";
	}
}

if ($out) {
	chop $out;
	print $out;
}
