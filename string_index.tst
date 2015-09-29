DECLARE
   l_employee   hr.employees%ROWTYPE;
BEGIN
   /*
   First, a demonstration that the caching is done once per day.
   But when the date string changes (which I force in the test_caching
   program), then the cache is refreshed.
   */
   employees_cache.set_trace (TRUE);
   DBMS_OUTPUT.put_line ('*** Test cache, first touch, should load.');
   employees_cache.test_caching;
   DBMS_OUTPUT.put_line ('*** Test cache, second touch, should NOT load.');
   employees_cache.test_caching;
   DBMS_OUTPUT.put_line ('*** Test cache, third touch, force load.');
   employees_cache.test_caching ('20071212');
   /*
   And now a usage of the functions themselves....
   I retrieve a row by a primary key, and then use that row's
   email address to retrieve the row, so the email addresses 
   should match.
   */
   l_employee := employees_cache.onerow (137);
   DBMS_OUTPUT.put_line (l_employee.email);
   l_employee := employees_cache.onerow_by_emp_email_uk (l_employee.email);
   DBMS_OUTPUT.put_line (l_employee.email);
END;
/