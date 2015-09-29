CREATE OR REPLACE PACKAGE BODY sql_guard
/*
| The SQL Guard package: an API to help PL/SQL developers
|    minimize the risk of SQL injection.
|
| File name: sql_guard.pkb
|
| Author(s): Steven Feuerstein, steven.feuerstein@quest.com
|
| Modification History:
|   Date          Who           What
|   Sep 6, 2007   SFeuerstein   Create first draft of package (Bratislava)
|
*/
IS
/*
Other ideas

  Concerns identified by Pete Finnegan:

* UNIONS can be added to an existing statement to execute a second statement;
* SUBSELECTS can be added to existing statements;
* Existing SQL can be short-circuited to bring back all data. This technique is often used to gain access via third party-implemented authentication schemes;
* A large selection of installed packages and procedures are available, these include packages to read and write O/S files;
* Data Definition Language (DDL) can be injected if DDL is used in a dynamic SQL string;
* INSERTS, UPDATES and DELETES can also be injected; and,
* Other databases can be injected through the first by using database links.

I think that I should create categories of indicators and let people choose.

As in: no remote database, no DML, no DDL, no comments, and so on.

Also for strings below, they must be distinct, not part of another bigger string,
like CREATE_EMP.

Add full list of SYS catalog views.

Detect fishing: repetitive calls to the same program within a period of time, same user,
something like that.

'a'='a' or 1=1

Analysis of certain classes of errors - such as multiple errors indicating that select classes have the wrong number of items or wrong data types. This would indicate someone trying to create an extra select using a union.

*/
   TYPE safe_bundle_rt IS RECORD (
      sql_text                    VARCHAR2 (32767)
    , safety_level                PLS_INTEGER
    , injection_indicators        DBMS_SQL.varchar2s
    , unsafe_indicators_checked   DBMS_SQL.varchar2s
    , created_on                  DATE
    , created_by                  VARCHAR2 (30)
   );

   TYPE bundles_tt IS TABLE OF safe_bundle_rt
      INDEX BY analyzed_sql_handle_t;

   g_bundles         bundles_tt;

   --
   TYPE tests_aat IS TABLE OF sql_guard_tests%ROWTYPE
      INDEX BY PLS_INTEGER;

   TYPE tests_by_name_aat IS TABLE OF sql_guard_tests%ROWTYPE
      INDEX BY sql_guard_tests.NAME%TYPE;

   g_test_once       tests_by_name_aat;
   g_ignore_once     tests_by_name_aat;
/*
Trace functionality carried over from Quest Error Manager
*/
   g_trace_enabled   BOOLEAN           := FALSE;

   PROCEDURE set_trace (onoff_in IN BOOLEAN)
   IS
   BEGIN
      g_trace_enabled := onoff_in;
   END set_trace;

   FUNCTION trace_enabled
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN g_trace_enabled;
   END trace_enabled;

   PROCEDURE TRACE (context_in IN VARCHAR2, text_in IN VARCHAR2)
   IS
   BEGIN
      IF trace_enabled
      THEN
         DBMS_OUTPUT.put_line (context_in || ': ' || text_in);
      END IF;
   END TRACE;

/*
Add tests for SQL injection
*/
   PROCEDURE add_test (
      test_string_in IN VARCHAR2
    , NAME_IN IN VARCHAR2 DEFAULT NULL
    , operator_in IN VARCHAR2 DEFAULT 'LIKE'
    , surround_with_pct_in IN BOOLEAN DEFAULT TRUE
    , apply_once_in IN BOOLEAN DEFAULT FALSE
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      l_upper_name   VARCHAR2 (32767)
         := UPPER (NVL (NAME_IN
                      ,    test_string_in
                        || CASE
                              WHEN INSTR (test_string_in, ' ') > 0
                                 THEN ' Statement'
                              ELSE ' Keyword'
                           END
                       )
                  );
      l_test         sql_guard_tests.test_string%TYPE
         := CASE
         WHEN surround_with_pct_in
            THEN '%' || test_string_in || '%'
         ELSE test_string_in
      END;
   BEGIN
      IF apply_once_in
      THEN
         /* Add to cache list. */
         g_test_once (l_upper_name).NAME := l_upper_name;
         g_test_once (l_upper_name).OPERATOR := operator_in;
         g_test_once (l_upper_name).test_string := l_test;
      ELSE
         /* Put it into the database and commit it. */
         INSERT INTO sql_guard_tests
                     (NAME, OPERATOR, test_string
                     )
              VALUES (l_upper_name, operator_in, l_test
                     );

         COMMIT;
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         DBMS_OUTPUT.put_line ('SQL GUARD: Unanticipated Error!');
         DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack);
         DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_backtrace);
         DBMS_OUTPUT.put_line (DBMS_UTILITY.format_call_stack);
         ROLLBACK;
         RAISE;
   END add_test;

   PROCEDURE add_plsql_expr_test (
      test_string_in IN VARCHAR2
    , NAME_IN IN VARCHAR2 DEFAULT NULL
    , apply_once_in IN BOOLEAN DEFAULT FALSE
   )
   IS
   BEGIN
      add_test (test_string_in            => test_string_in
              , NAME_IN                   => NAME_IN
              , operator_in               => c_expression_test
              , apply_once_in             => apply_once_in
              , surround_with_pct_in      => FALSE
               );
   END add_plsql_expr_test;

   PROCEDURE add_reg_expr_test (
      test_string_in IN VARCHAR2
    , NAME_IN IN VARCHAR2 DEFAULT NULL
    , apply_once_in IN BOOLEAN DEFAULT FALSE
   )
   IS
   BEGIN
      add_test (test_string_in            => test_string_in
              , NAME_IN                   => NAME_IN
              , operator_in               => c_regexp_like_test
              , apply_once_in             => apply_once_in
              , surround_with_pct_in      => FALSE
               );
   END add_reg_expr_test;

   PROCEDURE remove_test (
      NAME_IN IN VARCHAR2 DEFAULT NULL
    , apply_once_in IN BOOLEAN DEFAULT FALSE
   )
   IS
      l_upper_name   VARCHAR2 (32767) := UPPER (NAME_IN);
   BEGIN
      IF apply_once_in
      THEN
         g_ignore_once (l_upper_name).NAME := NAME_IN;
      ELSE
         /* Remove from the test table */
         DELETE FROM sql_guard_tests
               WHERE NAME = l_upper_name;
      END IF;
   END remove_test;

   PROCEDURE clear_test_once
   IS
   BEGIN
      g_test_once.DELETE;
      g_ignore_once.DELETE;
   END clear_test_once;

   PROCEDURE how_safe_is_it (
      sql_text_in IN VARCHAR2
    , safety_level_out OUT PLS_INTEGER
    , injection_indicators_out IN OUT DBMS_SQL.varchar2s
    , apply_once_only_in IN BOOLEAN DEFAULT FALSE
   )
   IS
      l_upper_text          VARCHAR2 (32767)           := UPPER (sql_text_in);
      l_tests               tests_by_name_aat;
      l_index               sql_guard_tests.NAME%TYPE;
      l_unsafe_indicators   DBMS_SQL.varchar2s;

      PROCEDURE apply_table_tests (
         injection_indicators_out IN OUT DBMS_SQL.varchar2s
      )
      IS
         c_dangerous   VARCHAR2 (100)   := 'DANGEROUS';
         l_block       VARCHAR2 (32767);
         l_result      VARCHAR2 (100);

         PROCEDURE prepare_test_list (tests_out OUT tests_by_name_aat)
         IS
            l_temp_tests   tests_aat;
            l_tests        tests_by_name_aat;
            l_index        sql_guard_tests.NAME%TYPE;
         BEGIN
            IF trace_enabled
            THEN
               TRACE ('prepare_test_list total test once tests'
                    , g_test_once.COUNT
                     );
               TRACE ('prepare_test_list total ignore once tests'
                    , g_ignore_once.COUNT
                     );
               l_index := g_test_once.FIRST;

               WHILE (l_index IS NOT NULL)
               LOOP
                  TRACE ('prepare_test_list test once ' || l_index
                       , g_test_once (l_index).test_string
                        );
                  l_index := g_test_once.NEXT (l_index);
               END LOOP;
            END IF;

            IF apply_once_only_in
            THEN
               l_tests := g_test_once;
            ELSE
               SELECT *
               BULK COLLECT INTO l_temp_tests
                 FROM sql_guard_tests;

               FOR indx IN 1 .. l_temp_tests.COUNT
               LOOP
                  l_tests (l_temp_tests (indx).NAME) := l_temp_tests (indx);
               END LOOP;

               /* Add the test once only tests */
               l_index := g_test_once.FIRST;

               WHILE (l_index IS NOT NULL)
               LOOP
                  l_tests (g_test_once (l_index).NAME) :=
                                                        g_test_once (l_index);
                  l_index := g_test_once.NEXT (l_index);
               END LOOP;
            END IF;

            /* Remove any ignore once tests. */
            l_index := g_ignore_once.FIRST;

            WHILE (l_index IS NOT NULL)
            LOOP
               l_tests.DELETE (l_index);
               l_index := g_ignore_once.NEXT (l_index);
            END LOOP;

            IF trace_enabled
            THEN
               TRACE ('prepare_test_list total tests', l_tests.COUNT);
               TRACE ('prepare_test_list total test once tests'
                    , g_test_once.COUNT
                     );
               TRACE ('prepare_test_list total ignore once tests'
                    , g_ignore_once.COUNT
                     );
               l_index := l_tests.FIRST;

               WHILE (l_index IS NOT NULL)
               LOOP
                  TRACE ('prepare_test_list test ' || l_index
                       , l_tests (l_index).test_string
                        );
                  l_index := l_tests.NEXT (l_index);
               END LOOP;
            END IF;

            tests_out := l_tests;
         END prepare_test_list;

         FUNCTION block_for_operator (test_in IN sql_guard_tests%ROWTYPE)
            RETURN VARCHAR2
         IS
            c_endif_text          CONSTANT VARCHAR2 (1000)
               :=    ' THEN :result_value := '''
                  || c_dangerous
                  || '''; ELSE :result_value := ''SAFE''; 
                                   END IF; END;';
            c_operator            CONSTANT sql_guard_tests.OPERATOR%TYPE
                                                   := UPPER (test_in.OPERATOR);
            c_upper_test_string   CONSTANT sql_guard_tests.test_string%TYPE
                                                := UPPER (test_in.test_string);
            c_placeholder                  VARCHAR2 (100)       := ':sql_text';
            l_stringloc                    PLS_INTEGER;
            l_return                       VARCHAR2 (32767);
         BEGIN
            CASE c_operator
               WHEN c_expression_test
               THEN
                  /* Substitute in the actual string for [SQLTEST] and then construct the block. */
                  l_stringloc := INSTR (c_upper_test_string, c_sqltext_tag);

                  IF l_stringloc > 0
                  THEN
                     l_return :=
                           SUBSTR (test_in.test_string, 1, l_stringloc - 1)
                        || ' '
                        || c_placeholder
                        || ' '
                        || SUBSTR (test_in.test_string
                                 , l_stringloc + c_sqltext_tag_length
                                  );
                  ELSE
                     /* No substitution */
                     l_return := test_in.test_string;
                  END IF;

                  l_return := 'BEGIN IF ' || l_return || c_endif_text;
               WHEN c_regexp_like_test
               THEN
                  l_return :=
                        'BEGIN IF REGEXP_LIKE ('
                     || c_placeholder
                     || ',  '''
                     || test_in.test_string
                     || ''') '
                     || c_endif_text;
               ELSE
                  /* Regular old PL/SQL comparison of some sort...build it! */
                  l_return :=
                        'BEGIN IF '
                     || c_placeholder
                     || ' '
                     || test_in.OPERATOR
                     || ' '''
                     || REPLACE (test_in.test_string, '''', '''''')
                     || ''''
                     || c_endif_text;
            END CASE;

            RETURN l_return;
         END block_for_operator;
      BEGIN
         prepare_test_list (l_tests);
         l_index := l_tests.FIRST;

         WHILE (l_index IS NOT NULL)
         LOOP
            BEGIN
               l_block := block_for_operator (l_tests (l_index));
               DBMS_OUTPUT.put_line (l_block);

               IF trace_enabled
               THEN
                  TRACE ('apply_table_tests block', l_block);
               END IF;

               EXECUTE IMMEDIATE l_block
                           USING l_upper_text, OUT l_result;

               IF l_result = c_dangerous
               THEN
                  injection_indicators_out (injection_indicators_out.COUNT + 1
                                           ) :=
                        l_tests (l_index).OPERATOR
                     || ' '
                     || l_tests (l_index).test_string;
               END IF;
            EXCEPTION
               WHEN OTHERS
               THEN
                  /* The operator or string provided is not valid.
                     Display the information and continue. */
                  DBMS_OUTPUT.put_line ('SQL GUARD: Invalid test!');
                  DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_stack);
                  --DBMS_OUTPUT.put_line (DBMS_UTILITY.format_error_backtrace);
                  --DBMS_OUTPUT.put_line (DBMS_UTILITY.format_call_stack);
                  DBMS_OUTPUT.put_line (   'Operator = '
                                        || l_tests (l_index).OPERATOR
                                       );
                  DBMS_OUTPUT.put_line (   'Test string  = '
                                        || l_tests (l_index).test_string
                                       );
                  DBMS_OUTPUT.put_line ('Block  = ' || l_block);
            END;

            l_index := l_tests.NEXT (l_index);
         END LOOP;

         /*
         Clear out the test once tests.
         */
         clear_test_once ();
      END apply_table_tests;
   BEGIN
      /*
      Now check to see if there are tests in the test table to apply.
      */
      apply_table_tests (injection_indicators_out);
      safety_level_out :=
         CASE
            WHEN injection_indicators_out.COUNT > 0
               THEN c_injection_detected
            ELSE c_sql_is_safe
         END;
   END how_safe_is_it;

   FUNCTION analyzed_sql (
      sql_text_in IN VARCHAR2
    , apply_once_only_in IN BOOLEAN DEFAULT FALSE
   )
      RETURN analyzed_sql_handle_t
   IS
      l_safe_bundle   safe_bundle_rt;
      l_new_handle    analyzed_sql_handle_t := SYS_GUID;
   BEGIN
      l_safe_bundle.sql_text := sql_text_in;
      how_safe_is_it
             (sql_text_in                   => sql_text_in
            , safety_level_out              => l_safe_bundle.safety_level
            , injection_indicators_out      => l_safe_bundle.injection_indicators
            , apply_once_only_in            => apply_once_only_in
             );
      l_safe_bundle.created_on := SYSDATE;
      l_safe_bundle.created_by := USER;
      g_bundles (l_new_handle) := l_safe_bundle;
      RETURN l_new_handle;
   END analyzed_sql;

   /*
   API that allows users to add logic to be used to validate text.

   Example:
      sql_guard.add_test ('LIKE', '%--%');

   This test will then be added to whatever other indicators are
   applied to the analysis of injection.
   */
   PROCEDURE add_for_next_only (
      test_in IN VARCHAR2
    , operator_in IN VARCHAR2 DEFAULT 'LIKE'
    , surround_with_pct_in IN BOOLEAN DEFAULT TRUE
    , next_analysis_only_in IN BOOLEAN DEFAULT FALSE
   )
   IS
   BEGIN
      NULL;
   END add_for_next_only;

   /* Simple, direct check of SQL text, using default indicators. */
   FUNCTION sql_safety_level (
      sql_text_in IN VARCHAR2
    , apply_once_only_in IN BOOLEAN DEFAULT FALSE
   )
      RETURN PLS_INTEGER
   IS
      l_no_extra_indicators   DBMS_SQL.varchar2s;
      l_ignore_nothing        DBMS_SQL.varchar2s;
      l_analysis              analyzed_sql_handle_t;
      l_return                PLS_INTEGER;
   BEGIN
      l_analysis := analyzed_sql (sql_text_in, apply_once_only_in);
      RETURN g_bundles (l_analysis).safety_level;
   END sql_safety_level;

   FUNCTION sql_safety_level (sql_handle_in IN analyzed_sql_handle_t)
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN g_bundles (sql_handle_in).safety_level;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN c_unknown_handle;
   END sql_safety_level;

   FUNCTION sql_is_safe (sql_handle_in IN analyzed_sql_handle_t)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN g_bundles (sql_handle_in).safety_level = c_sql_is_safe;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END sql_is_safe;

   FUNCTION injection_detected (sql_handle_in IN analyzed_sql_handle_t)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN g_bundles (sql_handle_in).safety_level = c_injection_detected;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END injection_detected;

   FUNCTION sql_text (sql_handle_in IN analyzed_sql_handle_t)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN g_bundles (sql_handle_in).sql_text;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END sql_text;

   FUNCTION injection_indicators_found (sql_handle_in IN analyzed_sql_handle_t)
      RETURN DBMS_SQL.varchar2s
   IS
      l_empty   DBMS_SQL.varchar2s;
   BEGIN
      RETURN g_bundles (sql_handle_in).injection_indicators;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN l_empty;
   END injection_indicators_found;

   PROCEDURE show_no_sql_guard_use (
      schema_in IN VARCHAR2 DEFAULT NULL
    , object_name_filter_in IN VARCHAR2 DEFAULT '%'
   )
   IS
      FUNCTION uses_dynamic_sql (
         owner_in IN VARCHAR2
       , object_name_in IN VARCHAR2
       , object_type_in IN VARCHAR2
      )
         RETURN BOOLEAN
      IS
         l_return       BOOLEAN                := FALSE;
         l_source       DBMS_SQL.varchar2a;
         l_index        PLS_INTEGER;
         l_upper_text   all_source.text%TYPE;
      BEGIN
         SELECT text
         BULK COLLECT INTO l_source
           FROM all_source
          WHERE owner = owner_in
            AND NAME = object_name_in
            AND TYPE = object_type_in;

         l_index := 1;

         WHILE (NOT l_return AND l_index <= l_source.LAST)
         LOOP
            l_upper_text := UPPER (l_source (l_index));
            l_return :=
                  INSTR (l_upper_text, 'DBMS_SQL') > 0
               OR INSTR (l_upper_text, 'EXECUTE IMMEDIATE') > 0;
            l_index := l_index + 1;
         END LOOP;

         RETURN l_return;
      END uses_dynamic_sql;

      FUNCTION uses_sql_guard (
         owner_in IN VARCHAR2
       , object_name_in IN VARCHAR2
       , object_type_in IN VARCHAR2
      )
         RETURN BOOLEAN
      IS
         l_dummy   VARCHAR2 (1);
      BEGIN
         SELECT 'x'
           INTO l_dummy
           FROM all_dependencies
          WHERE owner = owner_in
            AND NAME = object_name_in
            AND TYPE = object_type_in
            AND referenced_type = 'PACKAGE'
            AND referenced_name = 'SQL_GUARD'
            AND ROWNUM < 2;

         RETURN TRUE;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            RETURN FALSE;
      END uses_sql_guard;
   BEGIN
      FOR object_rec IN (SELECT *
                           FROM all_objects
                          WHERE owner = NVL (schema_in, USER)
                            AND object_name LIKE object_name_filter_in
                            AND object_type IN
                                   ('PACKAGE', 'PROCEDURE', 'FUNCTION'
                                  , 'TRIGGER', 'TYPE BODY'))
      LOOP
         IF uses_dynamic_sql (object_rec.owner
                            , object_rec.object_name
                            , object_rec.object_type
                             )
         THEN
            IF NOT uses_sql_guard (object_rec.owner
                                 , object_rec.object_name
                                 , object_rec.object_type
                                  )
            THEN
               DBMS_OUTPUT.put_line (object_rec.object_name);
            END IF;
         END IF;
      END LOOP;
   END show_no_sql_guard_use;
END sql_guard;
/