CREATE TABLE plch_failures
      (
         n NUMBER (3)
      )
/
BEGIN sf_timer.start_timer;

FOR indx IN 1 .. 100000
LOOP
   BEGIN

      INSERT
         INTO plch_failures VALUES
            (
               1000
            );

   EXCEPTION

   WHEN OTHERS THEN
      NULL;

   END;

END LOOP;
sf_timer.show_elapsed_time ('Row by row inserted='||sql%rowcount);

END;
/

CREATE OR REPLACE PACKAGE plch_pkg
IS
TYPE t
IS
   TABLE OF NUMBER INDEX BY PLS_INTEGER;

END;
/

DECLARE
   tt plch_pkg.t;
BEGIN

   FOR indx IN 1 .. 100000
   LOOP
      tt
      (
         indx
      )
      := 1000;

   END LOOP;
   sf_timer.start_timer;
   BEGIN
      FORALL indx IN 1 .. 100000 SAVE EXCEPTIONS

      INSERT
         INTO plch_failures VALUES
            (
               tt (indx)
            );

   EXCEPTION

   WHEN OTHERS THEN
      sf_timer.show_elapsed_time ('Bulk inserted='||sql%rowcount);

   END;

END;
/

DROP TABLE plch_failures 
/