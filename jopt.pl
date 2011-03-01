#!/usr/bin/perl
use warnings;
use strict;

use File::Find;
use Cwd qw/fast_abs_path/;
use DB_File;
use IPC::Run qw/start/;

die "Sorry, HOME env not found :-/"
	unless $ENV{HOME};

my $db_t = tie my %db, 'DB_File', $ENV{HOME}.'/.jopt.db'
	or die "Can't open db: $!";

my $jpegre = qr/\.jpe?g$/i;

my $gain = 0;
my $num = 0;

sub cb {
	my $file = $_;
	my $realfile = fast_abs_path $file;

	return
		unless -f $realfile;
	return
		unless $realfile =~ /$jpegre/;

	
	print "$file ";

	my $mtime = (stat($realfile))[9];
	my $eatime = $db{$realfile};

	if (defined $eatime && $mtime == $eatime) {
		print "-\n";
		return;
	}

	if (-e "$realfile.jopt.$$.o" or -e "$realfile.jopt.$$.p") {
		warn "Oops, tempfiles already exists ($realfile)";
		return;
	}

	my $normal = start [qw/jpegtran -copy no -optimize -outfile/, "$realfile.jopt.$$.o", $realfile];
	my $progres = start [qw/jpegtran -copy no -optimize -progressive -outfile/, "$realfile.jopt.$$.p", $realfile];

	if (!$normal->finish || !$progres->finish) {
		warn "Error while running jpegtran: $!";
		return;
	}

	my $nsize = (stat($realfile))[7];
	my $osize = (stat("$realfile.jopt.$$.o"))[7];
	my $psize = (stat("$realfile.jopt.$$.p"))[7];

	if ($nsize <= $osize and $nsize <= $psize) {
		print "n\n";
		unlink "$realfile.jopt.$$.p", "$realfile.jopt.$$.o";
	}
	elsif ($osize <= $psize) {
		print "o\n";
		
		rename "$realfile.jopt.$$.o", $realfile
			or die $!;
		unlink "$realfile.jopt.$$.p";

		$gain += $nsize - $osize;
	}
	else {
		print "p\n";

		rename "$realfile.jopt.$$.p", $realfile
			or die $!;
		unlink "$realfile.jopt.$$.o";

		$gain += $nsize - $psize;
	}
	
	$mtime = (stat($realfile))[9];
	$db{$realfile} = $mtime;

	$db_t->sync
		unless $num++ % 20;
}

@ARGV = "."
	unless @ARGV;

find({
	wanted => \&cb,
	no_chdir => 1,
	},
	@ARGV,
);

print "\n\nGain after optimization is $gain Bytes\n"; 

