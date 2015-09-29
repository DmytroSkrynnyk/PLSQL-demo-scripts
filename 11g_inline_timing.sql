alter session set Plsql_Warnings = 'Enable:All'
/
alter session set Plsql_Optimize_Level = 3
/

create or replace procedure show_inlining
is
   l_start_time   PLS_INTEGER;
   l_end_time     PLS_INTEGER;
   n              NUMBER;

   FUNCTION f1 (p NUMBER)
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN p * 10;
   END;

   FUNCTION f2 (p NUMBER)
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN p * 10;
   END;
BEGIN
   l_start_time := DBMS_UTILITY.get_time;

   FOR indx IN 1 .. 10000000
   LOOP
      PRAGMA INLINE (f1, 'YES');
      n := f1 (indx);
   END LOOP;

   DBMS_OUTPUT.put_line (DBMS_UTILITY.get_time - l_start_time);

   l_start_time := DBMS_UTILITY.get_time;

   FOR indx IN 1 .. 10000000
   LOOP
      n := f2 (indx);
   END LOOP;

   DBMS_OUTPUT.put_line (DBMS_UTILITY.get_time - l_start_time);
END;
/

show errors

/* Inlining does not work with subprograms defined outside
   of the PL/SQL unit. */

CREATE OR REPLACE FUNCTION f1 (p NUMBER)
   RETURN PLS_INTEGER
   AUTHID DEFINER
IS
BEGIN
   RETURN p * 10;
END;
/

CREATE OR REPLACE FUNCTION f2 (p NUMBER)
   RETURN PLS_INTEGER
   AUTHID DEFINER
IS
BEGIN
   RETURN p * 10;
END;
/

create or replace procedure show_inlining
is
   l_start_time   PLS_INTEGER;
   l_end_time     PLS_INTEGER;
   n              NUMBER;
BEGIN
   l_start_time := DBMS_UTILITY.get_time;

   FOR indx IN 1 .. 10000000
   LOOP
      --PRAGMA INLINE (f1, 'YES');
      n := f1 (indx);
   END LOOP;

   DBMS_OUTPUT.put_line (DBMS_UTILITY.get_time - l_start_time);

   l_start_time := DBMS_UTILITY.get_time;

   FOR indx IN 1 .. 10000000
   LOOP
      n := f2 (indx);
   END LOOP;

   DBMS_OUTPUT.put_line (DBMS_UTILITY.get_time - l_start_time);
END;
/

show errors

/* Work when all are inside package, but not local? */

CREATE OR REPLACE PACKAGE pkg
   AUTHID DEFINER
IS
   FUNCTION f1 (p NUMBER)
      RETURN PLS_INTEGER;

   FUNCTION f2 (p NUMBER)
      RETURN PLS_INTEGER;

   PROCEDURE test_inlining;
END;
/

CREATE OR REPLACE PACKAGE BODY pkg
IS
   FUNCTION f1 (p NUMBER)
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN p * 10;
   END;

   FUNCTION f2 (p NUMBER)
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN p * 10;
   END;

   PROCEDURE test_inlining
   IS
      l_start_time   PLS_INTEGER;
      l_end_time     PLS_INTEGER;
      n              NUMBER;
   BEGIN
      l_start_time := DBMS_UTILITY.get_time;

      FOR indx IN 1 .. 10000000
      LOOP
      --PRAGMA INLINE (f1, 'YES');
         n := f1 (indx);
      END LOOP;

      DBMS_OUTPUT.put_line (
         DBMS_UTILITY.get_time - l_start_time);

      l_start_time := DBMS_UTILITY.get_time;

      FOR indx IN 1 .. 10000000
      LOOP
         n := f2 (indx);
      END LOOP;

      DBMS_OUTPUT.put_line (
         DBMS_UTILITY.get_time - l_start_time);
   END;
END;
/

show errors

BEGIN
   pkg.test_inlining;
END;
/