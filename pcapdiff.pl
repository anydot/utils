#!/usr/bin/perl
use strict;
use warnings;

use Net::Pcap qw/:functions/;
use Digest::SHA qw/sha256/;

die "$0 pcapin1 pcapin2\nWill dump packet in pcap format on stdout containing packets found in pcapin1 which are not found in pcapin2 (= pcapin1 - pcapin2)\n"
	unless @ARGV == 2;

my ($err1, $err2);

my $pcapin1 = pcap_open_offline($ARGV[0], \$err1)
	or die "Can't open $ARGV[0]: $err1";

my $pcapin2 = pcap_open_offline($ARGV[1], \$err2)
	or die "Can't open $ARGV[1]: $err2";

die "Both sources must have same datalink"
	unless pcap_datalink($pcapin1) == pcap_datalink($pcapin2);

die "Both sources must have same snaplen"
	unless pcap_snapshot($pcapin1) == pcap_snapshot($pcapin2);

my $pcapout = pcap_open_dead(pcap_datalink($pcapin1), pcap_snapshot($pcapin1));
my $dumper = pcap_dump_open($pcapout, "-");

my %seen;

my $header = {};

while (my $packet = pcap_next($pcapin2, $header)) {
	$seen{sha256($header->{len}, $packet)} = 1;
}

while (my $packet = pcap_next($pcapin1, $header)) {
	next
		if $seen{sha256($header->{len}, $packet)};

	pcap_dump($dumper, $header, $packet);
}

pcap_dump_close($dumper);
pcap_close($pcapout);
pcap_close($pcapin2);
pcap_close($pcapin1);
