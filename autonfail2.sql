CREATE OR REPLACE PROCEDURE autonfail
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   DELETE FROM emp;
   RAISE VALUE_ERROR;
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN ROLLBACK TO out_here;   
END;
/
BEGIN
   SAVEPOINT out_here;
   autonfail;
END;
/   