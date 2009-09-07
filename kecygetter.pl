#!/usr/bin/perl

use warnings;
use strict;

use constant {
	FOX => 'iceweasel',
	LIMIT => 50,
};

use LWP::Simple;
use XML::XPath;
use List::Compare;

my $cachedir = $ENV{'HOME'} . "/.cache";

sub get_urls {
	my $rss = get("http://kecy.roumen.cz/roumingRSS.php")
		or die ("Can't get rss");

	my $set = XML::XPath->new(xml => $rss)->find('/rss/channel/item/title[text()!="Rouming"]/text()');

	return map {"http://kecy.roumen.cz/" . $_->string_value} $set->get_nodelist;
}

sub get_file {
	my $suffix = shift;

	open my $file, "<", "$cachedir/kecygetter.$suffix"
		or return ();
	
	return split /\s/, do {local $/; <$file>};
}

sub get_prefetch {
	return get_file("prefetch");
}

sub get_cache {
	return get_file("cache");
}

sub set_file {
	my $suffix = shift;

	open my $file, ">", "$cachedir/kecygetter.$suffix"
		or die ("Can't open $cachedir/kecygetter.$suffix for write");

	print $file join("\n", @_);
}

sub set_prefetch {
	return set_file("prefetch", @_);
}

sub set_cache {
	return set_file("cache", @_);
}

sub verify_urls {
	return grep {(head $_)[0] =~ /^image\//} @_;
}

if (! -d $cachedir) {
	mkdir $cachedir
		or die ("$cachedir doesn't exists and I can't create one");
}

my @cached = get_cache;
my @prefetched = get_prefetch;
my @fetched = get_urls;

my @fetched_new = List::Compare->new(\@fetched, \@cached)->get_unique;
push @cached, @fetched_new;
push @prefetched, @fetched_new;

if (@ARGV == 1 && $ARGV[0] eq '-update') {
}
elsif (@prefetched) {
	my @show = verify_urls splice @prefetched, 0, LIMIT;

	system FOX, map{+"-new-tab", $_} @show;
}

set_prefetch(@prefetched);
set_cache(@fetched);
