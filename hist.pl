#!/usr/bin/perl

use strict;
use warnings;

my ($start, $stop, $precission) = @ARGV;
my @bins;

while (my $value = <STDIN>) {
	my $bin;

	chomp($value);
	$value = $value*1.0;
	
	next if $value < $start or $value > $stop;

	$bin = int( ($value - $start)/$precission );

	$bins[$bin]++;
}

my $nobin = int ( ($stop-$start)/$precission );

for (my $i = 0; $i < $nobin; $i++) {
	my $value = $bins[$i];
	$value = 0.0 if (!defined($value));
	printf "%f %i\n",
		$start+($precission*$i), $value;
}
