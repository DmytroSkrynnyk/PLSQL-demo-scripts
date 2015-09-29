CREATE OR REPLACE PACKAGE BODY cc_error
/*
Codecheck: the QA utility for PL/SQL code
Copyright (C) 2002, Steven Feuerstein
All rights reserved

cc_error: consolidates all error-handling functionality
*/
IS
   FUNCTION errmsg (error_in IN PLS_INTEGER)
      RETURN cc_error_info.errmsg%TYPE
   IS
      retval   cc_error_info.errmsg%TYPE;
   BEGIN
      SELECT errmsg
        INTO retval
        FROM cc_error_info
       WHERE errcode = error_in;

      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END errmsg;

   PROCEDURE RAISE (error_in IN PLS_INTEGER, msg_in IN VARCHAR2 := NULL)
   IS
   BEGIN
      IF error_in BETWEEN -20999 AND -20000
      THEN
         raise_application_error (error_in, NVL (msg_in, errmsg (error_in)));
      /* Can't EXCEPTION_INIT -1403 */
      ELSIF error_in IN (100, -1403)
      THEN
         RAISE NO_DATA_FOUND;
      /* Re-raise any other exception. */
      ELSE
         EXECUTE IMMEDIATE    'DECLARE myexc EXCEPTION; '
                           || '   PRAGMA EXCEPTION_INIT (myexc, '
                           || TO_CHAR (error_in)
                           || ');'
                           || 'BEGIN  RAISE myexc; END;';
      END IF;
   END;

   PROCEDURE assert (
      condition_in    IN   BOOLEAN
     ,error_in        IN   PLS_INTEGER
     ,extra_info_in   IN   VARCHAR2
   )
   IS
   BEGIN
      IF error_in BETWEEN c_min_error_# AND c_max_error_#
      THEN
	     IF NOT condition_in OR condition_in IS NULL
         THEN
            cc_util.pl (cc_util.ifelse (extra_info_in IS NULL
                                       ,errmsg (error_in)
                                       ,    errmsg (error_in)
                                         || ' '
                                         || extra_info_in
                                       )
                       );
            cc_error.RAISE (error_in);
         END IF;
      ELSE
         cc_util.pl ('Undefined error number: ' || error_in);
      END IF;
   END;

   PROCEDURE initialize_error_table
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      INSERT INTO cc_error_info
                  (errcode, errmsg
                  )
           VALUES ('-20801', 'Specified object is not a package'
                  );

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
   END;
BEGIN
   initialize_error_table;
END cc_error;
/
