package IOToolkit;

use 5.008;
use strict;
use warnings;

use vars qw(@ISA @EXPORT @EXPORT_OK %EXPORT_TAGS $VERSION);
use base qw(Exporter);
use Crypt::RC6;
use English;
use POSIX;

require Exporter;

our @ISA = qw(Exporter);
our %EXPORT_TAGS = (
    'all' => [
        qw(

          )
    ]);

our @EXPORT_OK = (@{$EXPORT_TAGS{'all'}});

our @EXPORT  = qw(&logme &gettimestamp);
$VERSION     = '1.28.'.(qw$LastChangedRevision: 28 $)[-1];

#$LastChangedDate: 2004-10-30 18:10:49 +0100 (Sat, 30 Oct 2004) $
#$LastChangedRevision: 28 $
#$Id: IOToolkit.pm 28 2004-10-30 17:10:49Z root $


sub logme
{

    my $severity = $_[0];
    my $message  = $_[1];

    if ($severity eq "open")
    {

        if (!defined($message))
        {    # If no filename is provided, use defaults
            my $program = $0;    # Script Name with path
            $program =~ m/\/(.+)\.pl/i;    # Without leading path and extension
            my $logfilename = $1 . ".log";
            $message = $logfilename;
        }

        open LOGFILE, ">>$message"
          or die "*** Fatal Error: Logfile $message cannot be opened.";
    }
    elsif ($severity eq "close")
    {
        close LOGFILE or die "*** Fatal Error: Logfile cannot be closed.";
    }

    elsif (   ($main::getopt_loglevel =~ m/$severity/)
           || ($main::getopt_loglevel eq "all"))
    {
        my $timestamp = &gettimestamp();
        my $line = "$timestamp [$main::programname] <$severity> $message\n";
        if (not $main::getopt_loglevel =~ m/-/) { print $line; }
        print LOGFILE $line;
    }

    if (($severity eq "E") || ($severity eq "F"))
    {
        $main::error_occured++;
    }

    if ($severity eq "F")
    {
        close LOGFILE;
        die "\n*** Fatal Error: $_[1]\n\n";
    }
    return 1;
}

sub gettimestamp
{
    my $format = $_[0];

    if (! defined($format)) {
       return strftime("%Y-%m-%d %H:%M:%S",localtime);
    } elsif ($format eq "filename") {
       return strftime("%Y%m%d%H%M%S",localtime);
    } else {
       return strftime($format,localtime);
    }
}

sub trim
{
    my @out = @_;
    for (@out)
    {
        s/^\s+//;    # trim left
        s/\s+$//;    # trim right
    }
    return @out == 1
      ? $out[0]      # only one to return
      : @out;        # or many
}

sub moduleinfo
{
    print "Directories searched:\n\t", join("\n\t" => @INC),
      "\nModules loaded:\n\t", join("\n\t" => sort values %INC), "\n";
    return 1;
}

sub hash2sqlinsert
{
    my $table  = shift;
    my %hash   = @_;
    my @fields = sort keys %hash;
    my @values;

    foreach $a (sort keys %hash)
    {
        push @values, $hash{$a};
    }

    return "insert into $table ("
      . join(",", @fields)
      . ") values (\'"
      . join("\',\'", @values) . "\')";
}

sub sql2data
{
    my $localdbh = $_[0];
    my $sql      = $_[1];

    my $sth = $localdbh->prepare($sql);
    my $rc  = $sth->execute;

    my $num_of_fields = $sth->{NUM_OF_FIELDS}
      or logme("E", "Cannot get number of columns. SQL Syntax error?");
    my @field_names = @{$sth->{NAME}} or logme("E", "Cannot get column names");

    my $ary_ref = $sth->fetchall_arrayref() or logme("E", "Cannot fetch data");
    my $total_rows = @$ary_ref;

    my @resultlist;

    if ($@)
    {
        logme("F", "Database Error: Unable to get data $localdbh->errstr");
    }
    else
    {
        foreach my $row (@$ary_ref)
        {
            my $hashrow = {};
            my $i       = 0;
            while ($i < $num_of_fields)
            {
                if (defined(@$row[$i]))
                {
                    $hashrow->{$field_names[$i]} = @$row[$i];
                }
                else
                {
                }
                $i++;
            }
            push @resultlist, $hashrow;
        }
    }

    return @resultlist;
}

sub dosql
{
    my $locdbh = $_[0];
    my $locsql = $_[1];
    my $locsth = $locdbh->prepare_cached($locsql);
    my $ret    = $locsth->execute;
    if (not $ret eq 1)
    {
        logme("E", "Database error: " . $locdbh->errstr);
    }
    return $ret;
}

sub encrypt
{
    my $suppliedseed = shift or die "Usage: <seed> <password>\n";
    my $pwd          = shift or die "Usage: <seed> <password>\n";
    my $seed     = sprintf("%-8.8s", $suppliedseed);
    my $password = sprintf("%-16s",  $pwd);
    my $key      = "";
    map { $key .= sprintf("%02lx", ord($_)); } split("", $seed);
    my $cipher             = new Crypt::RC6 $key;
    my $ciphertext         = $cipher->encrypt($password);
    my $encrypted_password = "";
    map { $encrypted_password .= sprintf("%02lx", ord($_)) }
      split("", $ciphertext);
    return $encrypted_password;
}

sub decrypt
{
    my $seed  = shift;
    my $crypt = shift;
    $seed = sprintf("%-8.8s", $seed);
    my $key = "";
    map { $key .= sprintf("%02lx", ord($_)); } split("", $seed);
    my $cipher = new Crypt::RC6 $key;
    my $ep     = "";

    while ($crypt =~ m/../g) { $ep .= chr(hex($MATCH)); }
    my $pwd = $cipher->decrypt($ep);
    $pwd =~ s/\s//g;
    return $pwd;
}

1;

__END__

=head1 NAME

IOToolkit

=head1 ABSTRACT

IOToolkit - Perl extension to create logfiles

=head1 PREREQUISITS

This module needs Crypt::RC6 for its encryption/decryption routine.

=head1 SYNOPSIS

Sample Script:

    use strict;
    use warnings;
    use Getopt::Long;		      # processing command-line parameters
    use IOToolkit;

    package main; 
    use vars qw($getopt_loglevel $program $programname);

    my $program = $0;			# Script Name with path
    $program =~ m/\/(.+)/i; 		# Only the scriptname
    $programname = $1; 	
    $program =~ m/(.+)\.pl/i; 		# Without the extension
    $program = $1; 

    my $logfilename = $program.".log";
    my $VERSION = "1.00";
    my $description = "Description goes here";

    GetOptions("loglevel=s" => \$getopt_loglevel);

    if (not(defined($getopt_loglevel))) {
       print "$description ($programname)\n";
       print "Usage: \n$programname\n --loglevel=EMCDQ\n\n";
       die "You did not provide any parameters. The program ended here.\n\n";
    } 

    #logme("open");			# uses a default filename scriptname.log in the same dir
    logme("open",$logfilename);
    logme("D","$programname V$VERSION started --------------------------------------------------");
    logme("M","This is a MESSAGE");
    logme("D","This is a DEBUG-MESSAGE");
    logme("E","This is an ERROR-MESSAGE");
    logme("Q","This is a SQL-QUERY-MESSAGE");
    logme("C","This is a CONFIGURATION-MESSAGE");
    logme("M","FATAL- and SYSTEM-MESSAGES (F/S) are always logged.");
    logme("M","If the loglevel parameter contains - no messages are displayed.");
    #logme("F","This is a FATAL-MESSAGE which lets the program die");
    logme("D","$programname V$VERSION ended   --------------------------------------------------");
    logme("close");

This displays and creates a logfile like this:

    2004-09-09 10:23:57 [logging.pl] <D> logging.pl V1.00 started --------------------------------------------------
    2004-09-09 10:23:57 [logging.pl] <M> This is a MESSAGE
    2004-09-09 10:23:57 [logging.pl] <D> This is a DEBUG-MESSAGE
    2004-09-09 10:23:57 [logging.pl] <E> This is an ERROR-MESSAGE
    2004-09-09 10:23:57 [logging.pl] <Q> This is a SQL-QUERY-MESSAGE
    2004-09-09 10:23:57 [logging.pl] <C> This is a CONFIGURATION-MESSAGE
    2004-09-09 10:23:57 [logging.pl] <M> FATAL- and SYSTEM-MESSAGES (F/S) are always logged.
    2004-09-09 10:23:57 [logging.pl] <M> If the loglevel parameter contains - no messages are displayed.
    2004-09-09 10:23:57 [logging.pl] <D> logging.pl V1.00 ended   --------------------------------------------------

=head1 DESCRIPTION

Provides a human-readable logfile and is ment to replace "print" and "die" in your programs.

This module was written to provide an easy way to log messages. It
checks for an option --loglevel=EMCDQ- where each character stands 
for a certain level. e.g.

   E   = Error
   S   = System
   M   = Message
   D   = Debug
   -   = Silent
   all = All messages

You can use all characters you would like to use. These are just examples.

the minus ("-") has a special meaning: supresses output to the screen and
ONLY logs them to the file. Please see the sample script for more details.

The function gettimestamp returns the current time in the format used for the logfile. 
If you specifiy the format &gettimestamp("filename") it returns something like
this: 20041009131500

=head2 IOToolkit::moduleinfo 

prints a list of loaded modules.

=head2 IOToolkit::trim 

trims a variable.

=head2 IOToolkit::hash2sql 

creates SQL code to insert a hash into a table.

Example:

   use IOToolkit;

   my %hash=(
      firstname=>"Markus",
      lastname=>"Linke",
   );

   print IOToolkit::hash2sqlinsert("tablename",%hash)."\n";
   
Result:

   insert into tablename (firstname,lastname) values ("Markus","Linke") 

IOToolkit::sql2data executes SQL statement and creates a array of hashs

   use IOToolkit;
   use Data::Dumper;
   print Dumper(IOToolkit::sql2data($dbh,"select * from environments"));


=head2 IOToolkit::encrypt and IOToolkit::decrypt

needs two strings as parameters (e.g. seed and password) and returns an
encrypted/decrypted value.

=head1 EXPORT

logme and gettimestamp are exported.

=head1 SEE ALSO

   http://www.linke.de for my personal homepage
   http://www.nmsalert.com for website monitoring solutions
   http://www.trackalizer.com for website visitor tracking and clickpath analysis

=head1 AUTHOR

Markus Linke, markus.linke@linke.de

=head1 COPYRIGHT AND LICENSE

Copyright 2003-2004 by Markus Linke

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=head1 AMENDMENT HISTORY

=cut

