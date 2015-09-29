CREATE OR REPLACE PROCEDURE test_emplu (
   counter          IN   PLS_INTEGER
 , employee_id_in   IN   employees.employee_id%TYPE := 138
 , run_query_in     IN   BOOLEAN DEFAULT TRUE
)
IS
   emprec   employees%ROWTYPE;
BEGIN
   sf_timer.start_timer;

   FOR i IN 1 .. counter
   LOOP
      emprec := emplu2.onerow (employee_id_in);
   END LOOP;

   sf_timer.show_elapsed_time ('associative array caching');

   --
   sf_timer.start_timer;

   FOR i IN 1 .. counter
   LOOP
      emprec := emplu2.onerow_incremental (employee_id_in);
   END LOOP;

   sf_timer.show_elapsed_time ('JIT index-by table');
   --
   IF run_query_in
   THEN
      sf_timer.start_timer;

      FOR i IN 1 .. counter
      LOOP
         emprec := emplu1.onerow (employee_id_in);
      END LOOP;

      sf_timer.show_elapsed_time ('database table lookup');
   END IF;
END;
/