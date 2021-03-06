CREATE OR REPLACE PACKAGE BODY te_emp
--//-----------------------------------------------------------------------
--//  ** PL/Generator Table Encapsulator for "EMP"
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
--//  Stored In:  te_emp.pkb
--//  Created On: May       09, 2003 16:31:39
--//  Created By: SCOTT
--//  PL/Generator Version: PRO-2000.2.8
--//-----------------------------------------------------------------------
IS
   --// Package name and program name globals --//
   c_pkgname VARCHAR2(30) := 'te_emp';
   g_progname VARCHAR2(30) := NULL;

   --// Update Flag private data structures. --//
   TYPE frcflg_rt IS RECORD (
      ename CHAR(1),
      job CHAR(1),
      mgr CHAR(1),
      hiredate CHAR(1),
      sal CHAR(1),
      comm CHAR(1),
      deptno CHAR(1)
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
      empno_in IN EMP.EMPNO%TYPE,
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
             empno_in
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

   PROCEDURE open_fk_deptno_all_cur (
      deptno_in IN EMP.DEPTNO%TYPE,
      close_if_open IN BOOLEAN := TRUE
      )
   IS
      v_close BOOLEAN := NVL (close_if_open, TRUE);
      v_open BOOLEAN := TRUE;
   BEGIN
      IF fk_deptno_all_cur%ISOPEN AND v_close
      THEN
         CLOSE fk_deptno_all_cur;
      ELSIF fk_deptno_all_cur%ISOPEN AND NOT v_close
      THEN
         v_open := FALSE;
      END IF;

      IF v_open
      THEN
         OPEN fk_deptno_all_cur (
            deptno_in
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

   PROCEDURE close_fk_deptno_all_cur
   IS BEGIN
      IF fk_deptno_all_cur%ISOPEN
      THEN
         CLOSE fk_deptno_all_cur;
      END IF;
   END;

   PROCEDURE closeall
   IS
   BEGIN
      close_allforpky_cur;
      close_allbypky_cur;
      close_fk_deptno_all_cur;
   END;

--// Emulate aggregate-level record operations. //--

   FUNCTION recseq (rec1 IN EMP%ROWTYPE, rec2 IN EMP%ROWTYPE)
   RETURN BOOLEAN
   IS
      unequal_records EXCEPTION;
      retval BOOLEAN;
   BEGIN
      retval := rec1.EMPNO = rec2.EMPNO OR
         (rec1.EMPNO IS NULL AND rec2.EMPNO IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.ENAME = rec2.ENAME OR
         (rec1.ENAME IS NULL AND rec2.ENAME IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.JOB = rec2.JOB OR
         (rec1.JOB IS NULL AND rec2.JOB IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.MGR = rec2.MGR OR
         (rec1.MGR IS NULL AND rec2.MGR IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.HIREDATE = rec2.HIREDATE OR
         (rec1.HIREDATE IS NULL AND rec2.HIREDATE IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.SAL = rec2.SAL OR
         (rec1.SAL IS NULL AND rec2.SAL IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.COMM = rec2.COMM OR
         (rec1.COMM IS NULL AND rec2.COMM IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      retval := rec1.DEPTNO = rec2.DEPTNO OR
         (rec1.DEPTNO IS NULL AND rec2.DEPTNO IS NULL);
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
      retval := rec1.empno = rec2.empno OR
         (rec1.empno IS NULL AND rec2.empno IS NULL);
      IF NOT NVL (retval, FALSE) THEN RAISE unequal_records; END IF;
      RETURN TRUE;
   EXCEPTION
      WHEN unequal_records THEN RETURN FALSE;
   END;

--// Is the primary key NOT NULL? //--

   FUNCTION isnullpky (
      rec_in IN EMP%ROWTYPE
      )
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN
         rec_in.EMPNO IS NULL
         ;
   END;

   FUNCTION isnullpky (
      rec_in IN pky_rt
      )
   RETURN BOOLEAN
   IS
   BEGIN
      RETURN
         rec_in.empno IS NULL
         ;
   END;

--// Query Processing --//

   FUNCTION onerow_internal (
      empno_in IN EMP.EMPNO%TYPE
      )
   RETURN EMP%ROWTYPE
   IS
      CURSOR onerow_cur
      IS
         SELECT
            EMPNO,
            ENAME,
            JOB,
            MGR,
            HIREDATE,
            SAL,
            COMM,
            DEPTNO
           FROM EMP
          WHERE
             EMPNO = empno_in
      ;
      onerow_rec EMP%ROWTYPE;
   BEGIN
      OPEN onerow_cur;
      FETCH onerow_cur INTO onerow_rec;
      CLOSE onerow_cur;
      RETURN onerow_rec;
   END onerow_internal;

   FUNCTION onerow (
      empno_in IN EMP.EMPNO%TYPE
      )
   RETURN EMP%ROWTYPE
   IS
      retval EMP%ROWTYPE;
   BEGIN
      retval := onerow_internal (
         empno_in
         );
      RETURN retval;
   END onerow;

   --// Count of all rows in table and for each foreign key. //--
   FUNCTION rowcount RETURN INTEGER
   IS
      retval INTEGER;
   BEGIN
      SELECT COUNT(*) INTO retval FROM EMP;
      RETURN retval;
   END;

   FUNCTION pkyrowcount (
      empno_in IN EMP.EMPNO%TYPE
      )
      RETURN INTEGER
   IS
      retval INTEGER;
   BEGIN
      SELECT COUNT(*)
        INTO retval
        FROM EMP
       WHERE
         EMPNO = empno_in
         ;
      RETURN retval;
   END;

   FUNCTION fk_deptnorowcount (
      deptno_in IN EMP.DEPTNO%TYPE
      )
      RETURN INTEGER
   IS
      retval INTEGER;
   BEGIN
      SELECT COUNT(*) INTO retval
        FROM EMP
       WHERE
          DEPTNO = fk_deptnorowcount.deptno_in
          ;
      RETURN retval;
   END;
--// Update Processing --//

   PROCEDURE reset$frc IS
   BEGIN
      frcflg := emptyfrc;
   END reset$frc;

   FUNCTION ename$frc (ename_in IN EMP.ENAME%TYPE DEFAULT NULL)
      RETURN EMP.ENAME%TYPE
   IS
   BEGIN
      frcflg.ename := c_set;
      RETURN ename_in;
   END ename$frc;

   FUNCTION job$frc (job_in IN EMP.JOB%TYPE DEFAULT NULL)
      RETURN EMP.JOB%TYPE
   IS
   BEGIN
      frcflg.job := c_set;
      RETURN job_in;
   END job$frc;

   FUNCTION mgr$frc (mgr_in IN EMP.MGR%TYPE DEFAULT NULL)
      RETURN EMP.MGR%TYPE
   IS
   BEGIN
      frcflg.mgr := c_set;
      RETURN mgr_in;
   END mgr$frc;

   FUNCTION hiredate$frc (hiredate_in IN EMP.HIREDATE%TYPE DEFAULT NULL)
      RETURN EMP.HIREDATE%TYPE
   IS
   BEGIN
      frcflg.hiredate := c_set;
      RETURN hiredate_in;
   END hiredate$frc;

   FUNCTION sal$frc (sal_in IN EMP.SAL%TYPE DEFAULT NULL)
      RETURN EMP.SAL%TYPE
   IS
   BEGIN
      frcflg.sal := c_set;
      RETURN sal_in;
   END sal$frc;

   FUNCTION comm$frc (comm_in IN EMP.COMM%TYPE DEFAULT NULL)
      RETURN EMP.COMM%TYPE
   IS
   BEGIN
      frcflg.comm := c_set;
      RETURN comm_in;
   END comm$frc;

   FUNCTION deptno$frc (deptno_in IN EMP.DEPTNO%TYPE DEFAULT NULL)
      RETURN EMP.DEPTNO%TYPE
   IS
   BEGIN
      frcflg.deptno := c_set;
      RETURN deptno_in;
   END deptno$frc;

   PROCEDURE upd (
      empno_in IN EMP.EMPNO%TYPE,
      ename_in IN EMP.ENAME%TYPE DEFAULT NULL,
      job_in IN EMP.JOB%TYPE DEFAULT NULL,
      mgr_in IN EMP.MGR%TYPE DEFAULT NULL,
      hiredate_in IN EMP.HIREDATE%TYPE DEFAULT NULL,
      sal_in IN EMP.SAL%TYPE DEFAULT NULL,
      comm_in IN EMP.COMM%TYPE DEFAULT NULL,
      deptno_in IN EMP.DEPTNO%TYPE DEFAULT NULL,
      rowcount_out OUT INTEGER,
      reset_in IN BOOLEAN DEFAULT TRUE
      )
   IS
   BEGIN
      UPDATE EMP SET
         ENAME = DECODE (frcflg.ename, c_set, ename_in,
            NVL (ename_in, ENAME)),
         JOB = DECODE (frcflg.job, c_set, job_in,
            NVL (job_in, JOB)),
         MGR = DECODE (frcflg.mgr, c_set, mgr_in,
            NVL (mgr_in, MGR)),
         HIREDATE = DECODE (frcflg.hiredate, c_set, hiredate_in,
            NVL (hiredate_in, HIREDATE)),
         SAL = DECODE (frcflg.sal, c_set, sal_in,
            NVL (sal_in, SAL)),
         COMM = DECODE (frcflg.comm, c_set, comm_in,
            NVL (comm_in, COMM)),
         DEPTNO = DECODE (frcflg.deptno, c_set, deptno_in,
            NVL (deptno_in, DEPTNO))
       WHERE
          EMPNO = empno_in
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
      rec_in IN EMP%ROWTYPE,
      rowcount_out OUT INTEGER,
      reset_in IN BOOLEAN DEFAULT TRUE)
   IS
   BEGIN
      upd (
         rec_in.EMPNO,
         rec_in.ENAME,
         rec_in.JOB,
         rec_in.MGR,
         rec_in.HIREDATE,
         rec_in.SAL,
         rec_in.COMM,
         rec_in.DEPTNO,
         rowcount_out,
         reset_in);
   END upd;

--// Insert Processing --//

   --// Initialize record with default values. --//
   FUNCTION initrec (allnull IN BOOLEAN := FALSE) RETURN EMP%ROWTYPE
   IS
      retval EMP%ROWTYPE;
   BEGIN
      IF allnull THEN NULL; /* Default values are NULL already. */
      ELSE
         retval.EMPNO := NULL;
         retval.ENAME := NULL;
         retval.JOB := NULL;
         retval.MGR := NULL;
         retval.HIREDATE := NULL;
         retval.SAL := NULL;
         retval.COMM := NULL;
         retval.DEPTNO := NULL;
      END IF;
      RETURN retval;
   END;

   --// Initialize record with default values. --//
   PROCEDURE initrec (
      rec_inout IN OUT EMP%ROWTYPE,
      allnull IN BOOLEAN := FALSE)
   IS
   BEGIN
      rec_inout := initrec;
   END;

   PROCEDURE ins$ins (
      empno_in IN EMP.EMPNO%TYPE,
      ename_in IN EMP.ENAME%TYPE DEFAULT NULL,
      job_in IN EMP.JOB%TYPE DEFAULT NULL,
      mgr_in IN EMP.MGR%TYPE DEFAULT NULL,
      hiredate_in IN EMP.HIREDATE%TYPE DEFAULT NULL,
      sal_in IN EMP.SAL%TYPE DEFAULT NULL,
      comm_in IN EMP.COMM%TYPE DEFAULT NULL,
      deptno_in IN EMP.DEPTNO%TYPE DEFAULT NULL,
      upd_on_dup IN BOOLEAN := FALSE
      )
   IS
   BEGIN
      INSERT INTO EMP (
         EMPNO
         ,ENAME
         ,JOB
         ,MGR
         ,HIREDATE
         ,SAL
         ,COMM
         ,DEPTNO
         )
      VALUES (
         empno_in
         ,ename_in
         ,job_in
         ,mgr_in
         ,hiredate_in
         ,sal_in
         ,comm_in
         ,deptno_in
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
               IF 'PK_EMP' = c_name AND /* 2000.2 'SCOTT' */ USER = c_owner
               THEN
                  upd (
                     empno_in,
                     ename_in,
                     job_in,
                     mgr_in,
                     hiredate_in,
                     sal_in,
                     comm_in,
                     deptno_in,
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
      empno_in IN EMP.EMPNO%TYPE,
      ename_in IN EMP.ENAME%TYPE DEFAULT NULL,
      job_in IN EMP.JOB%TYPE DEFAULT NULL,
      mgr_in IN EMP.MGR%TYPE DEFAULT NULL,
      hiredate_in IN EMP.HIREDATE%TYPE DEFAULT NULL,
      sal_in IN EMP.SAL%TYPE DEFAULT NULL,
      comm_in IN EMP.COMM%TYPE DEFAULT NULL,
      deptno_in IN EMP.DEPTNO%TYPE DEFAULT NULL,
      upd_on_dup IN BOOLEAN := FALSE
      )
   IS
   BEGIN
      ins$ins (
         empno_in,
         ename_in,
         job_in,
         mgr_in,
         hiredate_in,
         sal_in,
         comm_in,
         deptno_in,
         upd_on_dup
         );
   END;

   --// Insert 4: with a record and providing primary key. --//
   PROCEDURE ins (rec_in IN EMP%ROWTYPE,
      upd_on_dup IN BOOLEAN := FALSE
      )
   IS
   BEGIN
      ins$ins (
         rec_in.EMPNO,
         rec_in.ENAME,
         rec_in.JOB,
         rec_in.MGR,
         rec_in.HIREDATE,
         rec_in.SAL,
         rec_in.COMM,
         rec_in.DEPTNO,
         upd_on_dup
         );
   END;

--// Delete Processing --//

   PROCEDURE del (
      empno_in IN EMP.EMPNO%TYPE,
      rowcount_out OUT INTEGER)
   IS
   BEGIN
      DELETE FROM EMP
       WHERE
          EMPNO = empno_in
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
         rec_in.empno,
         rowcount_out);
   END del;

   PROCEDURE del (rec_in IN EMP%ROWTYPE,
      rowcount_out OUT INTEGER)
   IS
   BEGIN
      del (
         rec_in.EMPNO,
         rowcount_out);
   END del;

   --// Delete all records for foreign key FK_DEPTNO. //--
   PROCEDURE delby_fk_deptno (
      deptno_in IN EMP.DEPTNO%TYPE,
      rowcount_out OUT INTEGER
      )
   IS
   BEGIN
      DELETE FROM EMP
       WHERE
          DEPTNO = delby_fk_deptno.deptno_in
         ;
      rowcount_out := SQL%ROWCOUNT;
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END delby_fk_deptno;


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
END te_emp;
/
