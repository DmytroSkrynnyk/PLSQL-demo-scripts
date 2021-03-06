CREATE OR REPLACE PROCEDURE raise_error (nth_in IN INTEGER)
IS
BEGIN
   IF nth_in <= 500
   THEN
      raise_error (nth_in + 1);
   ELSE
      RAISE NO_DATA_FOUND;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      raise_application_error (
         -20000 - nth_in,
         'Error raised in ' || nth_in || 'th call',
         TRUE);
END;
/

DECLARE
   PROCEDURE show_errors
   IS
   BEGIN
      DBMS_OUTPUT.put_line ('-------SQLERRM-------------');
      DBMS_OUTPUT.put_line (LENGTH (SQLERRM));
      DBMS_OUTPUT.put_line (SQLERRM);
      DBMS_OUTPUT.put_line ('-------FORMAT_ERROR_STACK--');
      DBMS_OUTPUT.put_line (LENGTH (DBMS_UTILITY.format_error_stack));
      DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack);
   END;
BEGIN
   raise_error (1);
EXCEPTION
   WHEN OTHERS
   THEN
      show_errors;
END;
/