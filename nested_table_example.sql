/*
Demonstrates how to declare a schema-level nested table type, extend to make room for news and populate them,
use MULTISET operators to perform set level operations, and finally use the TABLE operator to fetch elements
from the nested table as though it were a relational table. Fun stuff!
*/

CREATE OR REPLACE TYPE list_of_names_t
   IS TABLE OF VARCHAR2 (100);
/

GRANT EXECUTE ON list_of_names_t TO PUBLIC
/

DECLARE
   happyfamily     list_of_names_t := list_of_names_t ();
   children        list_of_names_t := list_of_names_t ();
   grandchildren   list_of_names_t := list_of_names_t ();
   parents         list_of_names_t := list_of_names_t ();
BEGIN
   /* Can extend in "bulk" - 6 at once here */
   happyfamily.EXTEND (6);
   happyfamily (1) := 'Veva';
   happyfamily (2) := 'Chris';
   happyfamily (3) := 'Lauren';
   happyfamily (4) := 'Loey';
   happyfamily (5) := 'Eli';
   happyfamily (6) := 'Steven';
   
   /* Individual extends. */
   children.EXTEND;
   children (children.LAST) := 'Chris';
   children.EXTEND;
   children (children.LAST) := 'Eli';
   children.EXTEND;
   children (children.LAST) := 'Lauren';
   --
   grandchildren.EXTEND;
   grandchildren (grandchildren.LAST) := 'Loey';

   /* Multiset operators on nested tables */

   FOR l_row IN 1 .. parents.COUNT
   LOOP
      DBMS_OUTPUT.put_line (parents (l_row));
   END LOOP;
 
   happyfamily.delete;
   happyfamily.EXTEND (4);
   happyfamily (1) := 'Eli';
   happyfamily (2) := 'Steven';
   happyfamily (3) := 'Chris';
   happyfamily (4) := 'Veva';

   /* Use TABLE operator to apply SQL operations to
      a PL/SQL nested table */

   FOR rec IN (  SELECT COLUMN_VALUE family_name
                   FROM TABLE (happyfamily)
               ORDER BY family_name)
   LOOP
      DBMS_OUTPUT.put_line (rec.family_name);
   END LOOP;
END;
/


/* Using a nested table as a column type */

DROP TABLE family
/

CREATE OR REPLACE TYPE parent_names_t
   IS TABLE OF VARCHAR2 (100);
/

CREATE OR REPLACE TYPE child_names_t
   IS TABLE OF VARCHAR2 (100);
/

CREATE TABLE family
(
   surname          VARCHAR2 (1000)
 ,  parent_names     parent_names_t
 ,  children_names   child_names_t
)
NESTED TABLE children_names
   STORE AS parent_names_tbl -- (TABLESPACE USERS)
NESTED TABLE parent_names
   STORE AS children_names_tbl -- (TABLESPACE TEMP)
/

DECLARE
   parents    parent_names_t
                 := parent_names_t ('Steven', 'Veva');
   children   child_names_t
                 := child_names_t ('Chris', 'Eli');
BEGIN
   INSERT
     INTO family (surname, parent_names, children_names)
   VALUES ('Feuerstein', parents, children);

   COMMIT;
END;
/

SELECT * FROM family
/