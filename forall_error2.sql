DECLARE
   TYPE namelist_t IS TABLE OF VARCHAR2 (5000);

   enames_with_errors   namelist_t
      := namelist_t ('ABC'
                   , 'DEF'
                   , RPAD ('BIGBIGGERBIGGEST', 1000, 'ABC')
                   , 'LITTLE'
                   , RPAD ('BIGBIGGERBIGGEST', 3000, 'ABC')
                   , 'SMITHIE'
                    );
BEGIN
   FORALL indx IN 1 .. 
                  enames_with_errors.COUNT 
   SAVE EXCEPTIONS
      UPDATE employees
         SET first_name = enames_with_errors (indx);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line ('Updated ' || SQL%ROWCOUNT || ' rows.');
      DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack);
      ROLLBACK;
END;