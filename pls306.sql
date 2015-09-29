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