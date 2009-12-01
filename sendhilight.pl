use strict;
use warnings;
use Irssi;


our $VERSION = "0.1";
our %IRSSI = (
	authors     => "Premysl Hruby",
	contact     => "dfenze\@gmail.com",
	name        => "sendhilight",
	description => "Send email on hilight",
	license     => "MIT/X11",
	url         => "http://www.redrum.cz",
);

our $awayonly = 1;
our $timeout  = 120;
our $subjpref = "Hilighted in:";
our $email    = "";
our %cache;
our $timertag;

sub send_email {
	return if
		$email eq "";

	open my $smail, "|-", "/usr/sbin/sendmail", "-i -B 8BITMIME", $email
		or return;
	
	print $smail "Subject: $subjpref" . join(" ", sort keys %cache) . "\n";
	print $smail "To: $email\n";
	print $smail "Content-Type: text/plain; charset=\"UTF-8\"";
	print $smail "Content-Transfer-Encoding: 8bit\n";
	print $smail "\n";
	print $smail "These hilights occured:\n\n";

	foreach my $target (sort keys %cache) {
		print $smail "$target:\n";
		print $smail join("\n", @{$cache{$target}});
		print $smail  "\n\n";
	}
	
	close $smail;

	%cache = ();
	undef $timertag;

	Irssi::print("Sent email to $email with notifications");
	
}

sub signal_printtext {
	my ($dest, $text, $stripped) = @_;

	return unless
		$dest->{level} & (MSGLEVEL_HILIGHT|MSGLEVEL_MSGS);
	return if
		$dest->{level} & (MSGLEVEL_NOHILIGHT);

	return unless
		$timeout;


	return if
		$awayonly and $dest->{server} and !$dest->{server}->{usermode_away};
	
	push @{$cache{$dest->{target}}}, $stripped;

	$timertag = Irssi::timeout_add_once(1000*$timeout, \&send_email, undef)
		unless defined $timertag;
}

sub signal_setupchanged {
	$awayonly = Irssi::settings_get_bool('sendhilight_awayonly');
	$timeout  = Irssi::settings_get_int ('sendhilight_timeout' );
	$subjpref = Irssi::settings_get_str ('sendhilight_subjpref');
	$email    = Irssi::settings_get_str ('sendhilight_email'   );

	$subjpref .= " "
		if $subjpref ne "";
}

Irssi::signal_add('print text', \&signal_printtext);
Irssi::signal_add('setup changed', \&signal_setupchanged);

Irssi::settings_add_bool('misc', 'sendhilight_awayonly', $awayonly);
Irssi::settings_add_int ('misc', 'sendhilight_timeout' , $timeout );
Irssi::settings_add_str ('misc', 'sendhilight_subjpref', $subjpref);
Irssi::settings_add_str ('misc', 'sendhilight_email'   , $email   );

signal_setupchanged();
