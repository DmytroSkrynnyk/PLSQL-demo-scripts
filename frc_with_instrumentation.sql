CREATE TABLE plch_log_table
      (
         log_info VARCHAR2(1000)
      )
/

CREATE OR REPLACE PROCEDURE plch_log
(
   info_in IN VARCHAR2
)
IS pragma autonomous_transaction;
BEGIN

   INSERT
      INTO plch_log_table VALUES
         (
            info_in
         );
   COMMIT;

END;
/

CREATE OR REPLACE FUNCTION plch_cache
   RETURN VARCHAR2 RESULT_CACHE
IS
BEGIN
   plch_log ('log!');
   dbms_output.put_line ('Executed body!');
   RETURN 'logged it';

END;
/
BEGIN
   dbms_output.put_line (plch_cache());
   dbms_output.put_line (plch_cache());

END;
/

SELECT    COUNT(*)
   FROM plch_log_table
/

DROP TABLE plch_log_table
/

DROP PROCEDURE plch_log
/

DROP FUNCTION plch_cache 
/

/*
Executed body!
logged it
logged it
*/