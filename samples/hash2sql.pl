#!/hfx/opt/perl-5.8/bin/perl

use strict;
use warnings;
use IOToolkit;
use DBI;
use Data::Dumper;

use vars qw($getopt_loglevel $program $programname);

$getopt_loglevel = "all";
$program         = $0;      # Script Name with path
$program =~ m/\/(.+)/i;     # Only the scriptname
$programname = $1;
$program =~ m/(.+)\.pl/i;    # Without the extension
$program = $1;

logme("open");

my $dsn = "DBI:Sybase:loginTimeout=300:server=xxx;database=xxx";
my $dbh =
  DBI->connect($dsn, "xxx", "xxx", {RaiseError => 1, AutoCommit => 1})
  || logme("F", "Database Error: $DBI::errstr");
logme("D", "dbconnect ok");
$dbh->{RaiseError} = 0;      # dont show error messages from dbi
$dbh->{PrintError} = 0;      # dont show error messages from dbi

my %hash = (description => "whatever",
            status      => "new",);

my $sql = IOToolkit::hash2sqlinsert("testtable", %hash);
logme("S", $sql);
IOToolkit::dosql($dbh, $sql);

while (1) {
   logme("D", "loop");
   my @results =
     IOToolkit::sql2data($dbh, "select * from testtable where status = \"new\"");

   for my $href (@results)
   {
       logme("D","doing something with ".$href->{description});
   }
   sleep(60); # wait a minute
}

logme("close");
$dbh->disconnect();
1;

