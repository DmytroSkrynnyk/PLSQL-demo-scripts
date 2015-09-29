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
   WHEN OTHERS THEN
   IF SQLCODE = -24381 
   THEN
      DBMS_OUTPUT.put_line (dbms_utility.format_error_stack);
      DBMS_OUTPUT.put_line ('Updated ' || SQL%ROWCOUNT || ' rows.');

      FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
      LOOP
         DBMS_OUTPUT.put_line
              (   'Error '
               || indx
               || ' occurred on index '
               || SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX
               || ' attempting to update name to "'
               || enames_with_errors (SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX)
               || '"'
              );
         DBMS_OUTPUT.put_line
                             (   'Oracle error is '
                              || SQLERRM
                                      (  -1
                                       * SQL%BULK_EXCEPTIONS (indx).ERROR_CODE
                                      )
                             );
      END LOOP;

      ROLLBACK;
   ELSE
      RAISE;
   END IF;
END;