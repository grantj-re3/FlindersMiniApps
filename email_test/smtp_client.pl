#!/usr/bin/perl
# smtp_client.pl
#
# Copyright (c) 2017, Flinders University, South Australia. All rights reserved.
# Contributors: Library, Corporate Services, Flinders University.
# See the accompanying LICENSE file (or http://opensource.org/licenses/BSD-3-Clause).
#
# Ideas from:
# - http://www.thegeekstuff.com/2010/07/perl-tcp-udp-socket-programming/
#
# Refs:
# - http://perldoc.perl.org/IO/Socket/INET.html
#
##############################################################################
use strict;
use IO::Socket::INET;

my $rhost = "127.0.0.1";	# IP address
my $rport = "25";

my $smtp_helo_domain = "localhost.localdomain";
my $smtp_mail_from = "FROM_USER";
my $smtp_rcpt_to = "TO_USER\@example.com";

##############################################################################
# Email content: Must terminate with "\r\n.\r\n"
my $content = <<"	EO_MSG";	# Terminating-string has leading tab char
		To: $smtp_rcpt_to
		Subject: Test message
		
		This is a test. Please do not reply.
		.
	EO_MSG
my $eol = "\r\n";		# End of line chars
$content =~ s/\n/$eol/g;	# End lines with "\r\n"
$content =~ s/^\t*//gm;		# Strip leading tabs from lines

# Email protocol commands + content.
# All command + content strings MUST have their own end-of-line chars.
my @commands = (
  "HELO $smtp_helo_domain$eol",
  "MAIL FROM:<$smtp_mail_from>$eol",
  "RCPT TO:<$smtp_rcpt_to>$eol",
  "DATA$eol",
  $content,
  "QUIT$eol",
);

##############################################################################
# flush after every write
$| = 1;

my ($socket, $resp);

$socket = new IO::Socket::INET (
  PeerHost => $rhost,
  PeerPort => $rport,
  Proto => 'tcp',
) or die "ERROR in Socket Creation : $!\n";

print "Successfully connected (to host $rhost port $rport).\n";
$resp = <$socket>;		# $socket->recv($resp,1024);
print "<---Server| $resp\n";

foreach my $cmd (@commands) {
  print "Client--->| $cmd";
  print $socket "$cmd";		# $socket->send($cmd);

  $resp = <$socket>;		# $socket->recv($resp,1024);
  print "<---Server| $resp\n";
}
$socket->close();

