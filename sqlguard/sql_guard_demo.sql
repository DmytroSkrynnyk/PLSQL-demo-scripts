DECLARE
   l_analyzed_sql   sql_guard.analyzed_sql_handle_t;
BEGIN
   l_analyzed_sql := sql_guard.analyzed_sql ('select * from my_table');
   DBMS_OUTPUT.put_line (sql_guard.safety_status (l_analyzed_sql));
   l_analyzed_sql :=
                   sql_guard.analyzed_sql ('employee_id = 15;drop table abc');
   DBMS_OUTPUT.put_line (sql_guard.safety_status (l_analyzed_sql));
END;
/

/* Without SQL_GUARD */

CREATE OR REPLACE PROCEDURE use_dynamic_sql (
   sql_handle_in   IN   sql_guard.analyzed_sql_handle_t
)
IS
BEGIN
   /* No protection, assume that everything is OK. */
   EXECUTE IMMEDIATE sql_guard.sql_text (sql_handle_in);
END use_dynamic_sql;
/

/* With SQL_GUARD */

CREATE OR REPLACE PROCEDURE use_dynamic_sql (
   sql_handle_in   IN   sql_guard.analyzed_sql_handle_t
)
IS
BEGIN
   /*
   Check to make sure this SQL statement is OK.
   If so, extract the text and execute it.
   */
   IF sql_guard.sql_is_safe (sql_handle_in)
   THEN
      EXECUTE IMMEDIATE sql_guard.sql_text (sql_handle_in);

      DBMS_OUTPUT.put_line ('Executed the following safe SQL statement:');
   ELSE
      DBMS_OUTPUT.put_line ('SQL statement is unsafe: ');
   END IF;

   DBMS_OUTPUT.put_line (sql_guard.sql_text (sql_handle_in));
END use_dynamic_sql;
/

DROP TABLE employees_temp
/
CREATE TABLE employees_temp AS SELECT * FROM employees
/

DECLARE
   l_analyzed_sql   sql_guard.analyzed_sql_handle_t;
   l_count          PLS_INTEGER;
BEGIN
   /*
   No problems with this one...
   */
   l_analyzed_sql :=
      sql_guard.analyzed_sql
                           ('update employees_temp set last_name =''Steven''');
   use_dynamic_sql (l_analyzed_sql);
   /*
   An unacceptable statement...
   */
   l_analyzed_sql := sql_guard.analyzed_sql ('Drop table employees_temp');
   use_dynamic_sql (l_analyzed_sql);

   SELECT COUNT (*)
     INTO l_count
     FROM employees_temp
    WHERE last_name <> 'Steven';

   DBMS_OUTPUT.put_line ('How many have last name NOT Steven? ' || l_count);
   ROLLBACK;
END;
/

BEGIN
   q$error_manager.trace_on;
   q$error_manager.toscreen;

   IF q$error_manager.trace_enabled
   THEN
      q$error_manager.TRACE ('prepare_test_list total tests', 'hello');
   END IF;

   sql_guard.add_test (test_string_in => 'STEVEN', apply_once_in => TRUE);
   DBMS_OUTPUT.put_line (sql_guard.sql_safety_level ('where steven 1=1'));
END;
/
