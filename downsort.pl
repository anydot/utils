#!/usr/bin/perl
use warnings;
use strict;

use DateTime;

my $directory = glob(shift @ARGV || "~/Downloads");

opendir my $dir, $directory
	or die "Can't open directory $directory";

while (my $file = readdir $dir) {
	next
		unless -f $file;

	my $date = DateTime->from_epoch(epoch => (stat "$directory/$file")[9]);
	my $tgdir1 = sprintf "%02i-%02i", $date->year, $date->month;
	my $tgdir2 = sprintf "%02i"     , $date->day               ;

	mkdir "$directory/$tgdir1";
	mkdir "$directory/$tgdir1/$tgdir2";

	rename "$directory/$file", "$directory/$tgdir1/$tgdir2/$file";	
}

