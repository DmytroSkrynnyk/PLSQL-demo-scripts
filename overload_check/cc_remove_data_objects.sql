create table cc_backup_test as select * from cc_ambig_ovld_results;
create table cc_backup_control as select * from cc_ovld_outcomes;
create table cc_backup_testcases as select * from cc_testcases;

drop table cc_ambig_ovld_results;
drop table cc_ovld_outcomes;
drop table cc_testcases;
drop sequence cc_testcases_seq;
drop sequence cc_ovld_outcomes_seq;
