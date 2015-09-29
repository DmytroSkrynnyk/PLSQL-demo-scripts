/*

Which choices show:

Carrera
Corvette

*/

CREATE TABLE plch_trees
(
   species_name   VARCHAR2 (100),
   tree_type   VARCHAR2 (100)
)
/

BEGIN
   INSERT INTO plch_trees
        VALUES ('Oak', 'Deciduous');

   INSERT INTO plch_trees
        VALUES ('Peltogyne', 'Deciduous');

   INSERT INTO plch_trees
           VALUES ('Pine', 'Conifer');

   COMMIT;
END;
/

/* New RETURN_RESULT procedure in 12c -
   SQL*Plus handles the output automatically. */

CREATE OR REPLACE PROCEDURE plch_show_trees (
   tree_type_in   IN plch_trees.tree_type%TYPE)
IS
   l_cursor   SYS_REFCURSOR;
BEGIN
   OPEN l_cursor FOR
        SELECT species_name
          FROM plch_trees
         WHERE tree_type = tree_type_in
      ORDER BY species_name;

   DBMS_SQL.return_result (l_cursor);
END;
/

BEGIN
   plch_show_trees ('Deciduous');
END;
/

/* Pre 12c, had to write code to display results. */

CREATE OR REPLACE PROCEDURE plch_show_trees (
   tree_type_in   IN plch_trees.tree_type%TYPE)
IS
BEGIN
   FOR rec IN (  SELECT species_name
                   FROM plch_trees
                  WHERE tree_type = tree_type_in
               ORDER BY species_name)
   LOOP
      DBMS_OUTPUT.put_line (rec.species_name);
   END LOOP;
END;
/

BEGIN
   plch_show_trees ('Deciduous');
END;
/

/* Straight SQL */

  SELECT species_name
    FROM plch_trees
   WHERE tree_type = 'Deciduous'
ORDER BY species_name
/

/* Clean up */

DROP PROCEDURE plch_show_trees
/

DROP TABLE plch_trees
/