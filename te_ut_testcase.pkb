CREATE OR REPLACE PACKAGE BODY te_ut_testcase
--//-----------------------------------------------------------------------
--//  ** PL/Generator Table Encapsulator for "UT_TESTCASE"
--//-----------------------------------------------------------------------
--//  (c) COPYRIGHT  2003.
--//               All rights reserved.
--//
--//  No part of this copyrighted work may be reproduced, modified,
--//  or distributed in any form or by any means without the prior
--//  written permission of .
--//-----------------------------------------------------------------------
--//  This software was generated by Quest Software's PL/Generator (TM).
--//
--//  For more information, visit www.Quest Software.com or call 1.800.REVEAL4
--//-----------------------------------------------------------------------
--//  Stored In:  te_ut_testcase.pkb
--//  Created On: May       09, 2003 16:37:40
--//  Created By: SCOTT
--//  PL/Generator Version: PRO-2000.2.8
--//-----------------------------------------------------------------------
IS
   --// Package name and program name globals --//
   c_pkgname VARCHAR2(30) := 'te_ut_testcase';
   g_progname VARCHAR2(30) := NULL;

   --// Update Flag private data structures. --//
   TYPE frcflg_rt IS RECORD (
      unittest_id CHAR(1),
      name CHAR(1),
      seq CHAR(1),
      description CHAR(1),
      status CHAR(1),
      declarations CHAR(1),
      setup CHAR(1),
      teardown CHAR(1),
      exceptions CHAR(1),
      test_id CHAR(1),
      prefix CHAR(1),
      assertion CHAR(1),
      inline_assertion_call CHAR(1),
      executions CHAR(1),
      failures CHAR(1),
      last_start CHAR(1),
      last_end CHAR(1)
      );

   frcflg frcflg_rt;
   emptyfrc frcflg_rt;
   c_set CHAR(1) := 'Y';
   c_noset CHAR(1) := 'N';

--// Private Modules //--

   --// For Dynamic SQL operations; currently unused. //--
   PROCEDURE initcur (cur_inout IN OUT INTEGER)
   IS
   BEGIN
      IF NOT DBMS_SQL.IS_OPEN (cur_inout)
      THEN
         cur_inout := DBMS_SQL.OPEN_CURSOR;
      END IF;
   EXCEPTION
      WHEN invalid_cursor
      THEN
         cur_inout := DBMS_SQL.OPEN_CURSOR;
   END;

   PROCEDURE start_program (nm IN VARCHAR2, msg IN VARCHAR2 := NULL) IS
   BEGIN
      g_progname := nm;
   END;

   PROCEDURE end_program IS
   BEGIN
      g_progname := NULL;
   END;

--// Cursor management procedures //--

   --// Open the cursors with some options. //--
   PROCEDURE open_allforpky_cur (
      id_in IN UT_TESTCASE.ID%TYPE,
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      start_program ('open_allforpky_cur');

      IF allforpky_cur%ISOPEN AND v_close
      THEN
         CLOSE allforpky_cur;
      ELSIF allforpky_cur%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open
      THEN
          OPEN allforpky_cur (
             id_in
             );
      END IF;

      end_program;
   END;

   PROCEDURE open_allbypky_cur (
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      IF allbypky_cur%ISOPEN AND v_close
      THEN
         CLOSE allbypky_cur;
      ELSIF allbypky_cur%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open
      THEN
         OPEN allbypky_cur;
      END IF;
   END;

   PROCEDURE open_ut_testcase_unitest_fk_al (
      unittest_id_in IN UT_TESTCASE.UNITTEST_ID%TYPE,
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      IF ut_testcase_unitest_fk_all_cur%ISOPEN AND v_close
      THEN
         CLOSE ut_testcase_unitest_fk_all_cur;
      ELSIF ut_testcase_unitest_fk_all_cur%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open
      THEN
         OPEN ut_testcase_unitest_fk_all_cur (
            unittest_id_in
            );
      END IF;
   END;

   --// Close the cursors if they are open. //--
   PROCEDURE close_allforpky_cur
   IS BEGIN
      IF allforpky_cur%ISOPEN
      THEN
         CLOSE allforpky_cur;
      END IF;
   END;

   PROCEDURE close_allbypky_cur
   IS BEGIN
      IF allbypky_cur%ISOPEN
      THEN
         CLOSE allbypky_cur;
      END IF;
   END;

   PROCEDURE close_ut_testcase_unitest_fk_a
   IS BEGIN
      IF ut_testcase_unitest_fk_all_cur%ISOPEN
      THEN
         CLOSE ut_testcase_unitest_fk_all_cur;
      END IF;
   END;

   PROCEDURE closeall
   IS
   BEGIN
      close_allforpky_cur;
      close_allbypky_cur;
      close_ut_testcase_unitest_fk_a;
   END;

--// Emulate aggregate-level record operations. //--

   FUNCTION recseq (rec1 IN UT_TESTCASE%ROWTYPE, rec2 IN UT_TESTCASE%ROWTYPE)
   RETURN BOOLEAN
   IS
      unequal_records EXCEPTION;
      retval BOOLEAN;
   BEGIN
      retval := rec1.ID = rec2.ID OR
         (rec1.ID IS NULL AND rec2.ID IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.UNITTEST_ID = rec2.UNITTEST_ID OR
         (rec1.UNITTEST_ID IS NULL AND rec2.UNITTEST_ID IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.NAME = rec2.NAME OR
         (rec1.NAME IS NULL AND rec2.NAME IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.SEQ = rec2.SEQ OR
         (rec1.SEQ IS NULL AND rec2.SEQ IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.DESCRIPTION = rec2.DESCRIPTION OR
         (rec1.DESCRIPTION IS NULL AND rec2.DESCRIPTION IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.STATUS = rec2.STATUS OR
         (rec1.STATUS IS NULL AND rec2.STATUS IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.DECLARATIONS = rec2.DECLARATIONS OR
         (rec1.DECLARATIONS IS NULL AND rec2.DECLARATIONS IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.SETUP = rec2.SETUP OR
         (rec1.SETUP IS NULL AND rec2.SETUP IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.TEARDOWN = rec2.TEARDOWN OR
         (rec1.TEARDOWN IS NULL AND rec2.TEARDOWN IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.EXCEPTIONS = rec2.EXCEPTIONS OR
         (rec1.EXCEPTIONS IS NULL AND rec2.EXCEPTIONS IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.TEST_ID = rec2.TEST_ID OR
         (rec1.TEST_ID IS NULL AND rec2.TEST_ID IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.PREFIX = rec2.PREFIX OR
         (rec1.PREFIX IS NULL AND rec2.PREFIX IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.ASSERTION = rec2.ASSERTION OR
         (rec1.ASSERTION IS NULL AND rec2.ASSERTION IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.INLINE_ASSERTION_CALL = rec2.INLINE_ASSERTION_CALL OR
         (rec1.INLINE_ASSERTION_CALL IS NULL AND rec2.INLINE_ASSERTION_CALL IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.EXECUTIONS = rec2.EXECUTIONS OR
         (rec1.EXECUTIONS IS NULL AND rec2.EXECUTIONS IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.FAILURES = rec2.FAILURES OR
         (rec1.FAILURES IS NULL AND rec2.FAILURES IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.LAST_START = rec2.LAST_START OR
         (rec1.LAST_START IS NULL AND rec2.LAST_START IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.LAST_END = rec2.LAST_END OR
         (rec1.LAST_END IS NULL AND rec2.LAST_END IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      RETURN TRUE;
   EXCEPTION
      WHEN unequal_records THEN RETURN FALSE;
   END;

   FUNCTION recseq (rec1 IN pky_rt, rec2 IN pky_rt)
   RETURN BOOLEAN
   IS
      unequal_records EXCEPTION;
      retval BOOLEAN;
   BEGIN
      retval := rec1.id = rec2.id OR
         (rec1.id IS NULL AND rec2.id IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      RETURN TRUE;
   EXCEPTION
      WHEN unequal_records THEN RETURN FALSE;
   END;

--// Is the primary key NOT NULL? //--

   FUNCTION isnullpky (
      rec_in IN UT_TESTCASE%ROWTYPE
      )
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN
         rec_in.ID IS NULL
         ;
   END;

   FUNCTION isnullpky (
      rec_in IN pky_rt
      )
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN
         rec_in.id IS NULL
         ;
   END;

--// Query Processing --//

   FUNCTION onerow_internal (
      id_in IN UT_TESTCASE.ID%TYPE
      )
   RETURN UT_TESTCASE%ROWTYPE
   IS
      CURSOR onerow_cur
      IS
         SELECT
            ID,
            UNITTEST_ID,
            NAME,
            SEQ,
            DESCRIPTION,
            STATUS,
            DECLARATIONS,
            SETUP,
            TEARDOWN,
            EXCEPTIONS,
            TEST_ID,
            PREFIX,
            ASSERTION,
            INLINE_ASSERTION_CALL,
            EXECUTIONS,
            FAILURES,
            LAST_START,
            LAST_END
           FROM UT_TESTCASE
          WHERE
             ID = id_in
      ;
      onerow_rec UT_TESTCASE%ROWTYPE;
   BEGIN
      OPEN onerow_cur;
      FETCH onerow_cur INTO onerow_rec;
      CLOSE onerow_cur;
      RETURN onerow_rec;
   END onerow_internal;

   FUNCTION onerow (
      id_in IN UT_TESTCASE.ID%TYPE
      )
   RETURN UT_TESTCASE%ROWTYPE
   IS
      retval UT_TESTCASE%ROWTYPE;
   BEGIN
      retval := onerow_internal (
         id_in
         );
      RETURN retval;
   END onerow;

   FUNCTION ut_testcase_idx1$pky (
      name_in IN UT_TESTCASE.NAME%TYPE
      )
      RETURN pky_rt
   IS
      CURSOR getpky_cur
      IS
         SELECT
            ID
           FROM UT_TESTCASE
          WHERE
            NAME = ut_testcase_idx1$pky.name_in
            ;

      getpky_rec getpky_cur%ROWTYPE;
      retval pky_rt;
   BEGIN
      OPEN getpky_cur;
      FETCH getpky_cur INTO getpky_rec;
      IF getpky_cur%FOUND
      THEN
         retval.id := getpky_rec.ID;
      END IF;
      CLOSE getpky_cur;
      RETURN retval;
   END ut_testcase_idx1$pky;

   FUNCTION ut_testcase_idx1$row (
      name_in IN UT_TESTCASE.NAME%TYPE
      )
   RETURN UT_TESTCASE%ROWTYPE
   IS
      CURSOR onerow_cur
      IS
         SELECT
            ID,
            UNITTEST_ID,
            NAME,
            SEQ,
            DESCRIPTION,
            STATUS,
            DECLARATIONS,
            SETUP,
            TEARDOWN,
            EXCEPTIONS,
            TEST_ID,
            PREFIX,
            ASSERTION,
            INLINE_ASSERTION_CALL,
            EXECUTIONS,
            FAILURES,
            LAST_START,
            LAST_END
           FROM UT_TESTCASE
          WHERE
             NAME = ut_testcase_idx1$row.name_in
             ;
      onerow_rec UT_TESTCASE%ROWTYPE;
   BEGIN
      OPEN onerow_cur;
      FETCH onerow_cur INTO onerow_rec;
      CLOSE onerow_cur;
      RETURN onerow_rec;
   END ut_testcase_idx1$row;

   FUNCTION ut_testcase_idx1$val (
      id_in IN UT_TESTCASE.ID%TYPE
      )
   RETURN ut_testcase_idx1_rt
   IS
      v_onerow UT_TESTCASE%ROWTYPE;
      retval ut_testcase_idx1_rt;
   BEGIN
      v_onerow := onerow (
         id_in
         );

      retval.name := v_onerow.NAME;

      RETURN retval;
   END ut_testcase_idx1$val;


   --// Count of all rows in table and for each foreign key. //--
   FUNCTION rowcount RETURN INTEGER
   IS
      retval INTEGER;
   BEGIN
      SELECT COUNT(*) INTO retval FROM UT_TESTCASE;
      RETURN retval;
   END;

   FUNCTION pkyrowcount (
      id_in IN UT_TESTCASE.ID%TYPE
      )
      RETURN INTEGER
   IS
      retval INTEGER;
   BEGIN
      SELECT COUNT(*)
        INTO retval
        FROM UT_TESTCASE
       WHERE
         ID = id_in
         ;
      RETURN retval;
   END;

   FUNCTION ut_testcase_unitest_fkrowcount (
      unittest_id_in IN UT_TESTCASE.UNITTEST_ID%TYPE
      )
      RETURN INTEGER
   IS
      retval INTEGER;
   BEGIN
      SELECT COUNT(*) INTO retval
        FROM UT_TESTCASE
       WHERE
          UNITTEST_ID = ut_testcase_unitest_fkrowcount.unittest_id_in
          ;
      RETURN retval;
   END;
--// Update Processing --//

   PROCEDURE reset$frc IS
   BEGIN
      frcflg := emptyfrc;
   END reset$frc;

   FUNCTION unittest_id$frc (unittest_id_in IN UT_TESTCASE.UNITTEST_ID%TYPE DEFAULT NULL)
      RETURN UT_TESTCASE.UNITTEST_ID%TYPE
   IS
   BEGIN
      frcflg.unittest_id := c_set;
      RETURN unittest_id_in;
   END unittest_id$frc;

   FUNCTION name$frc (name_in IN UT_TESTCASE.NAME%TYPE DEFAULT NULL)
      RETURN UT_TESTCASE.NAME%TYPE
   IS
   BEGIN
      frcflg.name := c_set;
      RETURN name_in;
   END name$frc;

   FUNCTION seq$frc (seq_in IN UT_TESTCASE.SEQ%TYPE DEFAULT NULL)
      RETURN UT_TESTCASE.SEQ%TYPE
   IS
   BEGIN
      frcflg.seq := c_set;
      RETURN seq_in;
   END seq$frc;

   FUNCTION description$frc (description_in IN UT_TESTCASE.DESCRIPTION%TYPE DEFAULT NULL)
      RETURN UT_TESTCASE.DESCRIPTION%TYPE
   IS
   BEGIN
      frcflg.description := c_set;
      RETURN description_in;
   END description$frc;

   FUNCTION status$frc (status_in IN UT_TESTCASE.STATUS%TYPE DEFAULT NULL)
      RETURN UT_TESTCASE.STATUS%TYPE
   IS
   BEGIN
      frcflg.status := c_set;
      RETURN status_in;
   END status$frc;

   FUNCTION declarations$frc (declarations_in IN UT_TESTCASE.DECLARATIONS%TYPE DEFAULT NULL)
      RETURN UT_TESTCASE.DECLARATIONS%TYPE
   IS
   BEGIN
      frcflg.declarations := c_set;
      RETURN declarations_in;
   END declarations$frc;

   FUNCTION setup$frc (setup_in IN UT_TESTCASE.SETUP%TYPE DEFAULT NULL)
      RETURN UT_TESTCASE.SETUP%TYPE
   IS
   BEGIN
      frcflg.setup := c_set;
      RETURN setup_in;
   END setup$frc;

   FUNCTION teardown$frc (teardown_in IN UT_TESTCASE.TEARDOWN%TYPE DEFAULT NULL)
      RETURN UT_TESTCASE.TEARDOWN%TYPE
   IS
   BEGIN
      frcflg.teardown := c_set;
      RETURN teardown_in;
   END teardown$frc;

   FUNCTION exceptions$frc (exceptions_in IN UT_TESTCASE.EXCEPTIONS%TYPE DEFAULT NULL)
      RETURN UT_TESTCASE.EXCEPTIONS%TYPE
   IS
   BEGIN
      frcflg.exceptions := c_set;
      RETURN exceptions_in;
   END exceptions$frc;

   FUNCTION test_id$frc (test_id_in IN UT_TESTCASE.TEST_ID%TYPE DEFAULT NULL)
      RETURN UT_TESTCASE.TEST_ID%TYPE
   IS
   BEGIN
      frcflg.test_id := c_set;
      RETURN test_id_in;
   END test_id$frc;

   FUNCTION prefix$frc (prefix_in IN UT_TESTCASE.PREFIX%TYPE DEFAULT NULL)
      RETURN UT_TESTCASE.PREFIX%TYPE
   IS
   BEGIN
      frcflg.prefix := c_set;
      RETURN prefix_in;
   END prefix$frc;

   FUNCTION assertion$frc (assertion_in IN UT_TESTCASE.ASSERTION%TYPE DEFAULT NULL)
      RETURN UT_TESTCASE.ASSERTION%TYPE
   IS
   BEGIN
      frcflg.assertion := c_set;
      RETURN assertion_in;
   END assertion$frc;

   FUNCTION inline_assertion_call$frc (inline_assertion_call_in IN UT_TESTCASE.INLINE_ASSERTION_CALL%TYPE DEFAULT NULL)
      RETURN UT_TESTCASE.INLINE_ASSERTION_CALL%TYPE
   IS
   BEGIN
      frcflg.inline_assertion_call := c_set;
      RETURN inline_assertion_call_in;
   END inline_assertion_call$frc;

   FUNCTION executions$frc (executions_in IN UT_TESTCASE.EXECUTIONS%TYPE DEFAULT NULL)
      RETURN UT_TESTCASE.EXECUTIONS%TYPE
   IS
   BEGIN
      frcflg.executions := c_set;
      RETURN executions_in;
   END executions$frc;

   FUNCTION failures$frc (failures_in IN UT_TESTCASE.FAILURES%TYPE DEFAULT NULL)
      RETURN UT_TESTCASE.FAILURES%TYPE
   IS
   BEGIN
      frcflg.failures := c_set;
      RETURN failures_in;
   END failures$frc;

   FUNCTION last_start$frc (last_start_in IN UT_TESTCASE.LAST_START%TYPE DEFAULT NULL)
      RETURN UT_TESTCASE.LAST_START%TYPE
   IS
   BEGIN
      frcflg.last_start := c_set;
      RETURN last_start_in;
   END last_start$frc;

   FUNCTION last_end$frc (last_end_in IN UT_TESTCASE.LAST_END%TYPE DEFAULT NULL)
      RETURN UT_TESTCASE.LAST_END%TYPE
   IS
   BEGIN
      frcflg.last_end := c_set;
      RETURN last_end_in;
   END last_end$frc;

   PROCEDURE upd (
      id_in IN UT_TESTCASE.ID%TYPE,
      unittest_id_in IN UT_TESTCASE.UNITTEST_ID%TYPE DEFAULT NULL,
      name_in IN UT_TESTCASE.NAME%TYPE DEFAULT NULL,
      seq_in IN UT_TESTCASE.SEQ%TYPE DEFAULT NULL,
      description_in IN UT_TESTCASE.DESCRIPTION%TYPE DEFAULT NULL,
      status_in IN UT_TESTCASE.STATUS%TYPE DEFAULT NULL,
      declarations_in IN UT_TESTCASE.DECLARATIONS%TYPE DEFAULT NULL,
      setup_in IN UT_TESTCASE.SETUP%TYPE DEFAULT NULL,
      teardown_in IN UT_TESTCASE.TEARDOWN%TYPE DEFAULT NULL,
      exceptions_in IN UT_TESTCASE.EXCEPTIONS%TYPE DEFAULT NULL,
      test_id_in IN UT_TESTCASE.TEST_ID%TYPE DEFAULT NULL,
      prefix_in IN UT_TESTCASE.PREFIX%TYPE DEFAULT NULL,
      assertion_in IN UT_TESTCASE.ASSERTION%TYPE DEFAULT NULL,
      inline_assertion_call_in IN UT_TESTCASE.INLINE_ASSERTION_CALL%TYPE DEFAULT NULL,
      executions_in IN UT_TESTCASE.EXECUTIONS%TYPE DEFAULT NULL,
      failures_in IN UT_TESTCASE.FAILURES%TYPE DEFAULT NULL,
      last_start_in IN UT_TESTCASE.LAST_START%TYPE DEFAULT NULL,
      last_end_in IN UT_TESTCASE.LAST_END%TYPE DEFAULT NULL,
      rowcount_out OUT INTEGER,
      reset_in IN BOOLEAN DEFAULT TRUE
      )
   IS
   BEGIN
      UPDATE UT_TESTCASE SET
         UNITTEST_ID = DECODE (frcflg.unittest_id, c_set, unittest_id_in,
            NVL (unittest_id_in, UNITTEST_ID)),
         NAME = DECODE (frcflg.name, c_set, name_in,
            NVL (name_in, NAME)),
         SEQ = DECODE (frcflg.seq, c_set, seq_in,
            NVL (seq_in, SEQ)),
         DESCRIPTION = DECODE (frcflg.description, c_set, description_in,
            NVL (description_in, DESCRIPTION)),
         STATUS = DECODE (frcflg.status, c_set, status_in,
            NVL (status_in, STATUS)),
         DECLARATIONS = DECODE (frcflg.declarations, c_set, declarations_in,
            NVL (declarations_in, DECLARATIONS)),
         SETUP = DECODE (frcflg.setup, c_set, setup_in,
            NVL (setup_in, SETUP)),
         TEARDOWN = DECODE (frcflg.teardown, c_set, teardown_in,
            NVL (teardown_in, TEARDOWN)),
         EXCEPTIONS = DECODE (frcflg.exceptions, c_set, exceptions_in,
            NVL (exceptions_in, EXCEPTIONS)),
         TEST_ID = DECODE (frcflg.test_id, c_set, test_id_in,
            NVL (test_id_in, TEST_ID)),
         PREFIX = DECODE (frcflg.prefix, c_set, prefix_in,
            NVL (prefix_in, PREFIX)),
         ASSERTION = DECODE (frcflg.assertion, c_set, assertion_in,
            NVL (assertion_in, ASSERTION)),
         INLINE_ASSERTION_CALL = DECODE (frcflg.inline_assertion_call, c_set, inline_assertion_call_in,
            NVL (inline_assertion_call_in, INLINE_ASSERTION_CALL)),
         EXECUTIONS = DECODE (frcflg.executions, c_set, executions_in,
            NVL (executions_in, EXECUTIONS)),
         FAILURES = DECODE (frcflg.failures, c_set, failures_in,
            NVL (failures_in, FAILURES)),
         LAST_START = DECODE (frcflg.last_start, c_set, last_start_in,
            NVL (last_start_in, LAST_START)),
         LAST_END = DECODE (frcflg.last_end, c_set, last_end_in,
            NVL (last_end_in, LAST_END))
       WHERE
          ID = id_in
         ;
      rowcount_out := SQL%ROWCOUNT;
      IF reset_in THEN reset$frc; END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END upd;

   --// Record-based Update --//
   PROCEDURE upd (
      rec_in IN UT_TESTCASE%ROWTYPE,
      rowcount_out OUT INTEGER,
      reset_in IN BOOLEAN DEFAULT TRUE)
   IS
   BEGIN
      upd (
         rec_in.ID,
         rec_in.UNITTEST_ID,
         rec_in.NAME,
         rec_in.SEQ,
         rec_in.DESCRIPTION,
         rec_in.STATUS,
         rec_in.DECLARATIONS,
         rec_in.SETUP,
         rec_in.TEARDOWN,
         rec_in.EXCEPTIONS,
         rec_in.TEST_ID,
         rec_in.PREFIX,
         rec_in.ASSERTION,
         rec_in.INLINE_ASSERTION_CALL,
         rec_in.EXECUTIONS,
         rec_in.FAILURES,
         rec_in.LAST_START,
         rec_in.LAST_END,
         rowcount_out,
         reset_in);
   END upd;

--// Insert Processing --//

   --// Initialize record with default values. --//
   FUNCTION initrec (allnull IN BOOLEAN := FALSE) RETURN UT_TESTCASE%ROWTYPE
   IS
      retval UT_TESTCASE%ROWTYPE;
   BEGIN
      IF allnull THEN NULL; /* Default values are NULL already. */
      ELSE
         retval.ID := NULL;
         retval.UNITTEST_ID := NULL;
         retval.NAME := NULL;
         retval.SEQ := 1;
         retval.DESCRIPTION := NULL;
         retval.STATUS := NULL;
         retval.DECLARATIONS := NULL;
         retval.SETUP := NULL;
         retval.TEARDOWN := NULL;
         retval.EXCEPTIONS := NULL;
         retval.TEST_ID := NULL;
         retval.PREFIX := NULL;
         retval.ASSERTION := NULL;
         retval.INLINE_ASSERTION_CALL := 'N';
         retval.EXECUTIONS := NULL;
         retval.FAILURES := NULL;
         retval.LAST_START := NULL;
         retval.LAST_END := NULL;
      END IF;
      RETURN retval;
   END;

   --// Initialize record with default values. --//
   PROCEDURE initrec (
      rec_inout IN OUT UT_TESTCASE%ROWTYPE,
      allnull IN BOOLEAN := FALSE)
   IS
   BEGIN
      rec_inout := initrec;
   END;

   PROCEDURE ins$ins (
      id_in IN UT_TESTCASE.ID%TYPE,
      unittest_id_in IN UT_TESTCASE.UNITTEST_ID%TYPE DEFAULT NULL,
      name_in IN UT_TESTCASE.NAME%TYPE DEFAULT NULL,
      seq_in IN UT_TESTCASE.SEQ%TYPE DEFAULT 1,
      description_in IN UT_TESTCASE.DESCRIPTION%TYPE DEFAULT NULL,
      status_in IN UT_TESTCASE.STATUS%TYPE DEFAULT NULL,
      declarations_in IN UT_TESTCASE.DECLARATIONS%TYPE DEFAULT NULL,
      setup_in IN UT_TESTCASE.SETUP%TYPE DEFAULT NULL,
      teardown_in IN UT_TESTCASE.TEARDOWN%TYPE DEFAULT NULL,
      exceptions_in IN UT_TESTCASE.EXCEPTIONS%TYPE DEFAULT NULL,
      test_id_in IN UT_TESTCASE.TEST_ID%TYPE DEFAULT NULL,
      prefix_in IN UT_TESTCASE.PREFIX%TYPE DEFAULT NULL,
      assertion_in IN UT_TESTCASE.ASSERTION%TYPE DEFAULT NULL,
      inline_assertion_call_in IN UT_TESTCASE.INLINE_ASSERTION_CALL%TYPE DEFAULT 'N',
      executions_in IN UT_TESTCASE.EXECUTIONS%TYPE DEFAULT NULL,
      failures_in IN UT_TESTCASE.FAILURES%TYPE DEFAULT NULL,
      last_start_in IN UT_TESTCASE.LAST_START%TYPE DEFAULT NULL,
      last_end_in IN UT_TESTCASE.LAST_END%TYPE DEFAULT NULL,
      upd_on_dup IN BOOLEAN := FALSE
      )
   IS
   BEGIN
      INSERT INTO UT_TESTCASE (
         ID
         ,UNITTEST_ID
         ,NAME
         ,SEQ
         ,DESCRIPTION
         ,STATUS
         ,DECLARATIONS
         ,SETUP
         ,TEARDOWN
         ,EXCEPTIONS
         ,TEST_ID
         ,PREFIX
         ,ASSERTION
         ,INLINE_ASSERTION_CALL
         ,EXECUTIONS
         ,FAILURES
         ,LAST_START
         ,LAST_END
         )
      VALUES (
         id_in
         ,unittest_id_in
         ,name_in
         ,seq_in
         ,description_in
         ,status_in
         ,declarations_in
         ,setup_in
         ,teardown_in
         ,exceptions_in
         ,test_id_in
         ,prefix_in
         ,assertion_in
         ,inline_assertion_call_in
         ,executions_in
         ,failures_in
         ,last_start_in
         ,last_end_in
         );
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         IF NOT NVL (upd_on_dup, FALSE)
         THEN
            RAISE;
         ELSE
            DECLARE
               v_errm VARCHAR2(2000) := SQLERRM;
               v_rowcount INTEGER;
               dotloc INTEGER;
               leftloc INTEGER;
               c_owner ALL_CONSTRAINTS.OWNER%TYPE;
               c_name ALL_CONSTRAINTS.CONSTRAINT_NAME%TYPE;
            BEGIN
               dotloc := INSTR (v_errm,'.');
               leftloc := INSTR (v_errm,'(');
               c_owner :=SUBSTR (v_errm, leftloc+1, dotloc-leftloc-1);
               c_name := SUBSTR (v_errm, dotloc+1, INSTR (v_errm,')')-dotloc-1);

               --// Duplicate based on primary key //--
               IF 'SYS_C003641' = c_name AND /* 2000.2 'SCOTT' */ USER = c_owner
               THEN
                  upd (
                     id_in,
                     unittest_id_in,
                     name_in,
                     seq_in,
                     description_in,
                     status_in,
                     declarations_in,
                     setup_in,
                     teardown_in,
                     exceptions_in,
                     test_id_in,
                     prefix_in,
                     assertion_in,
                     inline_assertion_call_in,
                     executions_in,
                     failures_in,
                     last_start_in,
                     last_end_in,
                     v_rowcount,
                     FALSE
                     );
               ELSE
                  --// Unique index violation. Cannot recover... //--
                  RAISE;
               END IF;
            END;
         END IF;
      WHEN OTHERS
      THEN
         RAISE;
   END ins$ins;


   --// Insert 3: with fields and providing primary key. --//
   PROCEDURE ins (
      id_in IN UT_TESTCASE.ID%TYPE,
      unittest_id_in IN UT_TESTCASE.UNITTEST_ID%TYPE DEFAULT NULL,
      name_in IN UT_TESTCASE.NAME%TYPE DEFAULT NULL,
      seq_in IN UT_TESTCASE.SEQ%TYPE DEFAULT 1,
      description_in IN UT_TESTCASE.DESCRIPTION%TYPE DEFAULT NULL,
      status_in IN UT_TESTCASE.STATUS%TYPE DEFAULT NULL,
      declarations_in IN UT_TESTCASE.DECLARATIONS%TYPE DEFAULT NULL,
      setup_in IN UT_TESTCASE.SETUP%TYPE DEFAULT NULL,
      teardown_in IN UT_TESTCASE.TEARDOWN%TYPE DEFAULT NULL,
      exceptions_in IN UT_TESTCASE.EXCEPTIONS%TYPE DEFAULT NULL,
      test_id_in IN UT_TESTCASE.TEST_ID%TYPE DEFAULT NULL,
      prefix_in IN UT_TESTCASE.PREFIX%TYPE DEFAULT NULL,
      assertion_in IN UT_TESTCASE.ASSERTION%TYPE DEFAULT NULL,
      inline_assertion_call_in IN UT_TESTCASE.INLINE_ASSERTION_CALL%TYPE DEFAULT 'N',
      executions_in IN UT_TESTCASE.EXECUTIONS%TYPE DEFAULT NULL,
      failures_in IN UT_TESTCASE.FAILURES%TYPE DEFAULT NULL,
      last_start_in IN UT_TESTCASE.LAST_START%TYPE DEFAULT NULL,
      last_end_in IN UT_TESTCASE.LAST_END%TYPE DEFAULT NULL,
      upd_on_dup IN BOOLEAN := FALSE
      )
   IS
   BEGIN
      ins$ins (
         id_in,
         unittest_id_in,
         name_in,
         seq_in,
         description_in,
         status_in,
         declarations_in,
         setup_in,
         teardown_in,
         exceptions_in,
         test_id_in,
         prefix_in,
         assertion_in,
         inline_assertion_call_in,
         executions_in,
         failures_in,
         last_start_in,
         last_end_in,
         upd_on_dup
         );
   END;

   --// Insert 4: with a record and providing primary key. --//
   PROCEDURE ins (rec_in IN UT_TESTCASE%ROWTYPE,
      upd_on_dup IN BOOLEAN := FALSE
      )
   IS
   BEGIN
      ins$ins (
         rec_in.ID,
         rec_in.UNITTEST_ID,
         rec_in.NAME,
         rec_in.SEQ,
         rec_in.DESCRIPTION,
         rec_in.STATUS,
         rec_in.DECLARATIONS,
         rec_in.SETUP,
         rec_in.TEARDOWN,
         rec_in.EXCEPTIONS,
         rec_in.TEST_ID,
         rec_in.PREFIX,
         rec_in.ASSERTION,
         rec_in.INLINE_ASSERTION_CALL,
         rec_in.EXECUTIONS,
         rec_in.FAILURES,
         rec_in.LAST_START,
         rec_in.LAST_END,
         upd_on_dup
         );
   END;

--// Delete Processing --//

   PROCEDURE del (
      id_in IN UT_TESTCASE.ID%TYPE,
      rowcount_out OUT INTEGER)
   IS
   BEGIN
      DELETE FROM UT_TESTCASE
       WHERE
          ID = id_in
         ;
      rowcount_out := SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END del;

   --// Record-based delete --//
   PROCEDURE del
      (rec_in IN pky_rt,
      rowcount_out OUT INTEGER)
   IS
   BEGIN
      del (
         rec_in.id,
         rowcount_out);
   END del;

   PROCEDURE del (rec_in IN UT_TESTCASE%ROWTYPE,
      rowcount_out OUT INTEGER)
   IS
   BEGIN
      del (
         rec_in.ID,
         rowcount_out);
   END del;

   --// Delete all records for foreign key UT_TESTCASE_UNITEST_FK. //--
   PROCEDURE delby_ut_testcase_unitest_fk (
      unittest_id_in IN UT_TESTCASE.UNITTEST_ID%TYPE,
      rowcount_out OUT INTEGER
      )
   IS
   BEGIN
      DELETE FROM UT_TESTCASE
       WHERE
          UNITTEST_ID = delby_ut_testcase_unitest_fk.unittest_id_in
         ;
      rowcount_out := SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END delby_ut_testcase_unitest_fk;


   --// Program called by database initialization script to pin the package. //--
   PROCEDURE pinme
   IS
   BEGIN
      --// Doesn't do anything except cause the package to be loaded. //--
      NULL;
   END;

--// Initialization section for the package. --//
BEGIN
   NULL; -- Placeholder.
END te_ut_testcase;
/