#!/usr/bin/perl
# telnet_raw_client.pl
#
# Copyright (c) 2017, Flinders University, South Australia. All rights reserved.
# Contributors: Library, Corporate Services, Flinders University.
# See the accompanying LICENSE file (or http://opensource.org/licenses/BSD-3-Clause).
#
# Ideas from:
# - http://www.thegeekstuff.com/2010/07/perl-tcp-udp-socket-programming/
# - http://www.justskins.com/forums/non-blocking-filehandles-for-10990.html
#
# Refs:
# - http://perldoc.perl.org/IO/Socket/INET.html
# - http://perldoc.perl.org/IO/Select.html
#
##############################################################################
use strict;
use IO::Socket::INET;
use IO::Select;

# FIXME: Read IP & optional port from command line
my $rhost = "127.0.0.1";	# IP address
my $rport = "25";		# Port number

my $timeout_seconds = 0.5;	# Used for non-blocking socket reads
my $is_blocking = 0;		# 0=Non-blocking read of socket; 1=Blocking

my $eol = "\r\n";		# End of line chars

##############################################################################
sub read_stdin_write_socket {
  my ($socket) = @_;
  my ($line, $cmd);

  print "Enter text% ";
  $line = <STDIN>;
  chomp($line);
  $cmd = $line . $eol;

  print "Client--->| $cmd";
  print $socket "$cmd";		# $socket->send($cmd);
}

##############################################################################
sub read_socket_and_show {
  my ($socket, $is_blocking, $sel) = @_;
  my ($resp, $ready);

  if($is_blocking) {
    $resp = <$socket>;		# $socket->recv($resp,1024);
    print "<---Server| $resp\n";

  } else {
    $ready = $sel->can_read($timeout_seconds);
    if($ready) {
      $resp = <$socket>;	# $socket->recv($resp,1024);
      print "<---Server| $resp\n";
    } else {
      print "<---Server| [No response from remote host.]\n\n"
    }
  }
}

##############################################################################
# flush after every write
$| = 1;

my $socket = new IO::Socket::INET (
  PeerHost => $rhost,
  PeerPort => $rport,
  Proto => 'tcp',
  Blocking => $is_blocking,
) or die "ERROR in Socket Creation : $!\n";

print "Successfully connected (to host $rhost port $rport).\n";
print "Press Ctrl-C to quit.\n\n";

my $sel = IO::Select->new();
$sel->add($socket);
read_socket_and_show($socket, $is_blocking, $sel);

while (1) {
  read_stdin_write_socket($socket);
  read_socket_and_show($socket, $is_blocking, $sel);
}
$socket->close();

