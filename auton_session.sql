DROP TABLE logtab
/

CREATE TABLE logtab
(
   code         INTEGER
 , text         VARCHAR2 (4000)
 , created_on   DATE
 , created_by   VARCHAR2 (100)
 , changed_on   DATE
 , changed_by   VARCHAR2 (100)
 , machine      VARCHAR2 (100)
 , program      VARCHAR2 (100)
)
/

CREATE OR REPLACE PACKAGE logpkg
IS
   PROCEDURE putline (code_in IN INTEGER, text_in IN VARCHAR2);

   PROCEDURE saveline (code_in IN INTEGER, text_in IN VARCHAR2);
END;
/

CREATE OR REPLACE PACKAGE BODY logpkg
IS
   CURSOR sess
   IS
      SELECT machine, program
        FROM v$session
       WHERE audsid = USERENV ('SESSIONID');

   rec   sess%ROWTYPE;

   PROCEDURE putline (code_in IN INTEGER, text_in IN VARCHAR2)
   IS
   BEGIN
      INSERT INTO logtab
          VALUES (
                     code_in
                   , text_in
                   , SYSDATE
                   , USER
                   , SYSDATE
                   , USER
                   , rec.machine
                   , rec.program
                 );
   END;

   PROCEDURE saveline (code_in IN INTEGER, text_in IN VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      /* Denver Nov 2008: show that commit is not REQUIRED. */
      IF code_in = -12
      THEN
         DBMS_OUTPUT.put_line ('help!');
         RAISE PROGRAM_ERROR;
      ELSE
         INSERT INTO logtab
             VALUES (
                        code_in
                      , text_in
                      , SYSDATE
                      , USER
                      , SYSDATE
                      , USER
                      , rec.machine
                      , rec.program
                    );
dbms_lock.sleep (15);
         COMMIT;
      END IF;
   EXCEPTION
      WHEN PROGRAM_ERROR
      THEN
         /* No rollback is needed! */
         RAISE;
      WHEN DUP_VAL_ON_INDEX
      THEN
         ROLLBACK;
      WHEN OTHERS
      THEN
         -- Table write failure, perhaps we should write to file as backup?
         ROLLBACK;
         RAISE;
   END;
BEGIN
   DBMS_OUTPUT.put_line ('Initializing log...');

   OPEN sess;

   FETCH sess INTO rec;

   CLOSE sess;
END;
/

BEGIN
   DBMS_OUTPUT.put_line (SYSDATE);
   logpkg.putline (1, 'Putline the date');
   logpkg.saveline (1, 'Saveline the date');
   ROLLBACK;
END;
/