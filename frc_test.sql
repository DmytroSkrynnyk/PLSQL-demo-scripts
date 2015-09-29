/* Does the function result cache work in my database? */

CREATE OR REPLACE FUNCTION frc_test
   RETURN VARCHAR2 result_cache
IS
BEGIN
   dbms_output.put_line ('Ran FRC_TEST');

   RETURN 'Return Value';

END;
/
BEGIN
   dbms_output.put_line (frc_test());
   dbms_output.put_line (frc_test());

END;
/