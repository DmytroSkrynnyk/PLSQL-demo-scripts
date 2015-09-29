/* Insist on clean compilation */

alter session set Plsql_Warnings = 'Error:All'
/

ALTER SESSION SET plsql_code_type = 'INTERPRETED'
/

CREATE OR REPLACE PROCEDURE testit AUTHID DEFINER
IS
   l_start pls_integer;
   si   SIMPLE_INTEGER := 1;
   pi   PLS_INTEGER := 1;
BEGIN
   l_start := DBMS_UTILITY.get_cpu_time;

   FOR i IN 1 .. 10000000
   LOOP
      si := si + si;
   END LOOP;

   DBMS_OUTPUT.put_line (
         'simple_integer-'
      || TO_CHAR (DBMS_UTILITY.get_cpu_time - l_start));

   l_start := DBMS_UTILITY.get_cpu_time;

   FOR i IN 1 .. 10000000
   LOOP
      pi := pi + pi;
   END LOOP;

   DBMS_OUTPUT.put_line (
         'pls_integer-'
      || TO_CHAR (DBMS_UTILITY.get_cpu_time - l_start));
END;
/

exec testit

ALTER SESSION SET plsql_code_type = 'NATIVE'
/

ALTER PROCEDURE testit COMPILE
/

exec testit