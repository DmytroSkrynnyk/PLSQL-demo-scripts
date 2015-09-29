CREATE TABLE plch_employees
(
   employee_id   INTEGER,
   last_name     VARCHAR2 (100),
   salary        NUMBER (8, 0)
)
/

BEGIN
   INSERT INTO plch_employees
        VALUES (100, 'Ninhursag ', 1000000);

   INSERT INTO plch_employees
        VALUES (200, 'Inanna', 1000000);

   INSERT INTO plch_employees
        VALUES (300, 'Enlil', 1000000);

   COMMIT;
END;
/

/* Indices of and sparse array */

DECLARE
   failure_in_forall   EXCEPTION;
   PRAGMA EXCEPTION_INIT (failure_in_forall, -24381);

   TYPE employee_aat IS TABLE OF employees.employee_id%TYPE
      INDEX BY PLS_INTEGER;

   l_employees         employee_aat;
BEGIN
   l_employees (1) := 100;
   l_employees (100) := 200;
   l_employees (500) := 300;

   FORALL l_index IN INDICES OF l_employees SAVE EXCEPTIONS
      UPDATE plch_employees
         SET salary =
                  salary
                * CASE employee_id WHEN 200 THEN 1 ELSE 100 END
       WHERE employee_id = l_employees (l_index);
EXCEPTION
   WHEN failure_in_forall
   THEN
      DBMS_OUTPUT.put_line ('Errors:');

      FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
      LOOP
         DBMS_OUTPUT.put_line (
            SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX);
      END LOOP;

      ROLLBACK;
END;
/

/* Indices of and dense array */

DECLARE
   failure_in_forall   EXCEPTION;
   PRAGMA EXCEPTION_INIT (failure_in_forall, -24381);

   TYPE employee_aat IS TABLE OF employees.employee_id%TYPE
      INDEX BY PLS_INTEGER;

   l_employees         employee_aat;
BEGIN
   l_employees (1) := 100;
   l_employees (2) := 200;
   l_employees (3) := 300;

   FORALL l_index IN INDICES OF l_employees SAVE EXCEPTIONS
      UPDATE plch_employees
         SET salary =
                  salary
                * CASE employee_id WHEN 200 THEN 1 ELSE 100 END
       WHERE employee_id = l_employees (l_index);
EXCEPTION
   WHEN failure_in_forall
   THEN
      DBMS_OUTPUT.put_line ('Errors:');

      FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
      LOOP
         DBMS_OUTPUT.put_line (
            SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX);
      END LOOP;

      ROLLBACK;
END;
/

/* No indices of */

DECLARE
   failure_in_forall   EXCEPTION;
   PRAGMA EXCEPTION_INIT (failure_in_forall, -24381);

   TYPE employee_aat IS TABLE OF employees.employee_id%TYPE
      INDEX BY PLS_INTEGER;

   l_employees         employee_aat;
BEGIN
   l_employees (1) := 100;
   l_employees (2) := 200;
   l_employees (3) := 300;

   FORALL l_index IN 1 .. l_employees.COUNT SAVE EXCEPTIONS
      UPDATE plch_employees
         SET salary =
                  salary
                * CASE employee_id WHEN 200 THEN 1 ELSE 100 END
       WHERE employee_id = l_employees (l_index);
EXCEPTION
   WHEN failure_in_forall
   THEN
      DBMS_OUTPUT.put_line ('Errors:');

      FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
      LOOP
         DBMS_OUTPUT.put_line (
            SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX);
      END LOOP;

      ROLLBACK;
END;
/

/* Indices of and dense array with between*/

DECLARE
   failure_in_forall   EXCEPTION;
   PRAGMA EXCEPTION_INIT (failure_in_forall, -24381);

   TYPE employee_aat IS TABLE OF employees.employee_id%TYPE
      INDEX BY PLS_INTEGER;

   l_employees         employee_aat;
BEGIN
   l_employees (1) := 100;
   l_employees (2) := 200;
   l_employees (3) := 300;
   l_employees (4) := 200;
   l_employees (5) := 100;

   FORALL l_index IN INDICES OF l_employees BETWEEN 3 AND 5
     SAVE EXCEPTIONS
      UPDATE plch_employees
         SET salary =
                  salary
                * CASE employee_id WHEN 200 THEN 1 ELSE 100 END
       WHERE employee_id = l_employees (l_index);
EXCEPTION
   WHEN failure_in_forall
   THEN
      DBMS_OUTPUT.put_line ('Errors:');

      FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
      LOOP
         DBMS_OUTPUT.put_line (
            SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX);
      END LOOP;

      ROLLBACK;
END;
/

/* Clean up */

DROP TABLE plch_employees
/