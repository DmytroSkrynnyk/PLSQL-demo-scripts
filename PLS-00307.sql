/* 

http://docs.oracle.com/database/121/ERRMG/toc.htm

PLS-00307: too many declarations of 'string' match this call

Cause: The declaration of a subprogram or cursor name is ambiguous because there was no exact match 
between the declaration and the call and more than one declaration matched the call when implicit 
conversions of the parameter datatypes were used. The subprogram or cursor name might be misspelled, 
its declaration might be faulty, or the declaration might be placed incorrectly in the block structure.

Action: Check the spelling and declaration of the subprogram or cursor name. Also confirm that its call 
is correct, its parameters are of the right datatype, and, if it is not a built-in function, 
that its declaration is placed correctly in the block structure.

ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL'
/

*/

ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL';

/* Overloading different by parameter name only */

CREATE OR REPLACE PACKAGE salespkg
IS
   PROCEDURE calc_total (zone_in IN VARCHAR2);

   PROCEDURE calc_total (reg_in IN VARCHAR2);
END salespkg; 
/

CREATE OR REPLACE PACKAGE BODY salespkg
IS
   PROCEDURE calc_total (zone_in IN VARCHAR2)
   IS
   BEGIN 
      DBMS_OUTPUT.PUT_LINE ('zone'); 
   END;

   PROCEDURE calc_total (reg_in IN VARCHAR2)
   IS
   BEGIN 
      DBMS_OUTPUT.PUT_LINE ('region'); 
   END;
END salespkg; 
/

BEGIN
   salespkg.calc_total ('zone15');
END;
/

BEGIN
   salespkg.calc_total (zone_in => 'zone15');
END;
/

/* It compiles but.... */

CREATE OR REPLACE PACKAGE salespkg
IS
   PROCEDURE calc_total (reg_in IN CHAR);

   PROCEDURE calc_total (reg_in IN VARCHAR2);

END salespkg; 
/

CREATE OR REPLACE PACKAGE BODY salespkg
IS
   PROCEDURE calc_total (reg_in IN CHAR)
   IS
   BEGIN 
      DBMS_OUTPUT.PUT_LINE ('zone'); 
   END;

   PROCEDURE calc_total (reg_in IN VARCHAR2)
   IS
   BEGIN 
      DBMS_OUTPUT.PUT_LINE ('region'); 
   END;
END salespkg; 
/   

/* No way to call it! */

BEGIN
   salespkg.calc_total ('reg11');
END;
/

BEGIN
   salespkg.calc_total (reg_in => 'reg11');
END;
/

DECLARE
   l_char   CHAR (2) := 'ab';
BEGIN
   salespkg.calc_total (reg_in => l_char);
END;
/

CREATE OR REPLACE PACKAGE salespkg
IS
   PROCEDURE calc_total (
      zone_in IN CHAR, date_in in DATE DEFAULT SYSDATE);

   PROCEDURE calc_total (zone_in IN VARCHAR2);

END salespkg; 
/

CREATE OR REPLACE PACKAGE BODY salespkg
IS
   PROCEDURE calc_total (
      zone_in IN CHAR, date_in in DATE DEFAULT SYSDATE)
   IS
   BEGIN 
      DBMS_OUTPUT.PUT_LINE ('zone'); 
   END;

   PROCEDURE calc_total (zone_in IN VARCHAR2)
   IS
   BEGIN 
      DBMS_OUTPUT.PUT_LINE ('region'); 
   END;
END salespkg; 
/  

BEGIN
   salespkg.calc_total ('reg11');
END;
/ 

BEGIN
   salespkg.calc_total ('reg11', sysdate);
END;
/ 

/* No match at all */

BEGIN
   DBMS_OUTPUT.PUT_LINE (salespkg.calc_total ('reg11', sysdate));
END;
/ 

