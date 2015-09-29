CREATE OR REPLACE PACKAGE BODY codecheck
/*
Codecheck: the QA utility for PL/SQL code
Copyright (C) 2002, Steven Feuerstein
All rights reserved

Codecheck: the code check engine
*/
IS
   c_version   CONSTANT VARCHAR2 (10) := '2.1.1';

   -- Should this even be here or does it belong in smartargs?
   FUNCTION same_program_types (
      program_in     IN   VARCHAR2
     ,overload1_in   IN   PLS_INTEGER
     ,overload2_in   IN   PLS_INTEGER
   )
      RETURN BOOLEAN
   IS
      l_arg1_is_function   BOOLEAN
                       := cc_smartargs.is_function (program_in, overload1_in);
      l_arg2_is_function   BOOLEAN
                       := cc_smartargs.is_function (program_in, overload2_in);
   BEGIN
      RETURN (   (l_arg1_is_function AND l_arg2_is_function)
              OR (NOT l_arg1_is_function AND NOT l_arg2_is_function)
             );
   END same_program_types;

   -- Analyze parameters for similarity

   PROCEDURE overloadings (
      package_in                IN   VARCHAR2
     ,verbose_in                IN   BOOLEAN := FALSE
     ,reload_argument_info_in   IN   BOOLEAN := TRUE
   )
   IS
      l_program_name   all_arguments.object_name%TYPE;

      PROCEDURE initialize
      IS
      BEGIN
         IF reload_argument_info_in
         THEN
            cc_smartargs.load_arguments (package_in);
         END IF;

         cc_error.assert (cc_smartargs.ispackage
                         ,cc_error.c_not_a_package
                         ,package_in
                         );
         cc_report.initialize (package_in);
      END initialize;

      PROCEDURE check_for_similarity (
         program_in     IN   VARCHAR2
        ,overload1_in   IN   PLS_INTEGER
        ,lastarg1_in    IN   PLS_INTEGER
        ,overload2_in   IN   PLS_INTEGER
        ,lastarg2_in    IN   PLS_INTEGER
      )
      IS
         arglist1     cc_arguments.arguments_tt
            := cc_smartargs.parameter_list (program_in
                                           ,overload1_in
                                           ,1
                                           ,lastarg1_in
                                           );
         arglist2     cc_arguments.arguments_tt
            := cc_smartargs.parameter_list (program_in
                                           ,overload2_in
                                           ,1
                                           ,lastarg2_in
                                           );
         l_numargs1   PLS_INTEGER               := arglist1.COUNT;
         l_numargs2   PLS_INTEGER               := arglist2.COUNT;

         PROCEDURE compare_each_parameter
         IS
            arg_row       PLS_INTEGER := 1;
            too_similar   BOOLEAN     := TRUE;
         BEGIN
            WHILE too_similar AND arg_row IS NOT NULL
                  AND arg_row <= l_numargs1
            LOOP
               too_similar :=
                  cc_arguments.in_same_family (arglist1 (arg_row)
                                              ,arglist2 (arg_row)
                                              );
               arg_row := arglist1.NEXT (arg_row);
            END LOOP;

            IF /* still */ too_similar
            THEN
               cc_report.ambig_ovld (cc_smartargs.owner_name
                                    ,cc_smartargs.package_name
                                    ,program_in
                                    ,overload1_in
                                    ,1
                                    ,lastarg1_in
                                    ,overload2_in
                                    ,1
                                    ,lastarg2_in
                                    );
            END IF;
         END compare_each_parameter;
      BEGIN
         IF l_numargs1 != l_numargs2
         THEN
            -- Diff # of arguments, nothing to report.
            NULL;
         ELSIF l_numargs1 = 0 AND l_numargs2 = 0
         THEN
            -- Neither has any arguments. Must be too similar!
            cc_report.ambig_ovld_noargs (cc_smartargs.owner_name
                                        ,cc_smartargs.package_name
                                        ,program_in
                                        ,overload1_in
                                        ,overload2_in
                                        );
         ELSE
            compare_each_parameter;
         END IF;
      END;

      PROCEDURE compare_all_invocations (
         program_in        IN   VARCHAR2
        ,check_this_in     IN   PLS_INTEGER
        ,against_this_in   IN   PLS_INTEGER
      )
      IS
      BEGIN

         <<check_this>>
         FOR check_this_perm IN
            cc_smartargs.first_invocation (program_in, check_this_in) .. cc_smartargs.last_invocation (program_in
                                                                                                      ,check_this_in
                                                                                                      )
         LOOP

            <<against_this>>
            FOR against_this_perm IN
               cc_smartargs.first_invocation (program_in, against_this_in) .. cc_smartargs.last_invocation (program_in
                                                                                                           ,against_this_in
                                                                                                           )
            LOOP
               check_for_similarity (program_in
                                    ,check_this_in
                                    ,check_this_perm
                                    ,against_this_in
                                    ,against_this_perm
                                    );
            END LOOP against_this;
         END LOOP check_this;
      END compare_all_invocations;

      PROCEDURE compare_overloadings (
         program_in           IN   all_arguments.object_name%TYPE
        ,check_this_ovld_in   IN   PLS_INTEGER
      )
      IS
      BEGIN
         FOR against_this_ovld IN
             check_this_ovld_in + 1 .. cc_smartargs.last_overloading (program_in
                                                                     )
         LOOP
            IF same_program_types (program_in
                                  ,check_this_ovld_in
                                  ,against_this_ovld
                                  )
            THEN
               compare_all_invocations (program_in
                                       ,check_this_ovld_in
                                       ,against_this_ovld
                                       );
            END IF;
         END LOOP;
      END compare_overloadings;
   BEGIN -- main overloadings
      initialize;
      l_program_name := cc_smartargs.first_program;

      LOOP
         EXIT WHEN l_program_name IS NULL;

         IF cc_smartargs.has_overloadings (l_program_name)
         THEN
            FOR overloading IN
               cc_smartargs.first_overloading (l_program_name) .. cc_smartargs.last_overloading (l_program_name
                                                                                                )
            LOOP
               compare_overloadings (l_program_name, overloading);
            END LOOP;
         END IF;

         l_program_name := cc_smartargs.next_program (l_program_name);
      END LOOP;

      cc_report.show_ambig_ovld_results (package_in, verbose_in);
   END overloadings;

   PROCEDURE naming_conventions (
      program_in                IN   VARCHAR2
     ,check_parameters_in       IN   BOOLEAN := TRUE
     ,check_programs_in         IN   BOOLEAN := TRUE
     ,prog_prefix_in            IN   VARCHAR2 := NULL
     ,prog_suffix_in            IN   VARCHAR2 := NULL
     ,type_as_prefix_delim_in   IN   VARCHAR2 := NULL
     ,param_prefix_in           IN   VARCHAR2 := NULL
     ,param_suffix_in           IN   VARCHAR2 := NULL
     ,mode_as_suffix_delim_in   IN   VARCHAR2 := NULL
     ,upper_in                  IN   BOOLEAN := TRUE
     ,verbose_in                IN   BOOLEAN := FALSE
     ,reload_argument_info_in   IN   BOOLEAN := TRUE
   )
   IS
      l_program_name   all_objects.object_name%TYPE;

      PROCEDURE initialize
      IS
      BEGIN
         IF reload_argument_info_in
         THEN
            cc_smartargs.load_arguments (program_in);
         END IF;

         cc_report.initialize (program_in);
      END initialize;

      PROCEDURE check_overloadings (l_program_name IN VARCHAR2)
      IS
         PROCEDURE check_program_name (
            check_programs_in   IN   BOOLEAN
           ,program_in          IN   VARCHAR2
           ,overload_in         IN   PLS_INTEGER
         )
         IS
            l_prefix   cc_names.combined_name_t;

            FUNCTION prefix (
               prog_prefix_in            IN   VARCHAR2 := NULL
              ,type_as_prefix_delim_in   IN   VARCHAR2 := NULL
            )
               RETURN VARCHAR2
            IS
               retval   cc_names.combined_name_t;
            BEGIN
               IF type_as_prefix_delim_in IS NULL
               THEN
                  retval := prog_prefix_in;
               ELSIF cc_smartargs.is_function (program_in, overload_in)
               THEN
                  retval := 'f' || type_as_prefix_delim_in;
               ELSE
                  retval := 'p' || type_as_prefix_delim_in;
               END IF;

               RETURN retval;
            END prefix;
         BEGIN
            IF check_programs_in
            THEN
               l_prefix := prefix (prog_prefix_in, type_as_prefix_delim_in);

               IF NOT cc_names.name_ok (program_in
                                       ,l_prefix
                                       ,prog_suffix_in
                                       ,upper_in
                                       )
               THEN
                  cc_report.bad_name (program_in
                                     ,cc_names.constructed_name (l_prefix
                                                                ,prog_suffix_in
                                                                ,'<PROGRAM>'
                                                                ,upper_in
                                                                )
                                     );
               END IF;
            END IF;
         END check_program_name;

         PROCEDURE check_parameters (
            check_parameters_in   IN   BOOLEAN
           ,program_in            IN   VARCHAR2
           ,overload_in           IN   PLS_INTEGER
         )
         IS
            l_arguments   cc_arguments.arguments_tt;
            l_mode        cc_names.combined_name_t;
         BEGIN
            l_arguments :=
                        cc_smartargs.parameter_list (program_in, overload_in);

            FOR indx IN 1 .. cc_smartargs.parameter_count (program_in
                                                          ,overload_in
                                                          )
            LOOP
               IF mode_as_suffix_delim_in IS NOT NULL
               THEN
                  l_mode :=
                           cc_arguments.mode_name (l_arguments (indx).in_out);
               END IF;

               IF NOT cc_names.parameter_name_ok (program_in
                                                 ,param_prefix_in
                                                 ,param_suffix_in
                                                 ,l_mode
                                                 ,mode_as_suffix_delim_in
                                                 ,upper_in
                                                 )
               THEN
                  cc_report.bad_name (   'PARAMETER '
                                      || program_in
                                      || '.'
                                      || l_arguments (indx).argument_name
                                     ,cc_names.constructed_parameter_name (param_prefix_in
                                                                          ,param_suffix_in
                                                                          ,l_mode
                                                                          ,mode_as_suffix_delim_in
                                                                          ,'<PARAMETER>'
                                                                          ,upper_in
                                                                          )
                                     );
               END IF;
            END LOOP;
         END check_parameters;
      BEGIN
         FOR overloading IN
            cc_smartargs.first_overloading (l_program_name) .. cc_smartargs.last_overloading (l_program_name
                                                                                             )
         LOOP
            check_program_name (check_programs_in
                               ,l_program_name
                               ,overloading
                               );
            check_parameters (check_parameters_in, l_program_name
                             ,overloading);
         END LOOP;
      END;
   BEGIN
      initialize;
      l_program_name := cc_smartargs.first_program;

      LOOP
         EXIT WHEN l_program_name IS NULL;
         check_overloadings (l_program_name);
         l_program_name := cc_smartargs.next_program (l_program_name);
      END LOOP;

      cc_report.show_bad_names (l_program_name, verbose_in);
   END naming_conventions;

   FUNCTION VERSION
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN c_version;
   END;
END codecheck;
/
