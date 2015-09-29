/* 

ORA-06502: PL/SQL: numeric or value errorstring

Cause: An arithmetic, numeric, string, conversion, or constraint error occurred. 
       For example, this error occurs if an attempt is made to assign the value 
       NULL to a variable declared NOT NULL, or if an attempt is made to assign 
       an integer larger than 99 to a variable declared NUMBER(2).
       
Action: Change the data, how it is manipulated, or how it is declared so that 
        values do not violate constraints.

http://docs.oracle.com/database/121/ERRMG/toc.htm

*/

/* Classic example */

DECLARE
   l_string VARCHAR2(5);
BEGIN
   l_string := '123456';
END;
/

/* Trap error by name */

DECLARE
   l_string VARCHAR2(5);
BEGIN
   l_string := '123456';
EXCEPTION
   WHEN VALUE_ERROR
   THEN
      DBMS_OUTPUT.PUT_LINE (
         DBMS_UTILITY.FORMAT_ERROR_STACK);
END;
/

/* Number 10 as a string has length of 2. No problem! */

DECLARE
   l_number NUMBER := 10;
   l_string VARCHAR2(5);
BEGIN
   l_string := l_number;
END;
/

/* Six significant digits */

DECLARE
   l_number NUMBER := 100000;
   l_string VARCHAR2(5);
BEGIN
   l_string := l_number;
END;
/

DECLARE
   l_string VARCHAR2(5) := 'ABC';
   l_number NUMBER := 100000;
BEGIN
   l_number := l_string;
END;
/

/* From SQL to PL/SQL, same issue */

DECLARE
   l_string VARCHAR2(5) := 'ABC';
   l_number NUMBER := 100000;
BEGIN
   SELECT '1234546' INTO l_string
     FROM dual;
END;
/

/* Assign NULL to NOT NULL - "plain vanilla" message */

DECLARE
   l_number NUMBER;
   l_string VARCHAR2(5) NOT NULL := 'abc';
BEGIN
   l_string := l_number;
END;
/

/* Sometimes it is less clear what is causing the problem,
   as when data values are in table */
   
DECLARE
   l_string VARCHAR2(15) ;
BEGIN
   SELECT last_name || ',' || first_name
     INTO l_string
     FROM employees WHERE employee_id = 201;
END;
/

/* Look for constrained declarations or incorrectly typed
   declarations */
   
DECLARE
   l_string employees.last_name%TYPE;
BEGIN
   SELECT last_name || ',' || first_name
     INTO l_string
     FROM employees WHERE employee_id = 201;
END;
/

/* Use warnings to flag some occurrences of 6502. */

ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL'
/

CREATE OR REPLACE PROCEDURE show_6502
IS
   l_string VARCHAR2(5);
BEGIN
   l_string := 'abcdefg';
END;
/

/* Warning(5,4): PLW-06017: an operation will raise an exception */



