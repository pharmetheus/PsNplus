#!/etc/bin/perl


use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/.."; #location of includes.pm
use includes; #file with paths to PsN packages
use Test::More;
use scmlogfile;


my $logfile = scmlogfile->new(filename => $includes::testfiledir.'/forward_pheno.logf',
							  test_relations => {'V' => ['WGT'],'CL' => ['WGT','APGR']});

is(scalar(@{$logfile->steps}),3,'three steps in file');
is($logfile->steps->[0]->directory(),'/home/kajsa/sandbox/asrscm/asrscm_dir13/m1','directory step 1');
is($logfile->steps->[1]->directory(),'/home/kajsa/sandbox/asrscm/asrscm_dir13/reduced_scm_dir1/m1','directory step 2');
is($logfile->steps->[2]->directory(),'/home/kajsa/sandbox/asrscm/asrscm_dir13/reduced_scm_dir1/scm_dir1/m1','directory step 3');

is($logfile->steps->[0]->candidates()->[0]->{'covariate'},'APGR','candidate 1 step 1 covariate');
is($logfile->steps->[0]->candidates()->[2]->{'parameter'},'V','candidate 3 step 1 parameter');

my ($drop,$have,$any_stashed,$reduced);

($have,$any_stashed,$drop) = $logfile->get_dropped_relations(p_cutoff => 0.01,step=>0,keep_local_min => 0,keep_failed => 0);
is($have,0,'no failed steps');
is($any_stashed,1,'stashed count');
#is_deeply($drop,{'V' => {'WGT'=>1},'CL' => {'WGT'=>1, 'APGR'=> 0}},'filter low cutoff');
is_deeply($drop,{'CL' => {'APGR'=> 1}},'filter low cutoff');


($have,$any_stashed,$drop) = $logfile->get_dropped_relations(p_cutoff => 0.5,step=>0,keep_local_min => 0,keep_failed => 0);
is($have,0,'no failed steps');
is($any_stashed,0,'stashed count');
is_deeply($drop,{},'filter high cutoff');

($have,$any_stashed,$drop) = $logfile->get_dropped_relations(p_cutoff => 0.3,keep_local_min => 0,keep_failed => 0);
is($have,0,'no failed steps');
is($any_stashed,2,'stashed count');
is_deeply($drop,{'V' => {'WGT'=>1},'CL' => {'WGT'=>1}},'filter default last step');

($have,$any_stashed,$drop) = $logfile->get_dropped_relations(p_cutoff => 0.2,keep_local_min => 0,keep_failed => 0);
is($have,0,'no failed steps');
is($any_stashed,3,'stashed count');
is_deeply($drop,{'V' => {'WGT'=>1},'CL' => {'WGT'=>1, 'APGR'=> 1}},'filter default last step low cutoff');


$logfile = scmlogfile->new(filename => $includes::testfiledir.'/localmin.logf',
						   test_relations => {'V' => ['WGT','CV2','CVD1'],'CL' => ['WGT','APGR','CV1']});


is(scalar(@{$logfile->steps}),8,'eight steps in file');

is($logfile->steps->[0]->candidates()->[0]->{'covariate'},'APGR','candidate 1 step 1 covariate');
is($logfile->steps->[0]->candidates()->[2]->{'parameter'},'CL','candidate 3 step 1 parameter');


($have,$any_stashed,$drop) = $logfile->get_dropped_relations(p_cutoff => 0.01,step=>0,keep_local_min => 0,keep_failed => 0);
is($have,0,'no failed steps');
is($any_stashed,4,'stashed count');
is_deeply($drop,{'CL' => {'APGR'=> 1,'CV1' => 1}, 'V' => {'CVD1' => 1, 'CV2' => 1}},'filter low cutoff drop local min');

($have,$any_stashed,$drop) = $logfile->get_dropped_relations(p_cutoff => 0.01,step=>0,keep_local_min => 1,keep_failed => 0);
is($have,0,'no failed steps');
is($any_stashed,2,'stashed count');
is_deeply($drop,{'CL' => {'CV1' => 1}, 'V' => {'CVD1' => 1}},'filter low cutoff keep local min');

$logfile = scmlogfile->new(directory => $includes::testfiledir.'/scm_dir1',
						   filename => 'scmlog.txt');

is($logfile->steps->[0]->p_value(),'0.4','step 0 pvalue');
is($logfile->steps->[0]->chosen_index(),5,'step 0 chosen index');
is_deeply($logfile->steps->[2]->posterior_included_relations(),[{'parameter'=> 'CL','covariate' => 'CV1','state' => '2'},
																{'parameter'=> 'CL','covariate' =>'WGT','state' =>'2'},
																{'parameter'=> 'V','covariate' =>'WGT','state' =>'2'}],
		  'posterior relations');
is($logfile->steps->[8]->p_value(),'0.001','step 8 pvalue');
is($logfile->steps->[8]->chosen_index(),0,'step 8 chosen index');
is_deeply($logfile->steps->[8]->posterior_included_relations(),[{'parameter'=> 'CL','covariate' =>'WGT','state' =>'2'},
																{'parameter'=> 'V','covariate' =>'WGT','state' =>'2'}],
		  'posterior relations 2');

is_deeply($logfile->steps->[8]->get_summary(),[['Backward 1','CV1','CL','1','587.15896','590.06016','-2.90120','0.001']],'summary step 8');
is_deeply($logfile->steps->[9]->get_summary(counter=> 3),[['Backward 3',undef,undef,undef,undef,undef,undef,undef]],'summary step 9');

is_deeply($logfile->steps->[9]->get_summary(counter=> 3),[['Backward 3',undef,undef,undef,undef,undef,undef,undef]],'summary step 9');
is_deeply($logfile->steps->[8]->get_summary(summarize_posterior => 1),
		  [['Final included','WGT','CL','2',undef,undef,undef,undef],
		   ['Final included','WGT','V','2',undef,undef,undef,undef]],'summary step 9 posterior');

is_deeply($logfile->get_statistics(),{
	'CLAPGR'=>{ 2=> {'tested' => 6, 'ok' => 6, 'failed' => 0, 'local_min' => 0,'stash_step' => 0, 'retest_step' => 0,'chosen_step' => 0,'removed_backward_step' => 0}}, 
	'CLCV1' =>{2 => {'tested' => 3, 'ok' => 3, 'failed' => 0, 'local_min' => 0,'stash_step' => 0, 'retest_step' => 0,'chosen_step' => 3,'removed_backward_step' => 3}},
	'CLWGT' =>{2 => {'tested' => 2, 'ok' => 2, 'failed' => 0, 'local_min' => 0,'stash_step' => 0, 'retest_step' => 0,'chosen_step' => 2,'removed_backward_step' => 0}},
	'VCV2' => {2 => {'tested' => 4, 'ok' => 4, 'failed' => 0, 'local_min' => 0,'stash_step' => 0, 'retest_step' => 0,'chosen_step' => 4,'removed_backward_step' => 2}}, 
	'VCVD1' =>{2 => {'tested' => 5, 'ok' => 5, 'failed' => 0, 'local_min' => 0,'stash_step' => 0, 'retest_step' => 0,'chosen_step' => 5,'removed_backward_step' => 1}},
	'VWGT' =>{2 => {'tested' => 1, 'ok' => 1, 'failed' => 0, 'local_min' => 0,'stash_step' => 0, 'retest_step' => 0,'chosen_step' => 1,'removed_backward_step' => 0}}
		  },'statistics 1 forward');


is_deeply($logfile->get_summary_matrix(),[
			  ['Forward 1','WGT','V','2','725.60200','629.27205','96.32995','0.4'],
			  ['Forward 2','WGT','CL','2','629.27205','590.06016','39.21190','0.4'],
			  ['Forward 3','CV1','CL','2','590.06016','587.15896','2.90120','0.4'],
			  ['Forward 4','CV2','V','2','587.15896','584.15462','3.00434','0.4'],
			  ['Forward 5','CVD1','V','2','584.15462','582.97276','1.18187','0.4'],
			  ['Forward 6',undef,undef,undef,undef,undef,undef,undef], 
			  ['Backward 1','CVD1','V','1','582.97276','584.15462','-1.18187','0.001'], 
			  ['Backward 2','CV2','V','1','584.15462','587.15896','-3.00434','0.001'], 
			  ['Backward 3','CV1','CL','1','587.15896','590.06016','-2.90120','0.001'],
			  ['Backward 4',undef,undef,undef,undef,undef,undef,undef], 
			  ['Final included','WGT','CL','2',undef,undef,undef,undef],
			  ['Final included','WGT','V','2',undef,undef,undef,undef]],
'logfile get summary');

#print $logfile->get_perl_statistics_string();

$logfile = scmlogfile->new(directory => $includes::testfiledir.'/scmplus_dir1',
						   filename => 'scmlog.txt');

#print $logfile->get_perl_statistics_string();

is($logfile->is_asrscm(),1,'asrscm logfile');
is($logfile->warnings(),'','asrscm warnings');
is_deeply($logfile->stashed_relations(),{'CL' => {'APGR'=> {'step' => 1, 'retest' => 3}, 'CV1' => {'step' => 1, 'retest' => 3}},'V' => {'CV2' => {'step' => 1, 'retest' => 3}, 'CVD1' => {'step' => 1, 'retest' => 3}}},'asrscm stashed');


is_deeply($logfile->get_statistics(),{
	'CLAPGR'=>{ 2=> {'tested' => 4, 'ok' => 2, 'failed' => 0, 'local_min' => 2,'stash_step' => 1, 'retest_step' => 3,'chosen_step' => 0,'removed_backward_step' => 0}}, 
	'CLCV1' =>{2 => {'tested' => 2, 'ok' => 2, 'failed' => 0, 'local_min' => 0,'stash_step' => 1, 'retest_step' => 3,'chosen_step' => 3,'removed_backward_step' => 2}},
	'CLWGT' =>{2 => {'tested' => 2, 'ok' => 2, 'failed' => 0, 'local_min' => 0,'stash_step' => 0, 'retest_step' => 0,'chosen_step' => 2,'removed_backward_step' => 3}},
	'VCV2' => {2 => {'tested' => 3, 'ok' => 3, 'failed' => 0, 'local_min' => 0,'stash_step' => 1, 'retest_step' => 3,'chosen_step' => 4,'removed_backward_step' => 1}}, 
	'VCVD1' =>{2 => {'tested' => 4, 'ok' => 3, 'failed' => 0, 'local_min' => 1,'stash_step' => 1, 'retest_step' => 3,'chosen_step' => 0,'removed_backward_step' => 0}},
	'VWGT' =>{2 => {'tested' => 1, 'ok' => 1, 'failed' => 0, 'local_min' => 0,'stash_step' => 0, 'retest_step' => 0,'chosen_step' => 1,'removed_backward_step' => 0}}
		  },'statistics asrscm');

#print $logfile->get_perl_statistics_string();

$logfile = scmlogfile->new(directory => $includes::testfiledir.'/gofofv_dir1',
						   filename => 'scmlog.txt');
#print $logfile->get_perl_statistics_string();

is($logfile->is_asrscm(),0,'not asrscm logfile');
is_deeply($logfile->get_statistics(),{
	'CLAPGR'=>{ 2=> {'tested' => 5, 'ok' => 5, 'failed' => 0, 'local_min' => 0,'stash_step' => 0, 'retest_step' => 0,'chosen_step' => 0,'removed_backward_step' => 0}}, 
	'CLCV1' =>{2 => {'tested' => 3, 'ok' => 3, 'failed' => 0, 'local_min' => 0,'stash_step' => 0, 'retest_step' => 0,'chosen_step' => 3,'removed_backward_step' => 2}},
	'CLWGT' =>{2 => {'tested' => 2, 'ok' => 2, 'failed' => 0, 'local_min' => 0,'stash_step' => 0, 'retest_step' => 0,'chosen_step' => 2,'removed_backward_step' => 0}},
	'VCV2' => {2 => {'tested' => 4, 'ok' => 4, 'failed' => 0, 'local_min' => 0,'stash_step' => 0, 'retest_step' => 0,'chosen_step' => 4,'removed_backward_step' => 1}}, 
	'VCVD1' =>{2 => {'tested' => 5, 'ok' => 5, 'failed' => 0, 'local_min' => 0,'stash_step' => 0, 'retest_step' => 0,'chosen_step' => 0,'removed_backward_step' => 0}},
	'VWGT' =>{2 => {'tested' => 1, 'ok' => 1, 'failed' => 0, 'local_min' => 0,'stash_step' => 0, 'retest_step' => 0,'chosen_step' => 1,'removed_backward_step' => 0}}
		  },'statistics gof ofv forward');


is_deeply($logfile->get_summary_matrix(),[
			  ['Forward 1','WGT','V','2','725.60200','629.27205','96.32995',undef],
			  ['Forward 2','WGT','CL','2','629.27205','590.06016','39.21190',undef],
			  ['Forward 3','CV1','CL','2','590.06016','587.15896','2.90120',undef],
			  ['Forward 4','CV2','V','2','587.15896','584.15462','3.00434',undef],
			  ['Forward 5',undef,undef,undef,undef,undef,undef,undef], 
			  ['Backward 1','CV2','V','1','584.15462','587.15896','-3.00434',undef], 
			  ['Backward 2','CV1','CL','1','587.15896','590.06016','-2.90120',undef],
			  ['Backward 3',undef,undef,undef,undef,undef,undef,undef], 
			  ['Final included','WGT','CL','2',undef,undef,undef,undef],
			  ['Final included','WGT','V','2',undef,undef,undef,undef]],
'logfile get summary gof ofv');

is($logfile->get_report_string(ofv_table => 1,as_R => 1,decimals=>2),'data.frame(stringsAsFactors = FALSE,
Step = c("Forward 1","Forward 2","Forward 3","Forward 4","Forward 5","Backward 1","Backward 2","Backward 3","Final included","Final included"),
covariate = c("WGT","WGT","CV1","CV2",NA,"CV2","CV1",NA,"WGT","WGT"),
parameter = c("V","CL","CL","V",NA,"V","CL",NA,"CL","V"),
state = c(2,2,2,2,NA,1,1,NA,2,2),
BASEOFV = c(725.60,629.27,590.06,587.16,NA,584.15,587.16,NA,NA,NA),
NEWOFV = c(629.27,590.06,587.16,584.15,NA,587.16,590.06,NA,NA,NA),
OFVDROP = c(96.33,39.21,2.90,3.00,NA,-3.00,-2.90,NA,NA,NA),
pvalue = c(NA,NA,NA,NA,NA,NA,NA,NA,NA,NA))
','R string');

$logfile = scmlogfile->new(directory => $includes::testfiledir.'/backward_dir1',
						   filename => 'scmlog.txt');
#print $logfile->get_perl_statistics_string();

is_deeply($logfile->get_statistics(),{
	'CLCV1' =>{1 => {'tested' => 3, 'ok' => 3, 'failed' => 0, 'local_min' => 0,'stash_step' => 0, 'retest_step' => 0,'chosen_step' => 3,'removed_backward_step' => 0}},
	'CLWGT' =>{1 => {'tested' => 4, 'ok' => 4, 'failed' => 0, 'local_min' => 0,'stash_step' => 0, 'retest_step' => 0,'chosen_step' => 0,'removed_backward_step' => 0}},
	'VCV2' => {1 => {'tested' => 2, 'ok' => 2, 'failed' => 0, 'local_min' => 0,'stash_step' => 0, 'retest_step' => 0,'chosen_step' => 2,'removed_backward_step' => 0}}, 
	'VCVD1' =>{1 => {'tested' => 1, 'ok' => 1, 'failed' => 0, 'local_min' => 0,'stash_step' => 0, 'retest_step' => 0,'chosen_step' => 1,'removed_backward_step' => 0}},
	'VWGT' =>{1 => {'tested' => 4, 'ok' => 4, 'failed' => 0, 'local_min' => 0,'stash_step' => 0, 'retest_step' => 0,'chosen_step' => 0,'removed_backward_step' => 0}}
		  },'statistics 1 backward');

$logfile = scmlogfile->new(directory => $includes::testfiledir.'/mergeofv_dir1',
						   filename => 'scmlog.txt');

is($logfile->is_asrscm(),0,'not asrscm logfile');



my ($header,$format) = scmlogfile::get_scm_header_and_format(attributes => ['status','ofvdrop','tested','ok','local_min','failed'],
															 stepname => 'NextForward');

is_deeply($header,['Model','NextForward','ofvdrop','N_test','N_ok','N_localmin','N_failed'],'scm header');
is($format,"%-15s %12s %12s %7s %7s %10s %8s\n",'scm format');

$logfile = scmlogfile->new(filename => $includes::testfiledir.'/mergeofv_dir1/scmlog.txt',
						   test_relations => {'PHA' => ['AGE','BMI','CYCLL','DIAG','DISDUR','GEOREG','LBEST','MENS','WT'],
											  'PHIA' => ['AGE','BMI','CYCLL','DIAG','DISDUR','GEOREG','LBEST','MENS','WT'],
											  'PHIB'=>['AGE','BMI','CYCLL','DIAG','DISDUR','GEOREG','LBEST','MENS','WT'],
											  'SLP'=>['AGE','BMI','CYCLL','DIAG','DISDUR','GEOREG','LBEST','MENS','WT']});

($have,$any_stashed,$drop) = $logfile->get_dropped_relations(p_cutoff => 0.7,
															 step=>8,
															 keep_local_min => 1,
															 keep_failed => 0);
is($have,1,'one failed step');
is($any_stashed,7,'stashed count');
is_deeply($drop,{'PHA' => {'LBEST'=> 1},
				 'PHIA'=>{'AGE'=>1,'DIAG'=>1},
				 'PHIB'=>{'AGE'=>1,'BMI'=>1,
						  'CYCLL'=>1,'WT'=>1}},'filter drop failed');

($have,$any_stashed,$drop) = $logfile->get_dropped_relations(p_cutoff => 0.7,
															 step=>8,
															 keep_local_min => 1,
															 keep_failed => 1);
is($have,1,'one failed step');
is($any_stashed,6,'stashed count');
is_deeply($drop,{'PHIA'=>{'AGE'=>1,'DIAG'=>1},
				 'PHIB'=>{'AGE'=>1,'BMI'=>1,
						  'CYCLL'=>1,'WT'=>1}},'filter keep failed');


is_deeply(scmlogfile::sort_on_last_column([['parcov','5',10],['parcova','1',-10.5],['parcovb','2',10E5],['parcovc','4',2]],(lc('ofv') =~ /drop/) ),
		  [['parcova','1',-10.5],['parcovc','4',2],['parcov','5',10],['parcovb','2',10E5]],'sort by last col increasing');

is_deeply(scmlogfile::sort_on_last_column([['parcov','5',10],['parcova','1',-10.5],['parcovb','2',10E5],['parcovc','4',2]],(lc('ofvdrop') =~ /drop/)),
		  [['parcovb','2',10E5],['parcov','5',10],['parcovc','4',2],['parcova','1',-10.5]],'sort by last col decreasing');



is_deeply(scmlogfile::parse_relations_list(text => 'KA-WT,,KA-AGE,KA-BALAT,KA-STUD,V2-AGE,V2-STUD,'),
		  [{'parameter' => 'KA', 'covariate' => 'WT','parcov' => 'KAWT'},
		   {'parameter' => 'KA', 'covariate' => 'AGE','parcov' => 'KAAGE'},
		   {'parameter' => 'KA', 'covariate' => 'BALAT','parcov' => 'KABALAT'},
		   {'parameter' => 'KA', 'covariate' => 'STUD','parcov' => 'KASTUD'},
		   {'parameter' => 'V2', 'covariate' => 'AGE','parcov' => 'V2AGE'},
		   {'parameter' => 'V2', 'covariate' => 'STUD','parcov' => 'V2STUD'}],'parse relations list');

		  
done_testing();
