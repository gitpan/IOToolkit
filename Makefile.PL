use 5.008;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'IOToolkit',
    'VERSION_FROM'	=> 'IOToolkit.pm', # finds $VERSION
    'PREREQ_PM'		=> {'Crypt::RC6'}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'IOToolkit.pm', # retrieve abstract from module
       AUTHOR     => 'Markus Linke <markus.linke@linke.de>') : ()),
    dist => {
	PREOP => 'svn log IOToolkit.pm > Changes;pod2text IOToolkit.pm > README;pod2html IOToolkit.pm > README.html',
    },
);
sub MY::libscan {
    my $path = $_[1];
    return '' if $path =~ /\B\.svn\b/;
    return $path;
}
