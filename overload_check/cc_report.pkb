/* Formatted on 2002/11/16 17:31 (Formatter Plus v4.7.0) */
CREATE OR REPLACE PACKAGE BODY cc_report
/*
Codecheck: the QA utility for PL/SQL code
Copyright (C) 2002, Steven Feuerstein
All rights reserved

cc_report: reporting API
*/
IS
   c_where_clause   CONSTANT VARCHAR2 (1000)
      := 'WHERE owner = :owner
       AND (   (    package_name = :package
                AND (   object_name = :object
                     OR :object IS NULL
                    )
               )
            OR (    package_name IS NULL
                AND :package IS NULL
                AND object_name = :object
               )
           )';

   PROCEDURE ambig_ovld (
      owner_in          IN   VARCHAR2,
      package_name_in   IN   VARCHAR2,
      object_name_in    IN   VARCHAR2,
      overload1_in      IN   PLS_INTEGER,
      startarg1_in      IN   PLS_INTEGER,
      endarg1_in        IN   PLS_INTEGER,
      overload2_in      IN   PLS_INTEGER,
      startarg2_in      IN   PLS_INTEGER,
      endarg2_in        IN   PLS_INTEGER
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      INSERT INTO cc_ambig_ovld_results
                  (object_name, package_name, owner, overload1,
                   startarg1, endarg1, overload2, startarg2,
                   endarg2
                  )
           VALUES (object_name_in, package_name_in, owner_in, overload1_in,
                   startarg1_in, endarg1_in, overload2_in, startarg2_in,
                   endarg2_in
                  );

      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
   END;

   PROCEDURE ambig_ovld_noargs (
      owner_in          IN   VARCHAR2,
      package_name_in   IN   VARCHAR2,
      object_name_in    IN   VARCHAR2,
      overload1_in      IN   PLS_INTEGER,
      overload2_in      IN   PLS_INTEGER
   )
   IS
   BEGIN
      ambig_ovld (
         owner_in          => owner_in,
         package_name_in   => package_name_in,
         object_name_in    => object_name_in,
         overload1_in      => overload1_in,
         startarg1_in      => 0,
         endarg1_in        => 0,
         overload2_in      => overload2_in,
         startarg2_in      => 0,
         endarg2_in        => 0); 
   END;
      
   PROCEDURE initialize (package_in IN VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      l_names   cc_names.names_rt := cc_names.for_program (package_in);
   BEGIN
      EXECUTE IMMEDIATE    'DELETE FROM cc_ambig_ovld_results'
                        || ' '
                        || c_where_clause
         -- Duplicate bindings...
      USING             l_names.owner,
                        l_names.package_name,
                        l_names.object_name,
                        l_names.object_name,
                        l_names.package_name,
                        l_names.object_name;
      COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
   END;

   PROCEDURE show_ambig_ovld_results (
      package_in   IN   VARCHAR2,
      verbose_in   IN   BOOLEAN := FALSE
   )
   IS
      l_names                cc_names.names_rt;

      TYPE results_tt IS TABLE OF cc_ambig_ovld_results%ROWTYPE
         INDEX BY BINARY_INTEGER;

      l_ambig_ovld_results   results_tt;

      PROCEDURE initialize_display
      IS
      BEGIN
         l_names := cc_names.for_program (package_in);
         cc_util.pl ('');
         cc_util.pl (   'Ambiguous Overloading Code Check for '
                     || cc_names.combined (l_names)
                    );
         cc_util.pl ('');
      END;

      PROCEDURE retrieve_results
      IS
      BEGIN
         EXECUTE IMMEDIATE    'SELECT * FROM cc_ambig_ovld_results'
                           || ' '
                           || c_where_clause
            BULK COLLECT INTO l_ambig_ovld_results
            USING          l_names.owner,
                           l_names.package_name,
                           l_names.object_name,
                           l_names.object_name,
                           l_names.package_name,
                           l_names.object_name;
      END;

      PROCEDURE display_results
      IS
         FUNCTION arg_clause (start_in IN PLS_INTEGER, end_in IN PLS_INTEGER)
            RETURN VARCHAR2
         IS
         BEGIN
            IF start_in = 0 AND end_in = 0
            THEN
               RETURN NULL;
            ELSE
               RETURN start_in || '-' || end_in;
            END IF;
         END;

         PROCEDURE display_full_headers (
            rec_in   IN   cc_ambig_ovld_results%ROWTYPE
         )
         IS
         BEGIN
            cc_util.pl (cc_smartargs.ovld_header (rec_in.object_name,
                                                  rec_in.overload1,
                                                  rec_in.startarg1,
                                                  rec_in.endarg1
                                                 )
                       );
            cc_util.pl ('  and');
            cc_util.pl (cc_smartargs.ovld_header (rec_in.object_name,
                                                  rec_in.overload2,
                                                  rec_in.startarg2,
                                                  rec_in.endarg2
                                                 )
                       );
            cc_util.pl ('-');
         END display_full_headers;

         PROCEDURE display_shorthand (rec_in IN cc_ambig_ovld_results%ROWTYPE)
         IS
         BEGIN
            cc_util.pl (   rec_in.object_name
                        || '-'
                        || rec_in.overload1
                        || ' ('
                        || arg_clause (rec_in.startarg1, rec_in.endarg1)
                        || ') and '
                        || rec_in.object_name
                        || '-'
                        || rec_in.overload2
                        || ' ('
                        || arg_clause (rec_in.startarg2, rec_in.endarg2)
                        || ')'
                       );
         END display_shorthand;
      BEGIN -- main display_results
         IF l_ambig_ovld_results.COUNT = 0
         THEN
            cc_util.pl ('>> No ambiguous overloadings detected.');
         ELSE
            FOR indx IN
               l_ambig_ovld_results.FIRST .. l_ambig_ovld_results.LAST
            LOOP
               IF verbose_in
               THEN
                  display_full_headers (l_ambig_ovld_results (indx));
               ELSE
                  display_shorthand (l_ambig_ovld_results (indx));
               END IF;
            END LOOP;
         END IF;
      END display_results;
   BEGIN -- main show_ambig_ovld_results
      initialize_display;
      retrieve_results;
      display_results;
   END show_ambig_ovld_results;
   
      PROCEDURE bad_name (
      name_in IN VARCHAR2
	 ,shouldbe_name_in in VARCHAR2
   ) is begin null; end;
   
         PROCEDURE show_bad_names (
      program_in IN VARCHAR2
     ,verbose_in IN BOOLEAN := FALSE
   ) is begin null; end;
END cc_report;
/