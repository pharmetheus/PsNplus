#!/etc/bin/perl

use strict;
use warnings;
use Test::More;
use Test::Exception;
use File::Path 'rmtree';
use FindBin qw($RealBin);
use lib "$RealBin/.."; #location of includes.pm
use includes; #file with paths to PsN packages and $path variable definition


our $tempdir = create_test_dir('system_scmplus2');

our $dir = "$tempdir/scmplus_test";

my @configs=('run1.scm');
my @runs = (
	'run1.scm -no-abort_on_fail',
	'run1.scm -scope=none -etas -no-abort_on_fail',
);


my @extra_files = qw (
run1.mod
pheno.dta
run1.lst
run1.phi
);


copy_test_files($tempdir,\@configs);
copy_test_files($tempdir,\@extra_files);

chdir($tempdir);

foreach my $cmd (@runs) {
	my $command = get_command('scmplus').' '.$cmd.' ';
	my $rc = system($command);
	$rc = $rc >> 8;
	ok ($rc == 0, "scmplus $cmd crash test");

}


#my $dir = 'newtest1';
my %options = ('etas'=> undef,
			   'maxevals' => undef,
			   'ctype4' => undef,
	);
#monitor::get_options(directory => $dir, options => \%options);
	
#print("tempdir is $tempdir");
remove_test_dir($tempdir);

done_testing();
