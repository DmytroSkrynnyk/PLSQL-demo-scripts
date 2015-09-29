CREATE TABLE plch_data (n NUMBER);

CREATE OR REPLACE TYPE numbers_t IS TABLE OF NUMBER;
/

CREATE OR REPLACE FUNCTION my_list_tf
   RETURN numbers_t AUTHID DEFINER
IS
   ns   numbers_t := numbers_t ();
BEGIN
   ns.EXTEND (1000000);

   FOR indx IN 1 .. 1000000
   LOOP
      ns (indx) := indx;
   END LOOP;

   RETURN ns;
END;
/

CREATE OR REPLACE FUNCTION my_list_ptf
   RETURN numbers_t
   PIPELINED AUTHID DEFINER
IS
BEGIN
   FOR indx IN 1 .. 1000000
   LOOP
      PIPE ROW (indx);
   END LOOP;
END;
/

SET TIMING ON

DECLARE
   l_count   INTEGER;
   l_start   PLS_INTEGER;

   PROCEDURE mark_start
   IS
   BEGIN
      l_start := DBMS_UTILITY.get_cpu_time;
   END mark_start;

   PROCEDURE show_elapsed (NAME_IN IN VARCHAR2)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (
            '"'
         || NAME_IN
         || '" elapsed CPU time: '
         || TO_CHAR (DBMS_UTILITY.get_cpu_time - l_start)
         || ' centiseconds');
      mark_start;
   END show_elapsed;
BEGIN
   INSERT INTO plch_data VALUES (1);

   COMMIT;
   
   mark_start;

   SELECT COUNT (*)
     INTO l_count
     FROM plch_data
    WHERE n IN (SELECT * FROM TABLE (my_list_tf));

   show_elapsed ('TF match on first');

   SELECT COUNT (*)
     INTO l_count
     FROM plch_data
    WHERE n IN (SELECT * FROM TABLE (my_list_ptf));

   show_elapsed ('PTF match on first');

   UPDATE plch_data
      SET n = 1000000;

   SELECT COUNT (*)
     INTO l_count
     FROM plch_data
    WHERE n IN (SELECT * FROM TABLE (my_list_tf));

   show_elapsed ('TF match on last');

   SELECT COUNT (*)
     INTO l_count
     FROM plch_data
    WHERE n IN (SELECT * FROM TABLE (my_list_ptf));

   show_elapsed ('PTF match on last');
END;
/

DROP TYPE numbers_t
/

DROP TABLE plch_data
/

DROP FUNCTION my_list_tf
/

DROP FUNCTION my_list_ptf
/