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

ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL'
/

*/

/* Mis-match on "same" type in different schemas */

CONNECT schema1/schema1

CREATE OR REPLACE TYPE number_nt IS TABLE OF NUMBER
/

CREATE OR REPLACE PROCEDURE show_nt_count (n IN number_nt)
IS
BEGIN
   DBMS_OUTPUT.put_line (n.COUNT);
END;
/

GRANT EXECUTE ON show_nt_count TO schema2
/

GRANT EXECUTE ON number_nt TO schema2
/

CONNECT schema2/schema2

/* This works */

DECLARE
   n   schema1.number_nt := schema1.number_nt (1);
BEGIN
   schema1.show_nt_count (n);
END;
/

/* Now create the "same" type in schema2 */

CREATE OR REPLACE TYPE number_nt IS TABLE OF NUMBER
/

/* This will FAIL with:

   PLS-00306: wrong number or types of arguments in call to 'SHOW_NT_COUNT'
*/

DECLARE
   n   number_nt := number_nt (1);
BEGIN
   schema1.show_nt_count (n);
END;
/

/* Now with built-in types */

CONNECT schema1/schema1

CREATE OR REPLACE PROCEDURE show_nt_count (n IN DBMS_SQL.number_table)
IS
BEGIN
   DBMS_OUTPUT.put_line (n.COUNT);
END;
/

GRANT EXECUTE ON show_nt_count TO schema2
/

CONNECT schema2/schema2

DECLARE
   n   DBMS_SQL.number_table;
BEGIN
   n(1) := 1;
   schema1.show_nt_count (n);
END;
/