#!/usr/bin/perl
#
# works ok with absolute symlink only (now)

use strict;
use warnings;

my $testval = shift or die 'You must supply test pattern';
my $t = qr/$testval/;
my $dst;

while (my $link = <STDIN>) {
	chomp($link);
	$link =~ s/\/+$//o;
	$dst = $link;
	next if $link =~ /$t/;

	while ($dst = readlink($dst)) {
		if ($dst =~ /$t/) {
			print "$link => $dst\n";
		}
	}
}
