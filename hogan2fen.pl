#!/usr/bin/perl
use warnings;
use strict;

use Data::Dumper;

=ukazka
 1.		E2 - E4
  		E7 - E5
 2.		G1 - F3
  		G8 - F6
 3.		F3 - G5
  		F8 - C5
 4.		F1 - C4
  		D7 - D5
 5.		E4 x D5
  		B8 - D7
 6.		D5 - D6
=cut

my %board = qw/
a8 r b8 n c8 b d8 q e8 k f8 b g8 n h8 r
a7 p b7 p c7 p d7 p e7 p f7 p g7 p h7 p
a2 P b2 P c2 P d2 P e2 P f2 P g2 P h2 P
a1 R b1 N c1 B d1 Q e1 K f1 B g1 N h1 R
/;


my $move = 2;
my $output;

# castles, c -  castle, w/b white/black, k/q king/queen
my ($cwk, $cwq, $cbk, $cbq) = qw/1 1 1 1/;

sub updatecastle {
	my $move = shift;

	if ($move eq 'a8') {
		$cbq = 0;
	}
	elsif ($move eq 'h8') {
		$cbk = 0;
	}
	elsif ($move eq 'e8') {
		$cbq = $cbk = 0;
	}
	elsif ($move eq 'a1') {
		$cwq = 0;
	}
	elsif ($move eq 'h1') {
		$cwk = 0;
	}
	elsif ($move eq 'e1') {
		$cwq = $cwk = 0;
	}
}


while (my $line = <STDIN>) {
	last if $line =~ /^\./;

	next
		if $line =~ /garde|šach|rošáda/;
	die "Bad format of input"
		unless $line =~ /^\s*(?:\d+\.)?\s+(\w\d) [-x] (\w\d)\s*$/;
	
	my ($from, $to) = (lc $1, lc $2);
	$move++;

	# castles
	if ($from eq 'e8' and $board{e8} eq 'k') {
		if ($to eq 'h8' and $board{h8} eq 'r') {
			delete $board{e8};
			delete $board{h8};
			$board{g8} = 'k';
			$board{f8} = 'r';
			$cbk = $cbq = 0;
			next;
		}
		elsif ($to eq 'a8' and $board{a8} eq 'r') {
			delete $board{e8};
			delete $board{a8};
			$board{c8} = 'k';
			$board{d8} = 'r';
			$cbk = $cbq = 0;
			next;
		}
	}
	elsif ($from eq 'e1' and $board{e1} eq 'K') {
		if ($to eq 'h1' and $board{h1} eq 'R') {
			delete $board{e1};
			delete $board{h1};
			$board{g1} = "K";
			$board{f1} = "R";
			$cwk = $cwq = 0;
			next;
		}
		elsif ($to eq 'a1' and $board{a1} eq "R") {
			delete $board{e1};
			delete $board{a1};
			$board{c1} = "K";
			$board{d1} = "R";
			$cwk = $cwq = 0;
			next
		}
	}



	$board{$to} = $board{$from};

	delete $board{$from};

	# castles
	updatecastle($from);
	updatecastle($to);

}

foreach my $row (qw/8 7 6 5 4 3 2 1/) {
	my $space = 0;
	foreach my $column (qw/a b c d e f g h/) {
		my $key = "$column$row";
		if (defined $board{$key}) {
			$output .= $space
				if ($space > 0);
			$space = 0;
			$output .= $board{$key};
		}
		else {
			$space++;
		}
	}
	$output .= "/";
}

$output .= " ";
if ($move % 2) {
	$output .= "b";
}
else {
	$output .= "w";
}

$output .= " ";

$output .= "-"
	unless $cwk or $cwq or $cbk or $cbq;
$output .= "K"
	if $cwk;
$output .= "Q"
	if $cwq;
$output .= "k"
	if $cbk;
$output .= "q"
	if $cbq;

$output .= sprintf " - %i %i\n", $move % 2, $move / 2;

if (@ARGV) {
	open my $crafty, "|-", "crafty"
		or die ("Can't exec crafty");

	print $crafty "setboard $output\nanalyze\n";
}
else {
	print "$output\n";
}








