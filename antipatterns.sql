/* Context switching reduction */

CREATE OR REPLACE FUNCTION plch_total_compensation (
   salary_in           IN NUMBER,
   commission_pct_in   IN NUMBER)
   RETURN NUMBER
IS
BEGIN
   RETURN NVL (commission_pct_in, 0) + salary_in;
END;
/

CREATE OR REPLACE FUNCTION plch_emp_comp (
   employee_id_in   IN INTEGER)
   RETURN NUMBER
IS
   l_return   NUMBER;
BEGIN
   SELECT plch_total_compensation (salary, commission_pct)
     INTO l_return
     FROM plch_employees;

   RETURN l_return;
END;
/

SELECT plch_emp_comp (employee_id) total_comp
  FROM plch_employees
/

-- Rewrite #1 - 0 context switches

SELECT NVL (commission_pct, 0) + salary total_comp
  FROM plch_employees
/

-- Rewrite #2 - reduced code in 12.1

CREATE OR REPLACE FUNCTION plch_total_compensation (
   salary_in           IN NUMBER,
   commission_pct_in   IN NUMBER)
   RETURN NUMBER
IS
   PRAGMA UDF;
BEGIN
   RETURN NVL (commission_pct_in, 0) + salary_in;
END;
/

SELECT plch_total_compensation (salary, commission_pct)
          total_comp
  FROM plch_employees
/

/* Creative use of indexing */

/* 1. Keep track of products already placed in order.
      Start with a dumb implementation, full of possible
      flaws. Rewrite using string indexed array. */

CREATE OR REPLACE PACKAGE plch_product_mgr
IS
   FUNCTION product_in_order (product_name_in IN VARCHAR2)
      RETURN BOOLEAN;

   PROCEDURE add_product_to_order (product_name_in IN VARCHAR2);
END;
/

CREATE OR REPLACE PACKAGE BODY string_tracker
IS
   g_list   VARCHAR2 (32767);

   FUNCTION product_in_order (product_name_in IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN INSTR (g_list, product_name_in) > 0;
   END;

   PROCEDURE add_product_to_order (product_name_in IN VARCHAR2)
   IS
   BEGIN
      g_list := g_list || ',' || product_name_in;
   END;
END;
/

/* Rewrite using string-indexed array */

CREATE OR REPLACE PACKAGE plch_product_mgr
IS
   FUNCTION product_in_order (product_name_in IN VARCHAR2)
      RETURN BOOLEAN;

   PROCEDURE add_product_to_order (product_name_in IN VARCHAR2);
END;
/

CREATE OR REPLACE PACKAGE BODY string_tracker
IS
   SUBTYPE product_name_t IS VARCHAR2 (100);

   TYPE list_t IS TABLE OF BOOLEAN
      INDEX BY product_name_t;

   g_list   list_t;

   FUNCTION product_in_order (product_name_in IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN g_list.EXISTS (product_name_in);
   END;

   PROCEDURE add_product_to_order (product_name_in IN VARCHAR2)
   IS
   BEGIN
      g_list (product_name_in) := NULL;
   END;
END;
/

/* We are caching the plch_employees table to enable us to access a row by
primary key very efficiently. But we also need to look up a row by
last_name. */

CREATE OR REPLACE PACKAGE plch_employee_mgr
IS
   FUNCTION onerow (
      employee_id_in   IN plch_employees.employee_id%TYPE)
      RETURN plch_employees%ROWTYPE;
END;
/

CREATE OR REPLACE PACKAGE BODY plch_employee_mgr
IS
   TYPE employee_tt IS TABLE OF plch_employees%ROWTYPE
      INDEX BY PLS_INTEGER;

   employee_cache   employee_tt;

   FUNCTION onerow (
      employee_id_in   IN plch_employees.employee_id%TYPE)
      RETURN plch_employees%ROWTYPE
   IS
   BEGIN
      RETURN employee_cache (employee_id_in);
   END onerow;
BEGIN
   FOR rec IN (SELECT e1.*
                 FROM plch_employees e1, plch_employees e2)
   LOOP
      employee_cache (rec.employee_id) := rec;
   END LOOP;
END;
/

/* New function in package spec. Write the body! */

CREATE OR REPLACE PACKAGE plch_employee_mgr
IS
   FUNCTION onerow (
      employee_id_in   IN plch_employees.employee_id%TYPE)
      RETURN plch_employees%ROWTYPE;

   FUNCTION onerow_by_name (
      last_name_in   IN plch_employees.last_name%TYPE)
      RETURN plch_employees%ROWTYPE;
END;
/

CREATE OR REPLACE PACKAGE BODY plch_employee_mgr
IS
   TYPE employees_tt IS TABLE OF plch_employees%ROWTYPE
      INDEX BY PLS_INTEGER;

   employee_cache      employees_tt;

   TYPE ids_tt IS TABLE OF plch_employees.employee_id%TYPE
      INDEX BY plch_employees.last_name%TYPE;

   ids_by_name_cache   ids_tt;

   FUNCTION onerow (
      employee_id_in   IN plch_employees.employee_id%TYPE)
      RETURN plch_employees%ROWTYPE
   IS
   BEGIN
      RETURN employee_cache (employee_id_in);
   END onerow;

   FUNCTION onerow_by_name (
      last_name_in   IN plch_employees.last_name%TYPE)
      RETURN plch_employees%ROWTYPE
   IS
   BEGIN
      RETURN employee_cache (ids_by_name_cache (last_name_in));
   END;
BEGIN
   FOR rec IN (SELECT e1.*
                 FROM plch_employees e1, plch_employees e2)
   LOOP
      employee_cache (rec.employee_id) := rec;
   END LOOP;
END;
/

/* NOT DONE

1. Long running job hits SNAPSHOT_TOO_OLD error. Fix it! */

CREATE OR REPLACE PROCEDURE plch_big_report
IS
BEGIN
   FOR rec IN (SELECT * FROM plch_report_driver)
   LOOP
      FOR rec IN (SELECT * FROM plch_employees)
      LOOP
         do_stuff1;
      END LOOP;

      do_more_stuff;

      FOR rec IN (SELECT * FROM plch_employees)
      LOOP
         do_stuff2;
      END LOOP;
   END LOOP;
END;
/

/*
I wrote this program several years ago to speed up retrievals of static data.
The problem is that the primary key is now approaching 2**31-1. Change the program
so that this problem is avoided and we still have improved performance of lookups.
*/

CREATE OR REPLACE PACKAGE plch_lookup
IS
   FUNCTION one_employee (
      employee_id_in   IN plch_employees.employee_id%TYPE)
      RETURN plch_employees%ROWTYPE;
END;
/

CREATE OR REPLACE PACKAGE BODY plch_lookup
IS
   TYPE employee_tt IS TABLE OF plch_employees%ROWTYPE
      INDEX BY PLS_INTEGER;

   l_employees   employee_tt;

   FUNCTION one_employee (
      employee_id_in   IN plch_employees.employee_id%TYPE)
      RETURN plch_employees%ROWTYPE
   IS
      l_employee   plch_employees%ROWTYPE;
   BEGIN
      IF l_employees.EXISTS (employee_id_in)
      THEN
         l_employee := l_employees (employee_id_in);
      ELSE
         SELECT *
           INTO l_employee
           FROM plch_employees
          WHERE employee_id = employee_id_in;

         l_employees (employee_id_in) := l_employee;
      END IF;

      RETURN l_employee;
   END;
BEGIN
   FOR rec IN (SELECT * FROM plch_employees)
   LOOP
      l_employees (rec.employee_id) := rec;
   END LOOP;
END;
/

/* Solution: change index type to VARCHAR2! */

CREATE OR REPLACE PACKAGE BODY plch_lookup
IS
   SUBTYPE id_as_string_t IS VARCHAR2 (20);

   TYPE employee_tt IS TABLE OF plch_employees%ROWTYPE
      INDEX BY id_as_string_t;

   l_employees   employee_tt;

   FUNCTION one_employee (
      employee_id_in   IN plch_employees.employee_id%TYPE)
      RETURN plch_employees%ROWTYPE
   IS
      l_employee   plch_employees%ROWTYPE;
   BEGIN
      IF l_employees.EXISTS (employee_id_in)
      THEN
         l_employee := l_employees (employee_id_in);
      ELSE
         SELECT *
           INTO l_employee
           FROM plch_employees
          WHERE employee_id = employee_id_in;

         l_employees (employee_id_in) := l_employee;
      END IF;

      RETURN l_employee;
   END;
BEGIN
   FOR rec IN (SELECT * FROM plch_employees)
   LOOP
      l_employees (rec.employee_id) := rec;
   END LOOP;
END;
/

/* Nested collections 

   Define a collection of departments and within each department element,
   all the employees.
   
   Not really anti-pattern, but a good exercise.
   
   Complete a package that contains an initialization section that
   populates a collection with all departments, and for each
   department the employees of that department.
*/

CREATE OR REPLACE PACKAGE plch_pkg
IS
   /* DECLARE */

   FUNCTION all_emps_in_dept (department_id IN INTEGER)
      RETURN employees_t;
END;
/

/* Solution */

CREATE OR REPLACE PACKAGE plch_pkg
IS
   TYPE employees_t IS TABLE OF plch_employees%ROWTYPE;

   TYPE dept_info IS RECORD
   (
      one_department       plch_departments%ROWTYPE,
      emps_in_department   employees_t
   );

   TYPE departments_t IS TABLE OF dept_info;

   FUNCTION all_emps_in_dept (department_id_in IN INTEGER)
      RETURN employees_t;
END;
/

CREATE OR REPLACE PACKAGE BODY plch_pkg
IS
   g_departments   departments_t;

   FUNCTION all_emps_in_dept (department_id_in IN INTEGER)
      RETURN employees_t
   IS
   BEGIN
      RETURN g_departments (department_id_in).emps_in_department;
   END;
BEGIN
   FOR drec IN (SELECT * FROM plch_departments)
   LOOP
      g_departments (drec.department_id).one_department := drec;

      SELECT *
        BULK COLLECT INTO g_departments (drec.department_id).emps_in_department
        FROM plch_employees
       WHERE department_id = drec.department_id;
   END LOOP;
END;
/

/* Nested table features 

* check for equality

*/

/* TABLE operator: we have lots of different views,
   all returning an integer and string. 

   We currently use a UNION with exclusion choice
   avoid writing lots of different reports. 
   
   Convert this to a table function (or do we just
   say that we currently have 25 reports, one for each view. 
   Get rid of them. COULD use a union....   
*/

CREATE OR REPLACE VIEW plch_view1
AS
   SELECT department_id, department_name FROM plch_departments
/

CREATE OR REPLACE VIEW plch_view2
AS
   SELECT employee_id, last_name FROM plch_employees
/

/* A UNION solution, sometimes OK */
SELECT *
  FROM plch_view1
 WHERE :user_choice = 'DEPARTMENT'
UNION
SELECT *
  FROM plch_view1
 WHERE :user_choice = 'EMPLOYEE'
/

/* And now the table function (ADVANCED!) */

CREATE OR REPLACE TYPE id_and_name_ot IS OBJECT
(
   the_id INTEGER,
   the_name VARCHAR2 (1000)
)
/

CREATE OR REPLACE TYPE ids_and_names_t
   IS TABLE OF id_and_name_ot
/

CREATE OR REPLACE FUNCTION plch_ids_and_names (
   type_in   IN VARCHAR2)
   RETURN ids_and_names_t
IS
   l_cursor   SYS_REFCURSOR;
   l_id       INTEGER;
   l_name     VARCHAR2 (1000);
   l_return   ids_and_names_t := ids_and_names_t ();
BEGIN
   OPEN l_cursor FOR
         'select * from plch_view'
      || CASE type_in
            WHEN 'DEPARTMENT' THEN '1'
            WHEN 'EMPLOYEE' THEN '2'
         END;

   LOOP
      FETCH l_cursor INTO l_id, l_name;

      EXIT WHEN l_cursor%NOTFOUND;
      l_return.EXTEND;
      l_return (l_return.LAST) := id_and_name_ot (l_id, l_name);
   END LOOP;

   RETURN l_return;
END;
/

SELECT * FROM TABLE (plch_ids_and_names ('DEPARTMENT'))
/

/*
1.    Optimizing SQL in PL/SQL

- SQL first, PL/SQL second
- Loops with DML

*/

/* Nested loops */

CREATE OR REPLACE PROCEDURE plch_lucky_employees (
   department_name_in   IN plch_departments.department_name%TYPE,
   last_name_like_in    IN VARCHAR2)
IS
BEGIN
   FOR drec IN (SELECT *
                  FROM plch_departments
                 WHERE department_name = department_name_in)
   LOOP
      FOR erec IN (  SELECT *
                       FROM plch_employees
                      WHERE department_id = drec.department_id
                   ORDER BY last_name)
      LOOP
         IF erec.last_name LIKE last_name_like_in
         THEN
            UPDATE plch_employees
               SET salary = salary * 2
             WHERE employee_id = erec.employee_id;
         END IF;
      END LOOP;
   END LOOP;
END;
/

-- rewrite 4203

CREATE OR REPLACE PROCEDURE plch_lucky_employees (
   department_name_in   IN plch_departments.department_name%TYPE,
   last_name_like_in    IN VARCHAR2)
IS
BEGIN
   UPDATE plch_employees
      SET salary = salary * 2
    WHERE     department_id =
                 (SELECT department_id
                    FROM plch_departments
                   WHERE department_name = department_name_in)
          AND last_name LIKE last_name_like_in;
END;
/

/* Logic in PL/SQL, should be in SQL */

CREATE OR REPLACE FUNCTION plch_senior_employee (
   employee_id_in   IN INTEGER)
   RETURN BOOLEAN
IS
   l_salary      plch_employees.salary%TYPE;
   l_hire_date   plch_employees.hire_date%TYPE;
BEGIN
   SELECT hire_date, salary
     INTO l_hire_date, l_salary
     FROM plch_employees
    WHERE employee_id = employee_id_in;

   RETURN     l_hire_date <= ADD_MONTHS (SYSDATE, -10 * 12)
          AND l_salary >= 10000;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      RETURN FALSE;
END;
/

-- rewrite 7950

CREATE OR REPLACE FUNCTION plch_senior_employee (
   employee_id_in   IN INTEGER)
   RETURN BOOLEAN
IS
   l_count   INTEGER;
BEGIN
   SELECT COUNT (*)
     INTO l_count
     FROM plch_employees
    WHERE     employee_id = employee_id_in
          AND hire_date <= ADD_MONTHS (SYSDATE, -10 * 12)
          AND salary >= 10000;

   RETURN l_count = 1;
END;
/

/* One two three function calls */

CREATE OR REPLACE FUNCTION plch_salary (
   employee_id_in   IN INTEGER)
   RETURN NUMBER
IS
   l_return   NUMBER;
BEGIN
   SELECT salary
     INTO l_return
     FROM plch_employees
    WHERE employee_id = employee_id_in;

   RETURN l_return;
END;
/

CREATE OR REPLACE FUNCTION plch_last_name (
   employee_id_in   IN INTEGER)
   RETURN VARCHAR2
IS
   l_return   plch_employees.last_name%TYPE;
BEGIN
   SELECT last_name
     INTO l_return
     FROM plch_employees
    WHERE employee_id = employee_id_in;

   RETURN l_return;
END;
/

CREATE OR REPLACE PROCEDURE plch_show_info (
   employee_id_in   IN INTEGER)
IS
   l_name     plch_employees.last_name%TYPE;
   l_salary   plch_employees.salary%TYPE;
BEGIN
   l_name := plch_last_name (employee_id_in);
   l_salary := plch_salary (employee_id_in);
   DBMS_OUTPUT.put_line (l_name || ' earns ' || l_salary);
END;
/

-- rewrite NNNNN

CREATE OR REPLACE PROCEDURE plch_show_info (
   employee_id_in   IN INTEGER)
IS
   l_name     plch_employees.last_name%TYPE;
   l_salary   plch_employees.salary%TYPE;
BEGIN
   SELECT last_name, salary
     INTO l_name, l_salary
     FROM plch_employees
    WHERE employee_id = employee_id_in;

   DBMS_OUTPUT.put_line (l_name || ' earns ' || l_salary);
END;
/

-- ? Drop functions?

/* BULK COLLECT anti-patterns */

DECLARE
   CURSOR emps_cur
   IS
      SELECT *
        FROM plch_employees
       WHERE department_id = 50;

   l_row   emps_cur%ROWTYPE;
BEGIN
   OPEN emps_cur;

   LOOP
      FETCH emps_cur INTO l_row;
      EXIT WHEN emps_cur%NOTFOUND;
      DBMS_OUTPUT.put_line (l_row.last_name);
   END LOOP;

   CLOSE emps_cur;
END;
/

-- Rewrite #1: cursor FOR loop!

BEGIN
   FOR l_row IN (SELECT *
                   FROM plch_employees
                  WHERE department_id = 50)
   LOOP
      DBMS_OUTPUT.put_line (l_row.last_name);
   END LOOP;
END;
/

-- Rewrite #2: BULK COLLECT it!

DECLARE
   TYPE emps_t IS TABLE OF plch_employees.last_name%TYPE;

   l_emps   emps_t;
BEGIN
   SELECT last_name
     BULK COLLECT INTO l_emps
     FROM plch_employees
    WHERE department_id = 50;

   FOR indx IN 1 .. l_emps.COUNT
   LOOP
      DBMS_OUTPUT.put_line (l_row.last_name);
   END LOOP;
END;
/

DECLARE
   CURSOR emps_cur
   IS
      SELECT *
        FROM plch_employees
       WHERE department_id = 50;

   TYPE emps_t IS TABLE OF emps_cur%ROWTYPE;

   l_emps   emps_t;
BEGIN
   OPEN emps_cur;

   FETCH emps_cur BULK COLLECT INTO l_emps;

   CLOSE emps_cur;

   FOR indx IN 1 .. l_emps.COUNT
   LOOP
      DBMS_OUTPUT.put_line (l_row.last_name);
   END LOOP;
END;
/

/* BULK COLLECT - limit clause */

CREATE OR REPLACE PROCEDURE plch_process_employees
IS
   TYPE emps_t IS TABLE OF plch_employees%ROWTYPE;

   l_emps   emps_t;

   PROCEDURE plch_do_stuff (emp_in IN emps_cur%ROWTYPE)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (
         emp_in.employee_id || '-' || emp_in.last_name);
   END;
BEGIN
   SELECT *
     BULK COLLECT INTO l_emps
     FROM plch_employees;

   FOR indx IN 1 .. l_emps.COUNT
   LOOP
      plch_do_stuff (l_emps (indx));
   END LOOP;
END;
/

-- Rewrite #1 - with HARD-CODED limit

DECLARE
   CURSOR emps_cur
   IS
      SELECT * FROM plch_employees;

   TYPE emps_t IS TABLE OF emps_cur%ROWTYPE;

   l_emps   emps_t;
BEGIN
   OPEN emps_cur;

   LOOP
      FETCH emps_cur BULK COLLECT INTO l_emps LIMIT 100;

      FOR indx IN 1 .. l_emps.COUNT
      LOOP
         plch_do_stuff (l_emps (indx));
      END LOOP;

      EXIT WHEN emps_cur%NOTFOUND;
   END LOOP;

   CLOSE emps_cur;
END;
/

-- Rewrite #2 - with SOFT-CODED limit

CREATE OR REPLACE PACKAGE plch_config
IS
   c_bulk_limit   CONSTANT PLS_INTEGER := 100;
END;
/

DECLARE
   CURSOR emps_cur
   IS
      SELECT * FROM plch_employees;

   TYPE emps_t IS TABLE OF emps_cur%ROWTYPE;

   l_emps   emps_t;
BEGIN
   OPEN emps_cur;

   LOOP
      FETCH emps_cur
         BULK COLLECT INTO l_emps
         LIMIT plch_pkg.c_bulk_limit;

      FOR indx IN 1 .. l_emps.COUNT
      LOOP
         plch_do_stuff (l_emps (indx));
      END LOOP;

      EXIT WHEN emps_cur%NOTFOUND;
   END LOOP;

   CLOSE emps_cur;
END;
/

/* FORALL */

/* Loop with single DML */

CREATE OR REPLACE PROCEDURE plch_upd_for_dept (
   dept_in     IN plch_employees.department_id%TYPE,
   newsal_in   IN plch_employees.salary%TYPE)
IS
   CURSOR emp_cur
   IS
      SELECT employee_id, salary
        FROM plch_employees
       WHERE department_id = dept_in;

   PROCEDURE adjust_salary (employee_id_in   IN     INTEGER,
                            salary_io        IN OUT NUMBER)
   IS
   BEGIN
      IF MOD (employee_id_in, 2) = 0
      THEN
         salary_io := salary_io / 2;
      ELSE
         salary_io := salary_io + 10;
      END IF;
   END;
BEGIN
   FOR rec IN emp_cur
   LOOP
      rec.salary := GREATEST (rec.salary, newsal_in);
      adjust_salary (rec.employee_id, rec.salary);

      UPDATE plch_employees
         SET salary = rec.salary
       WHERE employee_id = rec.employee_id;
   END LOOP;
END;
/

/* FORALL with some errors. make sure all statements are 
   executed and display all error information. */

CREATE OR REPLACE PACKAGE plch_pkg
IS
   TYPE ids_t IS TABLE OF INTEGER;

   g_ids   ids_t
              := ids_t (105,
                        100,
                        114,
                        115);
END;
/

CREATE OR REPLACE PROCEDURE plch_update (
   ids_in   IN plch_pkg.ids_t)
IS
BEGIN
   FORALL indx IN 1 .. ids_in.COUNT
      UPDATE plch_employees
         SET salary = salary * 100
       WHERE employee_id = ids_in (indx);
END;
/

/* FORALL with gaps */

CREATE OR REPLACE PACKAGE plch_pkg
IS
   TYPE names_t IS TABLE OF plch_employees.last_name%TYPE
      INDEX BY PLS_INTEGER;
END;
/

CREATE OR REPLACE PROCEDURE plch_update (
   names_in   IN plch_pkg.names_t)
IS
BEGIN
   FORALL indx IN 1 .. names_in.COUNT
      UPDATE plch_employees
         SET salary = salary * 1.10
       WHERE last_name = names_in (indx);
END;
/

DECLARE
   l_names   plch_pkg.names_t;
BEGIN
   FOR rec
      IN (SELECT employee_id, last_name FROM plch_employees)
   LOOP
      l_names (rec.employee_id) := rec.last_name;
   END LOOP;

   plch_upd_for_dept (l_names);
END;
/

/* Gaps with a "driver" array - ADVANCED */

CREATE OR REPLACE PACKAGE plch_pkg
IS
   TYPE ids_by_name_t
      IS TABLE OF plch_employees.employee_id%TYPE
      INDEX BY plch_employees.last_name%TYPE;

   TYPE employees_t IS TABLE OF plch_employees%ROWTYPE
      INDEX BY PLS_INTEGER;
END;
/

CREATE OR REPLACE PROCEDURE plch_update (
   employees_in     IN plch_pkg.employees_t,
   ids_by_name_in   IN plch_pkg.ids_by_name_t)
IS
   l_index   PLS_INTEGER := ids_by_name_in.FIRST;
BEGIN
   WHILE l_index IS NOT NULL
   LOOP
      UPDATE plch_employees
         SET row = employees_in (l_index)
       WHERE employee_id = ids_by_name_in (l_index);

      l_index := ids_by_name_in.NEXT (l_index);
   END LOOP;
END;
/

DECLARE
   l_employees     plch_pkg.employees_t;
   l_ids_by_name   plch_pkg.ids_by_name_t;
BEGIN
   FOR rec IN (SELECT * FROM plch_employees)
   LOOP
      l_employees (l_employees.COUNT + 1) := rec;
   END LOOP;

   FOR rec IN (SELECT *
                 FROM plch_employees
                WHERE department_id = 50)
   LOOP
      l_ids_by_name (rec.last_name) := rec.employee_id;
   END LOOP;
END;
/

/* Convert to FOARLL with INDICES OF */

CREATE OR REPLACE PROCEDURE plch_update (
   employees_in     IN plch_pkg.employees_t,
   ids_by_name_in   IN plch_pkg.ids_by_name_t)
IS
   l_index   PLS_INTEGER := ids_by_name_in.FIRST;
BEGIN
   FORALL l_index IN INDICES OF z
      UPDATE plch_employees
         SET row = employees_in (l_index)
       WHERE employee_id = ids_by_name_in (indx);
END;
/

/* FORALL with two DML statements */

/*
2. Caching data

- PGA
- FRC
- Deterministic

*/

/*
3. Hard-coding/Repetition

- Literal
- Declaration
- Formula
*/
CREATE OR REPLACE FUNCTION plch_get_hiredate (
   employee_id_in   IN PLS_INTEGER)
   RETURN plch_employees%ROWTYPE
IS
   hire_date   plch_employees%ROWTYPE;
BEGIN
   SELECT *
     INTO hire_date
     FROM plch_employees
    WHERE employee_id = employee_id_in;

   IF hire_date.hire_date < ADD_MONTHS (SYSDATE, -10 * 12)
   THEN
      UPDATE plch_employees
         SET salary = salary * 1.25
       WHERE employee_id = employee_id_in;
   END IF;

   RETURN hire_date;
END;
/

/* Two examples of usage of this function */

CREATE OR REPLACE PROCEDURE plch_give_bonuses_to_everyone
IS
   l_employee   plch_employees%ROWTYPE;
BEGIN
   FOR rec IN (SELECT employee_id FROM plch_employees)
   LOOP
      l_employee := plch_get_hiredate (rec.employee_id);

      DBMS_OUTPUT.put_line (
            'Longtime employee '
         || l_employee.last_name
         || ' given 25% raise!');
   END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE plch_employee_action (
   employee_id_in   IN PLS_INTEGER)
IS
   l_employee   plch_employees%ROWTYPE;
BEGIN
   l_employee := plch_get_hiredate (employee_id_in);

   IF l_employee.hire_date <= ADD_MONTHS (SYSDATE, -10 * 12)
   THEN
      DBMS_OUTPUT.put_line (
            'Longtime employee '
         || l_employee.last_name
         || ' given 25% raise!');
   END IF;
END;
/