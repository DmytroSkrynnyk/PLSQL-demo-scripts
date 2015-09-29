CREATE OR REPLACE PACKAGE BODY ut_betwnstr
IS 
   PROCEDURE ut_setup
   IS
   BEGIN
      -- No setup required for a deterministic function
	  NULL;
   END;

   PROCEDURE ut_teardown
   IS
   BEGIN
      -- No setup required for a deterministic function
	  NULL;
   END;

   -- Test the betwnstr function

   PROCEDURE ut_betwnstr
   IS 
      -- Variables for the control and test data.
      against_this   VARCHAR2 (2000);
      check_this     VARCHAR2 (2000);
   BEGIN
      -- Define "control" operation for "normal"
      against_this := 'cde';
      -- Execute test code for "normal"
      check_this := betwnstr (
                       string_in      => 'abcdefgh',
                       start_in       => 3,
                       end_in         => 5
                    );
					
      -- Assert success for "normal"
      -- Compare the two values.
      utassert.eq ('normal', check_this, against_this);
      -- End of test for "normal"

      -- Define "control" operation for "zero start"
      against_this := 'abc';
      -- Execute test code for "zero start"
      check_this := betwnstr (
                       string_in      => 'abcdefgh',
                       start_in       => 0,
                       end_in         => 2
                    );
      -- Assert success for "zero start"
      -- Compare the two values.
      utassert.eq ('zero start', check_this, against_this);
      -- End of test for "zero start"

      -- Define "control" operation for "null start"
      against_this := NULL;
      -- Execute test code for "null start"
      check_this := betwnstr (
                       string_in      => 'abcdefgh',
                       start_in       => NULL,
                       end_in         => 2
                    );
      -- Assert success for "null start"
      -- Check for NULL return value.
      utassert.isnull ('null start', check_this);
      -- End of test for "null start"

      -- Define "control" operation for "big start small end"
      against_this := NULL;
      -- Execute test code for "big start small end"
      check_this := betwnstr (
                       string_in      => 'abcdefgh',
                       start_in       => 10,
                       end_in         => 5
                    );
      -- Assert success for "big start small end"
      -- Check for NULL return value.
      utassert.isnull ('big start small end', check_this);
      -- End of test for "big start small end"

      -- Define "control" operation for "null end"
      against_this := NULL;
      -- Execute test code for "null end"
      check_this := betwnstr (
                       string_in      => 'abcdefgh',
                       start_in       => 3,
                       end_in         => NULL
                    );
      -- Assert success for "null end"
      -- Check for NULL return value.
      utassert.isnull ('null end', check_this);
      -- End of test for "null end"

      -- Define "control" operation for "bigstr"
      against_this := NULL;
      -- Execute test code for "bigstr"
      check_this := betwnstr (
                       string_in      => RPAD ('abc', 2000),
                       start_in       => 3,
                       end_in         => NULL
                    );
      -- Assert success for "bigstr"
      -- Check for NULL return value.
      utassert.isnull ('biggie', check_this);
      -- End of test for "bigstr"
   END ut_betwnstr;
END ut_betwnstr;
/