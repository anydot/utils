#!/usr/bin/perl
use warnings;
use strict;

sub rename_dir {
	my $DIRNAME = shift;
	my @params  = qw{mp3gain -a -k};

	opendir(DIR, $DIRNAME) || 
		(print STDERR "cannot open $DIRNAME: $!" and return -1);

	foreach my $filename (grep !/^\.\.?$/, readdir(DIR)) {
		my $actual = "$DIRNAME/$filename";

		#if is dir call rename_dir
		if (-d $actual) {
			rename_dir($actual);
		}

		if (-f "$actual" and $actual =~ /[.](mp3|ogg)$/i) {
			push @params, "$actual";
		}
		close(DIR);
	}

	print "% mp3gain on $DIRNAME:\n";
	print STDERR "% error\n" if system @params;
}

if ($#ARGV < 0) { 
	print STDERR "usage:\n\tapplymp3gain.pl <dir> [<dir> ...]\n\n";
	exit 0;
}

foreach my $dir (@ARGV) {
	rename_dir($dir);
}
