BEGIN

   FOR rec   IN
   (SELECT    *
      FROM employees
   )
   LOOP

      CASE
      WHEN rec.salary > 10000 THEN
         /* No change in salary */
         NULL;

      WHEN rec.salary > 1000 THEN

         UPDATE employees
            SET salary        = salary * 1.1
            WHERE employee_id = rec.employee_id;

      ELSE

         UPDATE employees
            SET salary        = salary * 1.25
            WHERE employee_id = rec.employee_id;

      END CASE;

   END LOOP;

END;
/

/* or ... */

UPDATE employees
   SET salary     = salary *
      CASE salary > 1000
         THEN 1.1
         ELSE 1.25
      END
   WHERE salary <= 10000