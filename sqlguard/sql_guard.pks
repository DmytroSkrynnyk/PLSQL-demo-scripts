CREATE OR REPLACE PACKAGE sql_guard
/*
| The SQL Guard package: an API to help PL/SQL developers
|    minimize the risk of SQL injection.
|
| File name: sql_guard.pks
|
| Author(s): Steven Feuerstein, steven.feuerstein@quest.com
|
| Overview: Protection against SQL injection comes in these forms:
|
|    1. Analyze contents of dynamic SQL text, identifying
|       the presence of strings which could be dangerous,
|       such as ; or CREATE or DROP. Save the text, plus all
|       related information in a record within the package body.
|       Hand back to the caller a handle or pointer to that
|       SQL statement and its analysis.
|
|    2. All dynamic SQL programs then will no longer accept a
|       string of text to be processed and executed. Instead, you
|       pass in the SQL_GUARD handle and then the program makes
|       certain that the SQL text is safe. If not, you do not
|       execute the statement; instead you raise an exception.
|
| Installation notes:
|    * You should wrap the package body so that it will be impossible (or
|      very very difficult) for anyone to bypass the package security and
|      manipulate the SQL bundles.
|
| IMPORTANT CAVEAT: this package will *not* comprehensively and
|    automatically protect against SQL injection. It will, however,
|    increase programmer awareness of the issues and make it eassier
|    to flag problematic text.
|
| Modification History:
|   Date          Who           What
|   Oct 13, 2007  SF            Add support for PL/SQL expressions
|                               Add "show" program to scan data dictionary.
|   Oct 12, 2007  SF            Add sql_safety_level function, to be used in
|                               Code Tester driver.
|   Sep 8, 2007   SFeuerstein   Switch to handing back only a handle, not record.
|   Sep 6, 2007   SFeuerstein   Create first draft of package (Bratislava)
|
*/
IS
   /* Codes used to communicate safety level. I choose to use absurd values
      to minimize the chance that anyone would actually hard-code them.
   */
   c_sql_is_safe          CONSTANT PLS_INTEGER    := 1010101;
   c_injection_detected   CONSTANT PLS_INTEGER    := 2020202;
   c_unknown_handle       CONSTANT PLS_INTEGER    := 3030303;
   /* Types of dynamic SQL */
   c_sql                  CONSTANT VARCHAR2 (100) := 'SQL';
   c_dml                  CONSTANT VARCHAR2 (100) := 'DML';
   c_ddl                  CONSTANT VARCHAR2 (100) := 'DDL';
   c_ddl_plsql            CONSTANT VARCHAR2 (100) := 'DDLPLSQL';
   c_plsql                CONSTANT VARCHAR2 (100) := 'PLSQL';
   /* Types of tests */
   c_expression_test      CONSTANT VARCHAR2 (100) := 'EXPRESSION';
   c_regexp_like_test     CONSTANT VARCHAR2 (100) := 'REGEXP_LIKE';
   /* Tag for replacement of sql text */
   c_sqltext_tag          CONSTANT VARCHAR2 (100) := '[SQLTEXT]';
   c_sqltext_tag_length   CONSTANT PLS_INTEGER    := 9;

   SUBTYPE analyzed_sql_handle_t IS VARCHAR2 (40);

   PROCEDURE set_trace (onoff_in IN BOOLEAN);

   /*
   API that allows users to add logic to be used to validate text.

   Example:
      sql_guard.add_test ('LIKE', '%--%');

   This test will then be added to whatever other indicators are
   applied to the analysis of injection.

   If you use EXPRESSION (c_expression_test) as the operator, then
   you can provide any valid Boolean PL/SQL expression you desire
   and it will be executed. Use the tag [sqltext] in your string to
   tell SQL Guard where to place the text being evaluated.
   */
   PROCEDURE add_test (
      test_string_in IN VARCHAR2
    , NAME_IN IN VARCHAR2 DEFAULT NULL
    , operator_in IN VARCHAR2 DEFAULT 'LIKE'
    , surround_with_pct_in IN BOOLEAN DEFAULT TRUE
    , apply_once_in IN BOOLEAN DEFAULT FALSE
   );

   PROCEDURE add_plsql_expr_test (
      test_string_in IN VARCHAR2
    , NAME_IN IN VARCHAR2 DEFAULT NULL
    , apply_once_in IN BOOLEAN DEFAULT FALSE
   );

   PROCEDURE add_reg_expr_test (
      test_string_in IN VARCHAR2
    , NAME_IN IN VARCHAR2 DEFAULT NULL
    , apply_once_in IN BOOLEAN DEFAULT FALSE
   );

   PROCEDURE remove_test (
      NAME_IN IN VARCHAR2 DEFAULT NULL
    , apply_once_in IN BOOLEAN DEFAULT FALSE
   );

   /* Analyze the SQL statement and return a handle to the bundle of
      information for that statement. */
   FUNCTION analyzed_sql (
      sql_text_in IN VARCHAR2
    , apply_once_only_in IN BOOLEAN DEFAULT FALSE
   )
      RETURN analyzed_sql_handle_t;

   /* Simple, direct check of SQL text, returning just the safety level. */
   FUNCTION sql_safety_level (
      sql_text_in IN VARCHAR2
    , apply_once_only_in IN BOOLEAN DEFAULT FALSE
   )
      RETURN PLS_INTEGER;

   /* Returns safety level of analyzed SQL text. */
   FUNCTION sql_safety_level (sql_handle_in IN analyzed_sql_handle_t)
      RETURN PLS_INTEGER;

   FUNCTION sql_is_safe (sql_handle_in IN analyzed_sql_handle_t)
      RETURN BOOLEAN;

   FUNCTION injection_detected (sql_handle_in IN analyzed_sql_handle_t)
      RETURN BOOLEAN;

   FUNCTION sql_text (sql_handle_in IN analyzed_sql_handle_t)
      RETURN VARCHAR2;

   FUNCTION injection_indicators_found (sql_handle_in IN analyzed_sql_handle_t)
      RETURN DBMS_SQL.varchar2s;

   PROCEDURE show_no_sql_guard_use (
      schema_in IN VARCHAR2 DEFAULT NULL
    , object_name_filter_in IN VARCHAR2 DEFAULT '%'
   );
END sql_guard;
/