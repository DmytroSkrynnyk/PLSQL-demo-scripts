CREATE OR REPLACE PACKAGE BODY ut_codecheck
/*
Codecheck: the QA utility for PL/SQL code
Copyright (C) 2002, Steven Feuerstein
All rights reserved

ut_codecheck: utPLSQL-compliant unit test package for Codecheck
*/
IS 
   PROCEDURE ut_setup
   IS
   BEGIN
      NULL;
   END;

   PROCEDURE ut_teardown
   IS
   BEGIN
      NULL;
   END;

   PROCEDURE ut_overloadings
   IS 
      l_name VARCHAR2(1000);
	  
      FUNCTION where_clause (rec_in IN cc_testcases%ROWTYPE)
         RETURN VARCHAR2
      IS
      BEGIN
         RETURN    ' WHERE owner = '''
                || rec_in.owner
                || ''' and '
                || 'package_name = '''
                || rec_in.package_name
                || ''' and '
                || 'object_name = '''
                || rec_in.object_name
                || '''';
      END;
   BEGIN
      FOR testcase IN (SELECT *
                         FROM cc_testcases)
      LOOP
	     -- Construct the "full name" of the object
		 l_name := 
		    cc_names.combined (
               testcase.owner,
               testcase.package_name,
               testcase.object_name
            );
			
         -- Analyze the overloadings
		 codecheck.overloadings (
            package_in => l_name
         );
		 
		 -- Check the results against the control table
         utassert.eqquery (
            l_name || ': ' || testcase.description,
            'select * from cc_ambig_ovld_results' || where_clause (testcase),
            'select * from cc_ovld_control' || where_clause (testcase)
         );
      END LOOP;
   END;

END ut_codecheck;
/
