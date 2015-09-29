CREATE OR REPLACE PROCEDURE plch_raise_error (nth_in IN INTEGER, keep_in in boolean)
   authid definer
IS
BEGIN
   IF nth_in <= 100
   THEN
      plch_raise_error (nth_in + 1, keep_in);
   ELSE
      RAISE NO_DATA_FOUND;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      --RAISE VALUE_ERROR;
       raise_application_error (
         -20000 - nth_in,
         'Error raised in ' || nth_in || 'th call',
         keep_in); 
END;
/

BEGIN
   plch_raise_error (1, true);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (LENGTH (SQLERRM));
      DBMS_OUTPUT.put_line (SQLERRM);
END;
/

BEGIN
   plch_raise_error (1, false);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (LENGTH (SQLERRM));
      DBMS_OUTPUT.put_line (SQLERRM);
END;
/

BEGIN
   plch_raise_error (1, true);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (LENGTH (DBMS_UTILITY.format_error_stack));
      DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack);
END;
/

BEGIN
   plch_raise_error (1, false);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (LENGTH (DBMS_UTILITY.format_error_stack));
      DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack);
END;
/