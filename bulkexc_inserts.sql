CREATE TABLE plch_quick
      (
         n NUMBER(3)
      )
/
DECLARE ns dbms_Sql.number_table;
BEGIN
   ns(1) := 100;
   ns(2) := 2000;
   ns(3) := 100;
   FORALL indx IN 1 .. 3

   INSERT
      INTO plch_quick VALUES
         (
            ns(indx)
         );

EXCEPTION

WHEN OTHERS THEN
   DBMS_OUTPUT.put_line ( 'Inserted ' || SQL%ROWCOUNT || ' rows.');
   DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack);
   ROLLBACK;

END;
/

DROP TABLE plch_quick;