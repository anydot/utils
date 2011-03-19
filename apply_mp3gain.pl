#!/usr/bin/perl
use warnings;
use strict;

use Cwd qw/fast_abs_path/;
use DB_File;

my $progs = {
	mp3 => [qw/mp3gain -a -k -q/],
	flac => [qw/metaflac --add-replay-gain/],
	ogg => [qw/vorbisgain -a/],
};

die "Sorry, HOME env not found :-/"
	unless $ENV{HOME};

my $db_t = tie my %db, 'DB_File', $ENV{HOME}.'/.replaygain.db'
	or die "Can't open db: $!";

die "Usage: $0 <dir> [<dir> ...]"
	unless @ARGV;

my @dirs = @ARGV;

while (my $dirname = shift @dirs) {
	my $albums;

	printf "Examining %s\n",
		$dirname;

	opendir my $dir, $dirname
		or die "Can't open $dirname: $!";

	foreach my $filename (grep !/^\.\.?$/, readdir($dir)) {
		my $actual = "$dirname/$filename";

		if (-d $actual) {
			push @dirs, $actual;
		}
		elsif (-f $actual) {
			my ($extension) = $actual =~ /\.(.*?)$/;

			push @{$albums->{$extension}}, $actual
				if $progs->{$extension};

		}
	}

	foreach (keys %$albums) {
		my @files = map {fast_abs_path $_} @{$albums->{$_}};

		if (grep {! exists $db{$_}} @files) {
			system(@{$progs->{$_}}, @files) == 0
				or die "Error $!";

			@db{@files} = ();
		}
	}
}
