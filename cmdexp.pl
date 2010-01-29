#!/usr/bin/perl
use strict;
use warnings;

use 5.10.0;
use File::Slurp qw/slurp/;
use Data::Dumper;

my $data = @ARGV ? slurp $ARGV[0] : slurp \*DATA;

$data =~ s/\s*#.*$//gm; # remove comments
$data =~ s/^\s*\n//gm;  # remove blank lines
$data =~ s/\{\s*\n/{/g; # remove post whitespace
$data =~ s/\n\s*\}/}/g; # remove pre whitespace

print join "\n", expand($data), '';

exit;

sub expand {
	my $data = shift;

	return ()
		unless $data;

	die "syntax error" unless
	$data =~ /
		^
		(?<PRE>[^{}]*+\n)?
		(?<PRELINE>[^{}\n]*)
		(?<TERM>
			\{
				(?<ITERM>
					(?:
						[^{}]*+
						(?&TERM)*
						[^{}]*+
					)++
				)
			\}
		)?
		(?<POSTLINE>
			(?:
				[^{}\n]*+
				(?&TERM)*
				[^{}\n]*+
			)*
		)
		\n?+
		(?<POST>
			(?:
				[^{}]*+
				(?&TERM)
				[^{}]*+
			)*+
			[^{}]*+
		)
		$
	/sx;

	my ($preline, $postline, $pre, $post, $iterm) = @+{qw/PRELINE POSTLINE PRE POST ITERM/};

	return split(/\n/, $pre // ''), ($iterm ?  map {expand($preline . $_ . $postline)} expand($iterm) : $preline), expand($post);
}

__DATA__
example
line {
	subline1
	subline2 {
		sublinepart1
		sublinepart2
	}
} continuation
dsdfsdf
