DECLARE
   TYPE employees_t IS TABLE OF employees%ROWTYPE;
   l_employees   employees_t;
   
   TYPE emps_by_name_t IS TABLE OF employees%ROWTYPE
      INDXEX BY employees.last_name%TYPE;
   l_emps_by_name emps_by_name_t;
BEGIN
     SELECT *
       BULK COLLECT INTO l_employees
       FROM employees
   ORDER BY last_name DESC;

   FOR indx IN 1 .. l_employees.COUNT
   LOOP
      l_emps_by_name (l_employees (indx).last_name)) := 
         l_employees (indx);
   END LOOP;
END;
/