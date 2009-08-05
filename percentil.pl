#!/usr/bin/perl
use strict;
use warnings;

my @data;
my @popisek;
my $sum = 0;
my $current = 0.0;

while (<>) {
	next unless /^\s*(\d+)\s+(.*)$/;

	$sum += $1;
	push @popisek, $2;
	push @data, $1;
}

exit unless $sum;

for (my $i = 0; $i < scalar @popisek; $i++) {
	my $p = $popisek[$i];
	my $d = $data   [$i];

	printf "%3.2f (%3.2f)\t%s\n", ($current/$sum*100), ($d/$sum*100), $p;

	$current += $d;
}
 


