CREATE TYPE string_list_nt IS TABLE OF VARCHAR2 (32767);
/

CREATE OR REPLACE FUNCTION is_value_in_list (
   list_in    IN   string_list_nt
 , value_in   IN   VARCHAR2
)
   RETURN NUMBER
IS
   l_listcount     NUMBER;
   col_val         VARCHAR2 (80);
   exit_function   EXCEPTION;
BEGIN
   IF list_in.COUNT = 0
   THEN
      DBMS_OUTPUT.put_line ('List does not contain any values');
      RAISE exit_function;
   END IF;

   IF value_in IS NULL
   THEN
      DBMS_OUTPUT.put_line ('Value for matching must not be NULL.');
      RAISE exit_function;
   END IF;

   l_listcount := list_in.COUNT;

   FOR indx IN 1 .. l_listcount
   LOOP
      IF UPPER (list_in (indx)) = UPPER (value_in)
      THEN
         RETURN indx;
      END IF;
   END LOOP;

   RAISE exit_function;
EXCEPTION
   WHEN exit_function
   THEN
      RETURN 0;
END;
/