/*
Demonstrates how to declare an associative array type, populate that array non-sequentially,
and iterate through the elements using methods.
*/
DECLARE
   TYPE list_of_names_t IS TABLE OF VARCHAR2 (32767)
                              INDEX BY PLS_INTEGER;

   happyfamily     list_of_names_t;
   -- Could also use a predefined array type!
   --happyfamily     dbms_sql.varchar2_table;
   l_index_value   PLS_INTEGER := 88;
BEGIN
   happyfamily (1) := 'Eli';
   happyfamily (-15070) := 'Steven';
   happyfamily (3) := 'Chris';
   happyfamily (l_index_value) := 'Veva';
   happyfamily (9999999) := 'Loey';
   happyfamily (9999998) := 'Lauren';

   DBMS_OUTPUT.put_line (happyfamily.COUNT);
   --
   l_index_value := happyfamily.FIRST;

   WHILE (l_index_value IS NOT NULL)
   LOOP
      DBMS_OUTPUT.put_line (
            'Name at index '
         || l_index_value
         || ' = '
         || happyfamily (l_index_value));

      l_index_value := happyfamily.NEXT (l_index_value);
   END LOOP;
/*
Don't use a numeric FOR loop with a sparse collection -
It will fail with a NO_DATA_FOUND exception.

FOR l_index_value IN happyfamily.FIRST .. happyfamily.LAST
LOOP
   DBMS_OUTPUT.put_line (happyfamily (l_index_value));
END LOOP;
*/
END;
/