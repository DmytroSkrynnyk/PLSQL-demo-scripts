DROP TABLE sql_guard_tests
/
DROP TABLE sql_guard_drivers
/
/*
Table that contains other tests the user wants to run
to check for SQL injection.

Example:

INSERT INTO sql_guard_tests VALUES (
   'LIKE', '%1=1%');
*/

CREATE TABLE sql_guard_tests (
   NAME VARCHAR2(100) UNIQUE NOT NULL,
   OPERATOR VARCHAR2(100) NOT NULL,
   test_string VARCHAR2(4000) NOT NULL
)
/
/*
Table that contains SQL text that a user wants to
check for injection. This table is used in the 
Quest Code Tester test driver for SQL Guard.

You can use the sequence to generate a unique primary
key value. 
*/

CREATE TABLE sql_guard_drivers (
   ID INTEGER PRIMARY KEY,
   expected_injection_status INTEGER NOT NULL,
   sql_type VARCHAR2(100) NOT NULL,
   sql_text VARCHAR2(4000) NOT NULL
)
/
DROP SEQUENCE sql_guard_seq
/
CREATE SEQUENCE sql_guard_seq
/
@@sql_guard.pks

SHOW ERRORS

@@sql_guard.pkb

SHOW ERRORS

/*
Some sample data...
*/


BEGIN
   sql_guard.add_test (NAME_IN => 'Semi-colon', test_string_in => ';');
   sql_guard.add_test (test_string_in => 'CREATE');
   sql_guard.add_test (test_string_in => 'REPLACE');
   sql_guard.add_test (test_string_in => 'DROP');
   sql_guard.add_test (test_string_in => 'ALTER');
   sql_guard.add_test (test_string_in => 'REVOKE');
   sql_guard.add_test (test_string_in => 'PROCEDURE');
   sql_guard.add_test (test_string_in => 'FUNCTION');
   sql_guard.add_test (test_string_in => 'EXECUTE IMMEDIATE');
   sql_guard.add_test (test_string_in => 'DBMS_SQL');
   sql_guard.add_test (test_string_in => 'UNION');
   sql_guard.add_test (NAME_IN => 'Single Quote', test_string_in => '''');
   sql_guard.add_test (NAME_IN             => 'Reference to SYS object'
                     , test_string_in      => 'SYS.'
                      );
   sql_guard.add_test (NAME_IN             => 'Trivial WHERE clause'
                     , test_string_in      => '%1=1%'
                      );
   sql_guard.add_test (NAME_IN                   => 'Contains the word "DUMMY"'
                     , test_string_in            => 'INSTR ([SQLTEXT], ''DUMMY'') > 0'
                     , operator_in               => sql_guard.c_expression_test
                     , surround_with_pct_in      => FALSE
                      );

   INSERT INTO sql_guard_drivers
        VALUES (sql_guard_seq.NEXTVAL
              , sql_guard.c_sql_is_safe
              , sql_guard.c_sql
              , 'SELECT * FROM employees'
               );

   INSERT INTO sql_guard_drivers
        VALUES (sql_guard_seq.NEXTVAL
              , sql_guard.c_injection_detected
              , sql_guard.c_ddl
              , 'DROP TABLE abc'
               );

   INSERT INTO sql_guard_drivers
        VALUES (sql_guard_seq.NEXTVAL
              , sql_guard.c_injection_detected
              , sql_guard.c_sql
              , 'where 1=1'
               );

   INSERT INTO sql_guard_drivers
        VALUES (sql_guard_seq.NEXTVAL
              , sql_guard.c_injection_detected
              , sql_guard.c_sql
              , 'select * from dummy'
               );

   INSERT INTO sql_guard_drivers
        VALUES (sql_guard_seq.NEXTVAL
              , sql_guard.c_injection_detected
              , sql_guard.c_sql
              , 'create or replace procedure abc is begin null; end;'
               );

   COMMIT;
END;
/