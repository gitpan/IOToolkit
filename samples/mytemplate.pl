#!/hfx/opt/perl-5.8/bin/perl

use strict;
use warnings;
use Getopt::Long;    # processing command-line parameters
use IOToolkit;

package main;
use vars qw($getopt_loglevel $program $programname);

my $program = $0;    		# Script Name with path
$program =~ m/\/(.+)/i;    	# Only the scriptname
$programname = $1;
$program =~ m/(.+)\.pl/i;    	# Without the extension
$program = $1;

my $logfilename = $program . ".log";
my $VERSION = sprintf "%d.%02d", '$Revision:   1.2  $' =~ /(\d+)/g;
my $description = "Script";

GetOptions("loglevel=s" => \$getopt_loglevel);

if (!defined($getopt_loglevel))
{
    print "$description ($programname)\n";
    print "Usage: \n$programname\n --loglevel=EMCDQ\n\n";
#   die "You did not provide any parameters. The program ended here.\n\n";
    $getopt_loglevel="all";
}

logme("open", $logfilename);
logme("M","$programname V$VERSION started --------------------------------------------------");
logme("C", "Logfile $logfilename used.");
logme("M","$programname V$VERSION ended   --------------------------------------------------");
logme("close");

1;

__END__

# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

script.pl

=head1 SYNOPSIS

./script.pl --loglevel=all

=head1 ABSTRACT

  Abstract of the script
  
=head1 DESCRIPTION

Here comes the full description

=head2 EXPORT

None by default.

=head1 SEE ALSO

   Documentation:   none
   Mailing List:    none
   Support Website: none

=head1 AUTHOR

Markus Linke, E<lt>markus.linke@linke.deE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2004 by Markus Linke

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=head1 AMENDMENT HISTORY

 $Log:   /hfx/var/pvcs/Murex/archives/pl/mytemplate.pl-arc  $
# 
#    Rev 1.2   29 Oct 2004 14:28:32   ml7tre
# pvcs related changes

=cut