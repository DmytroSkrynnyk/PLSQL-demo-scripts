CREATE OR REPLACE PACKAGE BODY cc_smartargs
/*
Codecheck: the QA utility for PL/SQL code
Copyright (C) 2002, Steven Feuerstein
All rights reserved

cc_smartargs: Enhanced ("smart") argument information
*/
IS
   -- Store program-level information.
   g_names           cc_names.names_rt;
   --
   -- "Raw" argument data
   g_all_arguments   cc_arguments.arguments_tt;
   --
   -- "Smart" array of arguments
   g_programs        programs_t;

   PROCEDURE initialize (program_in IN VARCHAR2, show_in IN BOOLEAN)
   IS
   BEGIN
      g_programs.delete;
      g_all_arguments.delete;
      g_names := cc_names.for_program (program_in);
   END;

   -- Manage names
   PROCEDURE show_names
   IS
   BEGIN
      cc_util.pl ('Object name = ' || g_names.object_name);
      cc_util.pl ('Program name = ' || g_names.package_name);
      cc_util.pl ('object name = ' || g_names.object_name);
   END;

   FUNCTION object_name
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN g_names.object_name;
   END;

   FUNCTION package_name
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN g_names.package_name;
   END;

   FUNCTION owner_name
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN g_names.owner;
   END;

   FUNCTION full_arg_spec (arg_in IN cc_arguments.one_argument_rt)
      RETURN VARCHAR2
   IS
      l_datatype_name   VARCHAR2 (100);
      retval            VARCHAR2 (100);
   BEGIN
      l_datatype_name := cc_types.name (arg_in.datatype);

      IF cc_types.is_rowtype (arg_in.datatype, arg_in.type_subname)
      THEN
         -- If subname is NULL, we have a %ROWTYPE declaration
         -- and nothing more can be known about this type -- without
         -- exporing below level 0 of the parameters.
         retval := cc_types.name (arg_in.datatype);
      ELSIF cc_types.is_composite_type (arg_in.datatype)
      THEN
         IF arg_in.type_subname IS NOT NULL
         THEN
            retval :=
                  arg_in.type_owner
               || '.'
               || LOWER (arg_in.type_name || '.' || arg_in.type_subname);
         ELSE
            retval := arg_in.type_owner || '.' || LOWER (arg_in.type_name);
         END IF;
      ELSE
         -- Use the actual datatype name.
         retval := cc_types.name (arg_in.datatype);
      END IF;

      IF cc_arguments.has_default (arg_in.DEFAULT_VALUE)
      THEN
         retval := retval || ' WITH DEFAULT';
      END IF;

      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         -- No name for this data type. What is it?
         raise_application_error (
            -20000,
            'No description for datatype # ' || arg_in.datatype);
   END;

   FUNCTION has_no_parameters (program_in    IN VARCHAR2,
                               overload_in   IN PLS_INTEGER)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN g_programs (program_in) (overload_in).parameters.COUNT = 0;
   END;

   FUNCTION parameter_count (program_in    IN VARCHAR2,
                             overload_in   IN PLS_INTEGER)
      RETURN INTEGER
   IS
   BEGIN
      RETURN g_programs (program_in) (overload_in).parameters.COUNT;
   END;

   FUNCTION ovld_header (program_in    IN VARCHAR2,
                         overload_in   IN PLS_INTEGER,
                         startarg_in   IN PLS_INTEGER := NULL,
                         endarg_in     IN PLS_INTEGER := NULL)
      RETURN VARCHAR2
   IS
      l_header    VARCHAR2 (2000);
      l_oneovld   one_overloading_rt := g_programs (program_in) (overload_in);
      l_onearg    VARCHAR2 (500);
      l_start     PLS_INTEGER;
      l_end       PLS_INTEGER;

      FUNCTION oneargdesc (arg_in         IN cc_arguments.one_argument_rt,
                           is_return_in   IN BOOLEAN := FALSE)
         RETURN VARCHAR2
      IS
      BEGIN
         IF is_return_in
         THEN
            RETURN cc_types.name (arg_in.datatype);
         ELSE
            RETURN    LOWER (arg_in.argument_name)
                   || ' '
                   || cc_arguments.mode_name (arg_in.in_out)
                   || ' '
                   || full_arg_spec (arg_in);
         END IF;
      END oneargdesc;
   BEGIN
      -- Construct the header for this program
      IF is_function (program_in, overload_in)
      THEN
         l_header := 'FUNCTION ' || program_in;
      ELSE
         l_header := 'PROCEDURE ' || program_in;
      END IF;

      -- Add overloading number
      l_header := l_header || '-' || overload_in;

      IF    has_no_parameters (program_in, overload_in)
         OR (startarg_in = 0 AND endarg_in = 0)
      THEN
         -- No arguments to process. We are done.
         NULL;
      ELSE
         -- More to do! For each argument, put together NAME MODE TYPE
         l_header := l_header || ' (';
         l_start := NVL (startarg_in, l_oneovld.parameters.FIRST);
         l_end := NVL (endarg_in, l_oneovld.parameters.LAST);

         FOR argindx IN l_start .. l_end
         LOOP
            l_onearg := oneargdesc (l_oneovld.parameters (argindx).toplevel);

            IF argindx = l_oneovld.parameters.FIRST
            THEN
               l_header := l_header || l_onearg;
            ELSE
               l_header := l_header || ', ' || l_onearg;
            END IF;
         END LOOP;

         l_header := l_header || ')';

         -- If a function, add a RETURN clause
         IF is_function (program_in, overload_in)
         THEN
            l_header :=
                  l_header
               || ' RETURN '
               || oneargdesc (l_oneovld.return_clause.toplevel);
         END IF;
      END IF;

      RETURN l_header || ';';
   END ovld_header;

   FUNCTION ispackage
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN g_names.ispackage;
   END;

   -- Programs to access contents of g_programs
   FUNCTION first_program
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN g_programs.FIRST;
   END;

   FUNCTION last_program
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN g_programs.LAST;
   END;

   FUNCTION next_program (program_in IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN g_programs.NEXT (program_in);
   END;

   FUNCTION prior_program (program_in IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN g_programs.PRIOR (program_in);
   END;

   FUNCTION num_programs
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN g_programs.COUNT;
   END;

   -- Programs to access contents of g_programs(overloading)
   FUNCTION first_overloading (program_in IN VARCHAR2)
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN g_programs (program_in).FIRST;
   END;

   FUNCTION last_overloading (program_in IN VARCHAR2)
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN g_programs (program_in).LAST;
   END;

   FUNCTION next_overloading (program_in       IN VARCHAR2,
                              overloading_in   IN PLS_INTEGER)
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN g_programs (program_in).NEXT (overloading_in);
   END;

   FUNCTION prior_overloading (program_in       IN VARCHAR2,
                               overloading_in   IN PLS_INTEGER)
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN g_programs (program_in).PRIOR (overloading_in);
   END;

   FUNCTION num_overloadings (program_in IN VARCHAR2)
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN g_programs (program_in).COUNT;
   END;

   FUNCTION has_overloadings (program_in IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN g_programs (program_in).COUNT > 1;
   END;

   FUNCTION is_function (program_in IN VARCHAR2, overload_in IN PLS_INTEGER)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN g_programs (program_in) (overload_in).return_clause.toplevel.object_name
                IS NOT NULL;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN FALSE;
   END;

   FUNCTION first_invocation (program_in    IN VARCHAR2,
                              overload_in   IN PLS_INTEGER)
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN NVL (g_programs (program_in) (overload_in).last_nondefault_parm,
                  0);
   END;

   FUNCTION last_invocation (program_in    IN VARCHAR2,
                             overload_in   IN PLS_INTEGER)
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN g_programs (program_in) (overload_in).parameters.COUNT;
   END;

   FUNCTION full_parameter_list (program_in    IN VARCHAR2,
                                 overload_in   IN PLS_INTEGER)
      RETURN parameters_tt
   IS
      empty_parm_list   parameters_tt;
   BEGIN
      RETURN g_programs (program_in) (overload_in).parameters;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN empty_parm_list;
   END;

   FUNCTION parameter_list (program_in     IN VARCHAR2,
                            overload_in    IN PLS_INTEGER,
                            startparm_in   IN PLS_INTEGER := 1,
                            endparm_in     IN PLS_INTEGER := NULL)
      RETURN cc_arguments.arguments_tt
   IS
      l_start        PLS_INTEGER := GREATEST (1, NVL (startparm_in, 1));
      l_end          PLS_INTEGER;
      l_parameters   parameters_tt;
      retval         cc_arguments.arguments_tt;
      empty_list     cc_arguments.arguments_tt;
   BEGIN
      l_parameters := g_programs (program_in) (overload_in).parameters;
      l_end :=
         LEAST (l_parameters.COUNT, NVL (endparm_in, l_parameters.COUNT));

      FOR parm_indx IN l_start .. l_end
      LOOP
         retval (NVL (retval.COUNT, 0) + 1) :=
            l_parameters (parm_indx).toplevel;
      END LOOP;

      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN empty_list;
   END;

   FUNCTION last_non_default (NAME_IN       IN VARCHAR2,
                              overload_in   IN PLS_INTEGER)
      RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN g_programs (NAME_IN) (overload_in).last_nondefault_parm;
   EXCEPTION
      WHEN NO_DATA_FOUND OR VALUE_ERROR
      THEN
         RETURN NULL;
   END;

   PROCEDURE load_arguments (program_in   IN VARCHAR2 := NULL,
                             show_in      IN BOOLEAN := FALSE)
   IS
      PROCEDURE compute_derived_information
      IS
         l_argindx   PLS_INTEGER;

         PROCEDURE record_the_procedure (argindx_inout IN OUT PLS_INTEGER)
         IS
         BEGIN
            g_programs (
               g_all_arguments (argindx_inout).object_name) (
               NVL (g_all_arguments (argindx_inout).overload, 0)).last_nondefault_parm :=
               0;
            argindx_inout := g_all_arguments.NEXT (argindx_inout);
         END record_the_procedure;

         PROCEDURE separate_return_clause_rows (
            argindx_inout   IN OUT PLS_INTEGER)
         IS
            c_program    CONSTANT all_arguments.object_name%TYPE
               := g_all_arguments (argindx_inout).object_name ;
            c_overload   CONSTANT PLS_INTEGER
               := NVL (g_all_arguments (argindx_inout).overload, 0) ;
            l_breakout            PLS_INTEGER := 1;

            PROCEDURE set_top_level_return_clause
            IS
            BEGIN
               g_programs (c_program) (c_overload).return_clause.toplevel :=
                  g_all_arguments (argindx_inout);
            END;
         BEGIN
            set_top_level_return_clause;

            -- All the following rows in the g_all_arguments array up until
            -- the next row with a level = 0 are PART of the return clause.
            LOOP
               argindx_inout := g_all_arguments.NEXT (argindx_inout);
               EXIT WHEN (   argindx_inout IS NULL
                          OR cc_arguments.is_toplevel_parameter (
                                g_all_arguments (argindx_inout)));
               g_programs (
                  g_all_arguments (argindx_inout).object_name) (c_overload).return_clause.breakouts (
                  l_breakout) :=
                  g_all_arguments (argindx_inout);
               l_breakout := l_breakout + 1;
            END LOOP;
         END separate_return_clause_rows;

         PROCEDURE add_new_parameter (argindx_inout IN OUT PLS_INTEGER)
         IS
            c_program    CONSTANT all_arguments.object_name%TYPE
               := g_all_arguments (argindx_inout).object_name ;
            c_overload   CONSTANT PLS_INTEGER
               := NVL (g_all_arguments (argindx_inout).overload, 0) ;
            c_position   CONSTANT PLS_INTEGER
               := g_all_arguments (argindx_inout).position ;
            l_breakout_pos        PLS_INTEGER := 1;

            PROCEDURE set_top_level_parameter (argindx_in IN PLS_INTEGER)
            IS
            BEGIN
               g_programs (c_program) (c_overload).parameters (c_position).toplevel :=
                  g_all_arguments (argindx_in);

               IF cc_arguments.not_defaulted (g_all_arguments (argindx_in))
               THEN
                  g_programs (c_program) (c_overload).last_nondefault_parm :=
                     c_position;
               END IF;
            END set_top_level_parameter;

            PROCEDURE add_breakout (argindx_in IN PLS_INTEGER)
            IS
            BEGIN
               g_programs (c_program) (c_overload).parameters (c_position).breakouts (
                  l_breakout_pos) :=
                  g_all_arguments (argindx_in);
            END add_breakout;
         BEGIN
            set_top_level_parameter (argindx_inout);

            LOOP
               argindx_inout := g_all_arguments.NEXT (argindx_inout);
               EXIT WHEN (   argindx_inout IS NULL
                          OR cc_arguments.is_toplevel_parameter (
                                g_all_arguments (argindx_inout)));
               add_breakout (argindx_inout);
               l_breakout_pos := l_breakout_pos + 1;
            END LOOP;
         END add_new_parameter;
      BEGIN                                -- main compute_derived_information
         l_argindx := g_all_arguments.FIRST;

         LOOP
            EXIT WHEN l_argindx IS NULL;

            IF cc_arguments.procedure_without_parameters (
                  g_all_arguments (l_argindx))
            THEN
               record_the_procedure (l_argindx);
            --
            ELSIF cc_arguments.is_return_clause (g_all_arguments (l_argindx))
            THEN
               separate_return_clause_rows (l_argindx);
            --
            ELSIF cc_arguments.is_toplevel_parameter (
                     g_all_arguments (l_argindx))
            THEN
               add_new_parameter (l_argindx);
            END IF;
         END LOOP;
      END compute_derived_information;
   BEGIN
      initialize (program_in, show_in);
      
      g_all_arguments := cc_arguments.fullset (program_in);

      IF g_all_arguments.COUNT > 0
      THEN
         compute_derived_information;
      END IF;
   END load_arguments;
END cc_smartargs;
/