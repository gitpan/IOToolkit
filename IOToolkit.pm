package IOToolkit;

use 5.008;
use strict;
use warnings;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);
use base qw(Exporter);

require Exporter;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT=qw(&logme &gettimestamp);
our $VERSION = '1.10';

sub logme{

   my $severity = $_[0];
   my $message  = $_[1];   
   $message     = "" unless defined($message);
      
   if ($severity eq "open") {open LOGFILE,">>$message" or die "*** Fatal Error: Logfile $message cannot be opened.";}
   elsif ($severity eq "close") {close LOGFILE or die "*** Fatal Error: Logfile cannot be closed.";}
   
   elsif ($main::getopt_loglevel =~ m/$severity/) {
      my $timestamp = &gettimestamp();
      my $line = "$timestamp [$main::programname] <$severity> $message\n";
      if (not $main::getopt_loglevel =~ m/-/) {print $line;}
      print LOGFILE $line;
   }
   
   if (($severity eq "E") || ($severity eq "F")) {$main::error_occured++;}
   
   if ($severity eq "F") {  
   close LOGFILE;
   die "\n*** Fatal Error: $_[1]\n\n";
   }
   return 1;
}

sub gettimestamp {
   my $format = $_[0];
   my ($sec,$min,$hour,$mday,$mon,$year) = localtime;
   $year=$year+1900;
   $mon=$mon+1;
   if ($mon<10) {$mon = "0".$mon;}
   if ($mday<10) {$mday = "0".$mday;}
   if ($hour<10) {$hour = "0".$hour;}
   if ($min<10) {$min = "0".$min;}
   if ($sec<10) {$sec = "0".$sec;}
   if (defined($format)) {
      if ($format eq "filename") {
         return "$year"."$mon"."$mday"."$hour"."$min"."$sec";
      }
   } else {
      return "$year-$mon-$mday $hour:$min:$sec";
   }
}

sub trim {
    my @out = @_;
    for (@out) {
        s/^\s+//;          # trim left
        s/\s+$//;          # trim right
    }
    return @out == 1 
              ? $out[0]   # only one to return
              : @out;     # or many
}

sub moduleinfo {
   print "Directories searched:\n\t",
   join ("\n\t" => @INC),
   "\nModules loaded:\n\t",
   join ("\n\t" => sort values %INC),
   "\n";
   return 1;
}

1;
    
__END__

=head1 NAME

IOToolkit - Perl extension to create logfiles

=head1 SYNOPSIS

Sample Script:

    use strict;
    use warnings;
    use Getopt::Long;		      # processing command-line parameters
    use IOToolkit;

    package main; 
    use vars qw($getopt_loglevel $program $programname);

    $program="logging";
    $programname = $program.".pl";
    my $logfilename = $program.".log";
    my $version = "1.00";
    my $description = "Logging-Sample";

    GetOptions("loglevel=s" => \$getopt_loglevel);

    if (not(defined($getopt_loglevel))) {
       print "$description ($programname)\n";
       print "Usage: \n$programname\n --loglevel=EMCDQ\n\n";
       die "You did not provide any parameters. The program ended here.\n\n";
    } 

    logme("open",$logfilename);
    logme("D","$programname V$version started --------------------------------------------------");
    logme("M","This is a MESSAGE");
    logme("D","This is a DEBUG-MESSAGE");
    logme("E","This is an ERROR-MESSAGE");
    logme("Q","This is a SQL-QUERY-MESSAGE");
    logme("C","This is a CONFIGURATION-MESSAGE");
    logme("M","FATAL- and SYSTEM-MESSAGES (F/S) are always logged.");
    logme("M","If the loglevel parameter contains - no messages are displayed.");
    #logme("F","This is a FATAL-MESSAGE");
    logme("D","$programname V$version ended   --------------------------------------------------");
    logme("close");

=head1 ABSTRACT

=head1 DESCRIPTION

This module was written to provide an easy way to log messages. It
checks for an option --loglevel=EMCDEQ- where each character stands 
for a certain level. e.g.

   E=Error
   S=System
   M=Message
   D=Debug
   -=Silent

the minus ("-") has a special meaning: supresses output to the screen and
ONLY logs them to the file. Please see the sample script for more details.

=head2 EXPORT

logme and gettimestamp are exported.

=head1 SEE ALSO

http://www.linke.de

=head1 AUTHOR

Markus Linke, markus.linke@linke.de

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Markus Linke

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
