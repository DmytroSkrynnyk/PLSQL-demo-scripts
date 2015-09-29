/* You have already run the syrecomp.sp script
   in an account with access to SYS.DBA_OBJECTS */
   
/* Remove the job if it already is running */
DECLARE 
   jobno INTEGER;
BEGIN
   SELECT job INTO jobno
     FROM user_jobs
    WHERE UPPER (what) LIKE '%RECOMP%';

   DBMS_OUTPUT.PUT_LINE ('Removing job ' || jobno);
   DBMS_JOB.REMOVE (jobno);

EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
END;
/

DECLARE
   jobno   NUMBER;
BEGIN
   DBMS_JOB.SUBMIT
      (job  => jobno
      ,what => 'BEGIN recompile.invalids; END;'
      ,next_date => SYSDATE
      ,interval  => 'SYSDATE+60/1440');
   COMMIT;
END;
/

