use IOToolkit;
use Test::More tests => 6;
  
BEGIN { 
   use_ok( 'Crypt::RC6' );
   use_ok( 'IOToolkit' ); 
}
require_ok( 'IOToolkit' );

my $seed="12345678";
my $password="verysecr";
my $encrypt=IOToolkit::encrypt($seed,$password);
my $decrypt=IOToolkit::decrypt($seed,$encrypt);
cmp_ok($password,"==",$decrypt,"Encryption/Decryption");

my $timestamp = gettimestamp("filename");
cmp_ok(length($timestamp),"==",14,"Timestamp");

my %hash=(module=>"IOToolkit",copyright=>"Markus Linke");
my $sql=IOToolkit::hash2sqlinsert("testtable",%hash);
cmp_ok($sql,"==",'insert into testtable (copyright,module) values (\'Markus Linke\',\'IOToolkit\')',"hash2sqlinsert");
