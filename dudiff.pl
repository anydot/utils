#!/usr/bin/perl

use warnings;
use strict;

my (%d1, %d2);

die "$0 firstfile secondfile"
	unless @ARGV == 2;

open my $f1, "<", $ARGV[0]
	or die "Can't open first file";
open my $f2, "<", $ARGV[1]
	or die "Can't open second file";

while (<$f1>) {
	/^(\d+)\s+(.*)\s*$/;
	$d1{$2} = $1;
}

while (<$f2>) {
	/^(\d+)\s+(.*)\s*$/;
	$d2{$2} = $1;
}

close $f1; close $f2;

# do diff
foreach (keys %d1) {
	$d2{$_} -= $d1{$_};
}

print "diff end\n";

#order descending by abs of difference of size, ignoring dirs with zero diff.
my @order = sort {abs($d2{$b}) <=> abs($d2{$a})} grep {$d2{$_}} keys %d2;

foreach (@order) {
	printf "%i\t%s\n", $d2{$_}, $_;
}
