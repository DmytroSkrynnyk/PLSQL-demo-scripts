-- Demonstrate update of VARRAY using TABLE operator.

DROP TYPE names_t FORCE
/
DROP TABLE family
/

CREATE OR REPLACE TYPE names_t IS TABLE OF VARCHAR2 ( 100 );
/

CREATE TABLE family (
   surname VARCHAR2(1000)
 , parent_names names_t
 , children_names names_t
) NESTED TABLE parent_names STORE AS nested_parent_names
  NESTED TABLE children_names STORE AS nested_children_names
/

DECLARE
   parents names_t := names_t ( );
   children names_t := names_t ( );
BEGIN
   parents.EXTEND ( 2 );
   parents ( 1 ) := 'Samuel';
   parents ( 2 ) := 'Charina';
   --
   children.EXTEND ( 3 );
   children ( 1 ) := 'Feather';
   children ( 2 ) := 'Sam';
   children ( 3 ) := 'Hanu';

   --
   INSERT INTO family
               ( surname, parent_names, children_names
               )
        VALUES ( 'Assurty', parents, children
               );

   UPDATE TABLE ( SELECT children_names
                    FROM family
                   WHERE surname = 'Assurty' )
      SET COLUMN_VALUE = 'Joshua'
    WHERE COLUMN_VALUE = 'Hanu';
END;
/

SELECT *
  FROM family
/
