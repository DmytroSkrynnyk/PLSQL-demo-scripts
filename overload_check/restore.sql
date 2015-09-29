INSERT INTO cc_testcases
   SELECT ID, owner, package_name, object_name, description
     FROM cc_backup_testcases;

INSERT INTO cc_ovld_outcomes
   SELECT ID, testcase_id, overload1, startarg1, endarg1, overload2, startarg2,
          endarg2
     FROM cc_backup_control;