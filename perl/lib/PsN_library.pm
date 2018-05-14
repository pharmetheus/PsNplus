package PsN_library;
use vars qw/$psnlib/;
use strict;
BEGIN{
	my $useStaticPsNversion = 0;

	if ($useStaticPsNversion){
		$psnlib = "/opt/psn/psn-4.7.0/PsN_4_7_0";
	}else{
		use Config;

		my $command = 'psn installation_info 2>/dev/null'; #unix, keep stdout and redirect stderr to /dev/null
		if ($Config{osname} eq 'MSWin32'){
			# keep stdout but redirect stderr to nul
			$command = 'psn installation_info 2>nul';
		}
		my @outp = readpipe($command);
		my $current_config_file;
		my $current_lib_dir;
		my $current_bin_dir;
		my $current_version;
		eval(join(' ',@outp));
		if (defined $current_lib_dir){
			$psnlib = $current_lib_dir;
		}else{
			die("PsN version is either too old (< 4.7.0) or script psn is not in your path.\n".
				"To diagnose run command\n"."psn -version\n");
		}
	}
}

use lib $psnlib;
use PsN;

sub checkPsNversion{
	my $scriptname = shift;
	my $smallestver = shift;
	my ($psnmajor,$psnminor,$psnrevision) = split(/\./,$PsN::version);
	unless ($psnmajor.'.'.$psnminor >= $smallestver){
		die("PsN version $psnmajor.$psnminor.$psnrevision is too old for $scriptname, at least $smallestver required\n");
	}
}


1;
