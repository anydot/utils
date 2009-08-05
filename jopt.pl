#!/usr/bin/perl
use warnings;
use strict;

use File::Find;
use File::ExtAttr qw/getfattr setfattr/;

my $jpegre = qr/\.jpe?g$/i;

my $gain = 0;

sub cb {
	my $file = $_;

	return
		unless -f $file;
	return
		unless $file =~ /$jpegre/;

	
	print "$File::Find::name ";

	my $mtime = (stat($file))[9];
	my $eatime = getfattr($file, "jopt");

	if (defined $eatime && $mtime == $eatime) {
		print "-\n";
		return;
	}

	if (-e "$file.jopt.$$.o" or -e "$file.jopt.$$.p") {
		warn "Oops, tempfiles already exists ($File::Find::name)";
		return;
	}

	if (system("jpegtran -copy no -optimize -outfile $file.jopt.$$.o $file") >> 8) {
		warn "Error while running jpegtran";
		return;
	}

	print ".";

	if (system("jpegtran -copy no -optimize -progressive -outfile $file.jopt.$$.p $file") >> 8) {
		warn "Error while running jpegtran";
		unlink "$file.jopt.$$.o";
		return;
	}

	print ".";

	my $nsize = (stat($file))[7];
	my $osize = (stat("$file.jopt.$$.o"))[7];
	my $psize = (stat("$file.jopt.$$.p"))[7];

	if ($nsize <= $osize and $nsize <= $psize) {
		print "n\n";
		unlink "$file.jopt.$$.p", "$file.jopt.$$.o";
	}
	elsif ($osize <= $psize) {
		print "o\n";
		
		rename "$file.jopt.$$.o", $file
			or die $@;
		unlink "$file.jopt.$$.p";

		$gain += $nsize - $osize;
	}
	else {
		print "p\n";

		rename "$file.jopt.$$.p", $file
			or die $@;
		unlink "$file.jopt.$$.o";

		$gain += $nsize - $psize;
	}
	
	$mtime = (stat($file))[9];
	setfattr($file, "jopt", $mtime);
}

if (@ARGV) {
	find(\&cb, @ARGV);
}
else {
	find(\&cb, ".");
}

print "\n\nGain after optimization is $gain Bytes\n"; 

