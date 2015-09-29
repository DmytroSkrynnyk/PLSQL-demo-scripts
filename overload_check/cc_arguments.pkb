CREATE OR REPLACE PACKAGE BODY cc_arguments
/*
Codecheck: the QA utility for PL/SQL code
Copyright (C) 2002, Steven Feuerstein
All rights reserved

cc_arguments: API to argument information consolidated from
              ALL_ARGUMENTS and DBMS_DESCRIBE
*/
IS
   TYPE mode_names_t IS TABLE OF VARCHAR2 (6)
      INDEX BY BINARY_INTEGER;

   g_mode_names   mode_names_t;

   FUNCTION mode_name (code_in IN PLS_INTEGER)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN g_mode_names (code_in);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;

   FUNCTION has_default (default_in IN PLS_INTEGER)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN default_in = c_has_default;
   END;

   FUNCTION not_defaulted (arg_in IN one_argument_rt)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN NOT has_default (arg_in.DEFAULT_VALUE);
   END;

   FUNCTION is_toplevel_parameter (arg_in IN one_argument_rt)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN arg_in.data_level = c_top_level;
   END;

   FUNCTION is_return_clause (arg_in IN one_argument_rt)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN arg_in.POSITION = c_return_pos;
   END;

   FUNCTION procedure_without_parameters (arg_in IN one_argument_rt)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN     arg_in.POSITION = 1
             AND arg_in.data_level = c_top_level
             AND arg_in.argument_name IS NULL;
   END;

   FUNCTION in_same_family (
      arg1_in   IN   one_argument_rt,
      arg2_in   IN   one_argument_rt
   )
      RETURN BOOLEAN
   IS
      retval   BOOLEAN;

      FUNCTION is_same (val1 VARCHAR2, val2 VARCHAR2)
         RETURN BOOLEAN
      IS
      BEGIN
         RETURN (val1 = val2 OR (val1 IS NULL AND val2 IS NULL));
      END;
   BEGIN
       -- If a complex datatype, need to examine the TYPE_* fields.
      -- Otherwise, just compare the data type values.      
      IF     cc_types.is_rowtype (arg1_in.datatype, arg1_in.type_subname)
         AND cc_types.is_rowtype (arg2_in.datatype, arg2_in.type_subname)
      THEN
         -- Two different %ROWTYPES. Flag as TRUE, let them figure it out.
         retval := TRUE;
      ELSIF cc_types.is_composite_type (arg1_in.datatype)
      THEN
         -- Make sure all the TYPE_* columns are the same.
         retval :=
                 is_same (arg1_in.type_owner, arg2_in.type_owner)
             AND is_same (arg1_in.type_name, arg2_in.type_name)
             AND is_same (arg1_in.type_subname, arg2_in.type_subname)
             AND is_same (arg1_in.pls_type, arg2_in.pls_type);
      ELSE
         retval :=
                cc_types.in_same_family (arg1_in.datatype, arg2_in.datatype);
      END IF;

      RETURN NVL (retval, FALSE);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN FALSE;
   END;

   PROCEDURE show (
      program_in   IN   VARCHAR2,
      start_in     IN   PLS_INTEGER := NULL,
      end_in       IN   PLS_INTEGER := NULL
   )
   IS
      v_onearg          one_argument_rt;
      v_last_overload   all_arguments.overload%TYPE;
      l_start           PLS_INTEGER;
      l_end             PLS_INTEGER;
      l_arguments       arguments_tt;

      FUNCTION strval (num IN INTEGER, padto IN INTEGER)
         RETURN VARCHAR2
      IS
      BEGIN
         RETURN LPAD (NVL (TO_CHAR (num), 'N/A'), padto) || ' ';
      END;
   BEGIN
      l_arguments := fullset (program_in);
      l_start := NVL (start_in, l_arguments.FIRST);
      l_end := NVL (end_in, l_arguments.LAST);

      IF l_arguments.COUNT > 0
      THEN
         cc_util.pl ('OvLd Pos Lev Type         Name                               Mode  Def Len'
                    );
         cc_util.pl ('---- --- --- ------------ --------------------------------- ------ --- ----'
                    );

         FOR argrow IN NVL (start_in, l_arguments.FIRST) .. NVL (end_in,
                                                                 l_arguments.LAST
                                                                )
         LOOP
            v_onearg := l_arguments (argrow);

            IF v_last_overload != v_onearg.overload
            THEN
               cc_util.pl ('----');
               v_last_overload := v_onearg.overload;
            ELSIF v_last_overload IS NULL
            THEN
               v_last_overload := v_onearg.overload;
            END IF;

            cc_util.pl (   strval (v_onearg.overload, 4)
                        || strval (v_onearg.POSITION, 4)
                        || strval (v_onearg.data_level, 3)
                        || strval (v_onearg.datatype, 10)
                        || RPAD (   LPAD (' ', 2 * v_onearg.data_level, ' ')
                                 || NVL (v_onearg.argument_name,
                                         'RETURN Value'
                                        ),
                                 35
                                )
                        || RPAD (g_mode_names (v_onearg.in_out), 6)
                        || strval (v_onearg.DEFAULT_VALUE, 4)
                       );
         END LOOP;
      END IF;
   END;

   FUNCTION onerow (
      object_name_in     IN   VARCHAR2,
      package_name_in    IN   VARCHAR2,
      owner_in           IN   VARCHAR2,
      overload_in        IN   PLS_INTEGER,
      argument_name_in   IN   VARCHAR2,
      position_in        IN   PLS_INTEGER,
      level_in           IN   PLS_INTEGER
   )
      RETURN all_arguments%ROWTYPE
   IS
      empty_rec   all_arguments%ROWTYPE;
      retval      all_arguments%ROWTYPE;
   BEGIN
      SELECT *
        INTO retval
        FROM all_arguments
       WHERE object_name = object_name_in
         AND (   package_name = package_name_in
              OR (package_name IS NULL AND package_name_in IS NULL)
             )
         AND owner = owner_in
         AND (   overload = overload_in
              OR (    overload IS NULL
                  AND (overload_in = 0 OR overload_in IS NULL)
                 )
             )
         AND POSITION = position_in
         AND LEVEL = level_in
         AND argument_name = argument_name_in;

      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN empty_rec;
   END;

   FUNCTION fullset (program_in IN VARCHAR2, show_in IN BOOLEAN := FALSE)
      RETURN arguments_tt
   IS
      l_index           PLS_INTEGER;
      l_names           cc_names.names_rt;
      retval            arguments_tt;

      CURSOR distinct_programs_cur (
         owner_in          IN   VARCHAR2,
         package_name_in   IN   VARCHAR2,
         object_name_in    IN   VARCHAR2
      )
      IS
         SELECT DISTINCT owner, package_name, object_name
                    FROM all_arguments
                   WHERE owner = owner_in
                     AND (   (    package_name = package_name_in
                              AND (   object_name = object_name_in
                                   OR object_name_in IS NULL
                                  )
                             )
                          OR (    package_name IS NULL
                              AND package_name_in IS NULL
                              AND object_name = object_name_in
                             )
                         );

      /* PL/SQL tables which will hold the output from calls to
      DBMS_DESCRIBE.DESCRIBE_PROCEDURE */
      l_overload        DBMS_DESCRIBE.number_table;
      l_position        DBMS_DESCRIBE.number_table;
      l_level           DBMS_DESCRIBE.number_table;
      l_argument_name   DBMS_DESCRIBE.varchar2_table;
      l_datatype        DBMS_DESCRIBE.number_table;
      l_default_value   DBMS_DESCRIBE.number_table;
      l_in_out          DBMS_DESCRIBE.number_table;
      l_length          DBMS_DESCRIBE.number_table;
      l_precision       DBMS_DESCRIBE.number_table;
      l_scale           DBMS_DESCRIBE.number_table;
      l_radix           DBMS_DESCRIBE.number_table;
      l_spare           DBMS_DESCRIBE.number_table;

      PROCEDURE get_dbms_describe_info (
         rec_in   IN   distinct_programs_cur%ROWTYPE
      )
      IS
         l_name   cc_names.combined_name_t
            := cc_names.combined (rec_in.owner,
                                  rec_in.package_name,
                                  rec_in.object_name
                                 );
      BEGIN
         DBMS_DESCRIBE.describe_procedure (l_name,
                                           NULL,
                                           NULL,
                                           l_overload,
                                           l_position,
                                           l_level,
                                           l_argument_name,
                                           l_datatype,
                                           l_default_value,
                                           l_in_out,
                                           l_length,
                                           l_precision,
                                           l_scale,
                                           l_radix,
                                           l_spare
                                          );
      END;

      PROCEDURE transfer_data (
         rec    IN   distinct_programs_cur%ROWTYPE,
         indx   IN   PLS_INTEGER
      )
      IS
         l_argindx   PLS_INTEGER := NVL (retval.LAST, 0) + 1;

         PROCEDURE copy_to_arguments_array (
            rec_in       IN   distinct_programs_cur%ROWTYPE,
            ddindx_in    IN   PLS_INTEGER,
            argindx_in   IN   PLS_INTEGER
         )
         IS
         BEGIN
            retval (argindx_in).object_name := rec_in.object_name;
            retval (argindx_in).package_name := rec_in.package_name;
            retval (argindx_in).owner := rec_in.owner;
            retval (argindx_in).overload := l_overload (ddindx_in);
            retval (argindx_in).POSITION := l_position (ddindx_in);
            retval (argindx_in).data_level := l_level (ddindx_in);
            retval (argindx_in).argument_name := l_argument_name (ddindx_in);
            retval (argindx_in).datatype := l_datatype (ddindx_in);
            retval (argindx_in).DEFAULT_VALUE := l_default_value (ddindx_in);
            retval (argindx_in).in_out := l_in_out (ddindx_in);
         END;

         PROCEDURE add_all_arguments_info (
            argument_inout   IN OUT   one_argument_rt
         )
         IS
            l_argument   all_arguments%ROWTYPE
               := onerow (argument_inout.object_name,
                          argument_inout.package_name,
                          argument_inout.owner,
                          argument_inout.overload,
                          argument_inout.argument_name,
                          argument_inout.POSITION,
                          argument_inout.data_level
                         );
         BEGIN
            argument_inout.character_set_name :=
                                             l_argument.character_set_name;
            argument_inout.type_owner := l_argument.type_owner;
            argument_inout.type_name := l_argument.type_name;
            argument_inout.type_subname := l_argument.type_subname;
            argument_inout.type_link := l_argument.type_link;
            argument_inout.pls_type := l_argument.pls_type;
            argument_inout.char_length := l_argument.char_length;
            argument_inout.char_used := l_argument.char_used;
         END add_all_arguments_info;
      BEGIN
         copy_to_arguments_array (rec, indx, l_argindx);
         add_all_arguments_info (retval (l_argindx));
      END transfer_data;
   BEGIN -- main fullset
      l_names := cc_names.for_program (program_in);

      FOR rec IN distinct_programs_cur (l_names.owner,
                                        l_names.package_name,
                                        l_names.object_name
                                       )
      LOOP
         get_dbms_describe_info (rec);
         l_index := l_argument_name.FIRST;

         LOOP
            EXIT WHEN l_index IS NULL;
            transfer_data (rec, l_index);
            l_index := l_argument_name.NEXT (l_index);
         END LOOP;
      END LOOP;

      RETURN retval;
   END fullset;

   -- Utility program to compare the contents of 
   -- ALL_ARGUMENTS to DBMS_DESCRIBE
   PROCEDURE compare_aa_to_dd (program_in IN VARCHAR2)
   IS
      l_names           cc_names.names_rt;
      l_argument        all_arguments%ROWTYPE;
--
      l_overload        DBMS_DESCRIBE.number_table;
      l_position        DBMS_DESCRIBE.number_table;
      l_level           DBMS_DESCRIBE.number_table;
      l_argument_name   DBMS_DESCRIBE.varchar2_table;
      l_datatype        DBMS_DESCRIBE.number_table;
      l_default_value   DBMS_DESCRIBE.number_table;
      l_in_out          DBMS_DESCRIBE.number_table;
      l_length          DBMS_DESCRIBE.number_table;
      l_precision       DBMS_DESCRIBE.number_table;
      l_scale           DBMS_DESCRIBE.number_table;
      l_radix           DBMS_DESCRIBE.number_table;
      l_spare           DBMS_DESCRIBE.number_table;

      CURSOR distinct_programs_cur (
         owner_in          IN   VARCHAR2,
         package_name_in   IN   VARCHAR2,
         object_name_in    IN   VARCHAR2
      )
      IS
         SELECT DISTINCT owner, package_name, object_name
                    FROM all_arguments
                   WHERE owner = owner_in
                     AND (   (    package_name = package_name_in
                              AND (   object_name = object_name_in
                                   OR object_name_in IS NULL
                                  )
                             )
                          OR (    package_name IS NULL
                              AND package_name_in IS NULL
                              AND object_name = object_name_in
                             )
                         );
   BEGIN
      l_names := cc_names.for_program (program_in);

      FOR rec IN distinct_programs_cur (l_names.owner,
                                        l_names.package_name,
                                        l_names.object_name
                                       )
      LOOP
         -- Call DBMS_DESCRIBE to retrieve the information
         DBMS_DESCRIBE.describe_procedure (cc_names.combined (rec.owner,
                                                              rec.package_name,
                                                              rec.object_name
                                                             ),
                                           NULL,
                                           NULL,
                                           l_overload,
                                           l_position,
                                           l_level,
                                           l_argument_name,
                                           l_datatype,
                                           l_default_value,
                                           l_in_out,
                                           l_length,
                                           l_precision,
                                           l_scale,
                                           l_radix,
                                           l_spare
                                          );

         IF l_argument_name.FIRST IS NOT NULL
         THEN
            cc_util.pl (   RPAD ('Argument', 20)
                        || ' '
                        || RPAD ('ALL_ARGUMENTS', 20)
                        || ' DBMS_DESCRIBE'
                       );
            cc_util.pl (   RPAD ('-', 20, '-')
                        || ' '
                        || RPAD ('-', 30, '-')
                        || ' -------------'
                       );

            FOR indx IN l_argument_name.FIRST .. l_argument_name.LAST
            LOOP
               l_argument :=
                  cc_arguments.onerow (rec.object_name,
                                       rec.package_name,
                                       rec.owner,
                                       l_overload (indx),
                                       l_argument_name (indx),
                                       l_position (indx),
                                       l_level (indx)
                                      );
               -- Show the ALL ARGS and DBMS_DESCRIBE datatype information
               cc_util.pl (   RPAD (l_argument_name (indx), 21)
                           || RPAD (l_argument.data_type, 31)
                           || l_datatype (indx)
                          );
            END LOOP;
         END IF;
      END LOOP;
   END compare_aa_to_dd;
BEGIN
   g_mode_names (c_in) := 'IN';
   g_mode_names (c_out) := 'OUT';
   g_mode_names (c_inout) := 'IN OUT';
END cc_arguments;
/