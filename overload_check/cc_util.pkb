CREATE OR REPLACE PACKAGE BODY cc_util
/*
Codecheck: the QA utility for PL/SQL code
Copyright (C) 2002, Steven Feuerstein
All rights reserved

cc_util: holds the general utilities used by Codecheck packages
*/
IS
   PROCEDURE pl (str IN VARCHAR2, len IN INTEGER := 80)
   IS
      v_len PLS_INTEGER := LEAST (len, 255);
      v_len2 PLS_INTEGER;
      v_chr10 PLS_INTEGER;
   BEGIN
      IF LENGTH (str) > v_len
      THEN
         v_chr10 := INSTR (str, CHR (10));

         IF     v_chr10 > 0
            AND v_len < v_chr10
         THEN
            v_len :=   v_chr10
                     - 1;
            v_len2 :=   v_chr10
                      + 1;
         ELSE
            v_len :=   v_len
                     - 1;
            v_len2 := v_len;
         END IF;

         DBMS_OUTPUT.put_line (SUBSTR (str
                                      ,1
                                      ,v_len
                                      ));
         pl (SUBSTR (str, v_len2), len);
      ELSE
         DBMS_OUTPUT.put_line (str);
      END IF;
   END;

   FUNCTION strval (val IN BOOLEAN)
      RETURN VARCHAR2
   IS
   BEGIN
      IF val
      THEN
         RETURN ('TRUE');
      ELSIF NOT val
      THEN
         RETURN ('FALSE');
      ELSE
         RETURN ('NULL');
      END IF;
   END;

   PROCEDURE pl (val IN BOOLEAN)
   IS
   BEGIN
      pl (strval (val));
   END;

   PROCEDURE pl (str IN VARCHAR2, bool IN BOOLEAN)
   IS
   BEGIN
      pl (   str
          || ' '
          || strval (bool));
   END;

   PROCEDURE assert (condition_in IN BOOLEAN, msg_in IN VARCHAR2)
   IS
   BEGIN
      IF    NOT condition_in
         OR condition_in IS NULL
      THEN
         pl (msg_in);
         RAISE VALUE_ERROR;
      END IF;
   END;

   FUNCTION ifelse (
      condition_in IN BOOLEAN
     ,iftrue IN VARCHAR2
     ,iffalse IN VARCHAR2
     ,ifnull IN VARCHAR2 := NULL
   )
      RETURN VARCHAR2
   IS
   BEGIN
      IF condition_in
      THEN
         RETURN iftrue;
      ELSIF NOT condition_in
      THEN
         RETURN iffalse;
      ELSE
         RETURN ifnull;
      END IF;
   END;

   FUNCTION NVL2 (
      val_in IN VARCHAR2
     ,ifnull IN VARCHAR2
     ,ifnotnull IN VARCHAR2
   )
      RETURN VARCHAR2
   IS
   BEGIN
      IF val_in IS NULL
      THEN
         RETURN ifnull;
      ELSE
         RETURN ifnotnull;
      END IF;
   END;
END cc_util;
/
