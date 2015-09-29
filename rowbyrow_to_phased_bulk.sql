-- Original

CREATE OR REPLACE PROCEDURE upd_for_dept (
   dept_in     IN employees.department_id%TYPE
 , newsal_in   IN employees.salary%TYPE)
IS
   CURSOR emp_cur
   IS
      SELECT employee_id, salary, hire_date
        FROM employees
       WHERE department_id = dept_in;
BEGIN
   FOR rec IN emp_cur
   LOOP
      BEGIN
         INSERT INTO employee_history (employee_id, salary, hire_date)
              VALUES (rec.employee_id, rec.salary, rec.hire_date);

         rec.salary := newsal_in;

         adjust_compensation (rec.employee_id, rec.salary);

         UPDATE employees
            SET salary = rec.salary
          WHERE employee_id = rec.employee_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            log_error;
      END;
   END LOOP;
END upd_for_dept;
/

-- Step 1: put some maintainability in place

CREATE OR REPLACE PROCEDURE upd_for_dept2 (
   dept_in   IN   employee.department_id%TYPE
 , newsal    IN   employee.salary%TYPE
 , bulk_limit_in   IN PLS_INTEGER DEFAULT 100)
IS
   at_least_one_forall_failure   EXCEPTION;
   PRAGMA EXCEPTION_INIT (at_least_one_forall_failure, -24381);

   CURSOR employees_cur
   IS
      SELECT employee_id, salary, hire_date
        FROM employees
       WHERE department_id = dept_in
      FOR UPDATE;

   TYPE employees_tt IS TABLE OF employees_cur%ROWTYPE
                           INDEX BY PLS_INTEGER;
                           
-- Step 2: Add collection based on cursor       

CREATE OR REPLACE PROCEDURE upd_for_dept2 (
   dept_in   IN   employee.department_id%TYPE
 , newsal    IN   employee.salary%TYPE
 , bulk_limit_in   IN PLS_INTEGER DEFAULT 100)
IS
   at_least_one_forall_failure   EXCEPTION;
   PRAGMA EXCEPTION_INIT (at_least_one_forall_failure, -24381);

   CURSOR employees_cur
   IS
      SELECT employee_id, salary, hire_date
        FROM employees
       WHERE department_id = dept_in
      FOR UPDATE;

   TYPE employees_tt IS TABLE OF employees_cur%ROWTYPE
                           INDEX BY PLS_INTEGER;
                           
   l_employees   employees_tt; 
   
-- Step 3: Top-down design, shift to "bottom" of procedure

BEGIN -- Main executable section
   OPEN employees_cur;

   LOOP
      -- Phase 1
      FETCH employees_cur
      BULK COLLECT INTO l_employees
      LIMIT bulk_limit_in;

      EXIT WHEN l_employees.COUNT = 0;

      -- Phase 3
      insert_history;
      -- Phase 2: prepare arrays 100% application specific.
      adj_comp_for_arrays;
      -- Phase 3
      update_employees;
   END LOOP;
END upd_for_dept;
/

-- Step 4: Build insert_history

   PROCEDURE insert_history
   IS
   BEGIN
      FORALL indx IN 1 .. l_employees.COUNT SAVE EXCEPTIONS
         INSERT
           INTO employee_history (employee_id
                                ,  salary
                                ,  hire_date)
         VALUES (
                   l_employees (indx).employee_id
                 ,  l_employees (indx).salary
                 ,  l_employees (indx).hire_date);
   EXCEPTION
      WHEN at_least_one_forall_failure
      THEN
         FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
         LOOP
            log_error (
                  'Unable to insert history row for employee '
               || l_employees (
                     SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX).employee_id
             ,  SQL%BULK_EXCEPTIONS (indx).ERROR_CODE);
            /*
            Communicate this failure to the update phase:
            Delete this row so that the update will not take place.
            */
            l_employees.delete (
               SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX);
         END LOOP;
   END insert_history;
BEGIN -- Main executable section   

-- Step 5: Build update_employees

   END insert_history;
   
   PROCEDURE update_employees
   IS
   BEGIN
      /*
        Use INDICES OF to avoid errors
        from a sparsely-populated employee_ids collection.
      */
      FORALL indx IN INDICES OF l_employees
        SAVE EXCEPTIONS
         UPDATE employees
            SET salary = l_employees (indx).salary
              ,  hire_date = l_employees (indx).hire_date
          WHERE employee_id =
                   l_employees (indx).employee_id;
   EXCEPTION
      WHEN at_least_one_forall_failure
      THEN
         FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
         LOOP
            log_error (
                  'Unable to update salary for employee '
               || l_employees (
                     SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX).employee_id
             ,  SQL%BULK_EXCEPTIONS (indx).ERROR_CODE);
         END LOOP;
   END update_employees;
BEGIN -- Main executable section  

-- Put it all together

/*
Take advantage of 11g ability to reference fields of records in FORALL.
*/

CREATE OR REPLACE PROCEDURE upd_for_dept (
   dept_in         IN employees.department_id%TYPE
 ,  newsal_in       IN employees.salary%TYPE
 ,  bulk_limit_in   IN PLS_INTEGER DEFAULT 100)
IS
   at_least_one_forall_failure   EXCEPTION;
   PRAGMA EXCEPTION_INIT (at_least_one_forall_failure, -24381);

   CURSOR employees_cur
   IS
      SELECT employee_id, salary, hire_date
        FROM employees
       WHERE department_id = dept_in
      FOR UPDATE;

   TYPE employees_tt IS TABLE OF employees_cur%ROWTYPE
                           INDEX BY PLS_INTEGER;

   l_employees   employees_tt;

   PROCEDURE adj_comp_for_arrays
   IS
      l_index   PLS_INTEGER;

      PROCEDURE adjust_compensation (
         id_in       IN INTEGER
       ,  salary_in   IN NUMBER)
      IS
      BEGIN
         NULL;
      END;
   BEGIN
      /* IFMC Nov 2008 Cannot go 1 to COUNT */
      l_index := l_employees.FIRST;

      WHILE (l_index IS NOT NULL)
      LOOP
         adjust_compensation (
            l_employees (l_index).employee_id
          ,  l_employees (l_index).salary);
         l_index := l_employees.NEXT (l_index);
      END LOOP;
   END adj_comp_for_arrays;

   PROCEDURE insert_history
   IS
   BEGIN
      FORALL indx IN 1 .. l_employees.COUNT SAVE EXCEPTIONS
         INSERT
           INTO employee_history (employee_id
                                ,  salary
                                ,  hire_date)
         VALUES (
                   l_employees (indx).employee_id
                 ,  l_employees (indx).salary
                 ,  l_employees (indx).hire_date);
   EXCEPTION
      WHEN at_least_one_forall_failure
      THEN
         FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
         LOOP
            -- Log the error
            log_error (
                  'Unable to insert history row for employee '
               || l_employees (
                     SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX).employee_id
             ,  SQL%BULK_EXCEPTIONS (indx).ERROR_CODE);
            /*
            Communicate this failure to the update phase:
            Delete this row so that the update will not take place.
            */
            l_employees.delete (
               SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX);
         END LOOP;
   END insert_history;

   PROCEDURE update_employees
   IS
   BEGIN
      FORALL indx IN INDICES OF l_employees
        SAVE EXCEPTIONS
         UPDATE employees
            SET salary = l_employees (indx).salary
              ,  hire_date = l_employees (indx).hire_date
          WHERE employee_id =
                   l_employees (indx).employee_id;
   EXCEPTION
      WHEN at_least_one_forall_failure
      THEN
         FOR indx IN 1 .. SQL%BULK_EXCEPTIONS.COUNT
         LOOP
            log_error (
                  'Unable to update salary for employee '
               || l_employees (
                     SQL%BULK_EXCEPTIONS (indx).ERROR_INDEX).employee_id
             ,  SQL%BULK_EXCEPTIONS (indx).ERROR_CODE);
         END LOOP;
   END update_employees;
BEGIN
   OPEN employees_cur;

   LOOP
      FETCH employees_cur
      BULK COLLECT INTO l_employees
      LIMIT bulk_limit_in;

      EXIT WHEN l_employees.COUNT = 0;

      insert_history;
      adj_comp_for_arrays;
      update_employees;
   END LOOP;
END upd_for_dept;
/
   