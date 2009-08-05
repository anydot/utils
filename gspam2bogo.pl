#!/usr/bin/perl
use strict;
use warnings;
use Mail::Webmail::Gmail;

my $cfgfile = ($ENV{'HOME'} || ".") . "/.gspam2bogo.conf";
my %cfg;
my @msgids;

open CFG, '<', $cfgfile or die "Can't open config file $cfgfile";
while (<CFG>) {
	chomp;
	next if /^\s*#/;
	/^\s*(\S+)\s*(.*)$/;
	$cfg{$1} = $2;
}
close CFG;

if (!defined $cfg{username} || !defined $cfg{password}) {
	die "You must supply username and password";
}

my ($gmail) = Mail::Webmail::Gmail->new(
		username => $cfg{username}, password => $cfg{password});

my $messages = $gmail->get_messages(label => $Mail::Webmail::Gmail::FOLDERS{ 'SPAM' });

foreach my $msg (@{$messages}) {
	my $message = $gmail->get_mime_email(msg => $msg);

	open(BOGOFILTER, "|bogofilter");
	print BOGOFILTER $message;
	close BOGOFILTER;

	if (!$?) {
		print ".";
	} else {
		print "L";
		open(BOGOFILTER, "|bogofilter -s");
		print BOGOFILTER $message;
	}

	push @msgids, $msg->{id};
}
print "\n";

if (defined($cfg{delete})) {
	print "Deleting " . @msgids . " messages\n";
	$gmail->delete_message( msgid => \@msgids, search => 'spam', del_message => 1 );
	print "Delete done\n";
}

