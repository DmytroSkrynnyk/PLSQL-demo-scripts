/* Error messages manual, good starting point 

http://docs.oracle.com/database/121/ERRMG/toc.htm

PLS-00306: wrong number or types of arguments in call to 'string'

Cause: This error occurs when the named subprogram call cannot be matched 
to any declaration for that subprogram name. The subprogram name might be misspelled, 
a parameter might have the wrong datatype, the declaration might be faulty, 
or the declaration might be placed incorrectly in the block structure. 
For example, this error occurs if the built-in square root function SQRT is 
called with a misspelled name or with a parameter of the wrong datatype.

Action: Check the spelling and declaration of the subprogram name. Also confirm 
that its call is correct, its parameters are of the right datatype, and, if it 
is not a built-in function, that its declaration is placed correctly in the block structure.

*/


CREATE OR REPLACE PACKAGE salespkg
IS
   PROCEDURE calc_total (zone IN VARCHAR2);

   PROCEDURE calc_total (reg_in IN VARCHAR2);
   
   FUNCTION calc_total (zone_in in VARCHAR2) RETURN NUMBER;

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
   
   FUNCTION calc_total (zone_in in VARCHAR2) RETURN NUMBER
   IS
   BEGIN
      RETURN 0;
   END;
END salespkg; 
/

/* Cannot convert Boolean to....anything else */

BEGIN
   salespkg.calc_total (TRUE);
END;
/

/* Wrong number of arguments passed to subprogram */

BEGIN
   salespkg.calc_total (sysdate, sysdate);
END;
/

/* No match on parameter name - especially hard to see
   in a long list of parameters. */

BEGIN
   salespkg.calc_total (zone => 'ABC');
END;
/

/* Calling proc version where func is needed */

BEGIN
   DBMS_OUTPUT.PUT_LINE (
      salespkg.calc_total (reg_in => 'zone15'));
END;
/

/* Wait a minute, that's a record! */

BEGIN
   FOR employee IN (SELECT * FROM employees)
   LOOP
      DBMS_OUTPUT.PUT_LINE (employee.last_name);
   END LOOP;
END;
/

/* Concatenation is a function too! 

   PLS-00306: wrong number or types of arguments in call to '||'
*/

BEGIN
   FOR employee IN (SELECT * FROM employees)
   LOOP
      DBMS_OUTPUT.PUT_LINE ('Name = ' || employee);
   END LOOP;
END;
/