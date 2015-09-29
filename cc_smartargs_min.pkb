CREATE OR REPLACE PACKAGE BODY cc_smartargs
IS
   -- "Raw" argument data
   g_all_arguments   cc_arguments.arguments_tt;
   
   -- "Smart" array of arguments
   g_programs        programs_t;

   PROCEDURE initialize (program_in IN VARCHAR2)
   IS
   BEGIN
      g_programs.DELETE;
      g_all_arguments.DELETE;
      g_names := cc_names.for_program (program_in);
   END;

   PROCEDURE load_arguments (
      program_in   IN   VARCHAR2
   )
   IS
      PROCEDURE normalize_arg_info
      IS
         l_argindx   PLS_INTEGER;

         PROCEDURE record_the_procedure (argindx_inout IN OUT PLS_INTEGER)
         IS
            c_program    CONSTANT all_arguments.object_name%TYPE
                            := g_all_arguments (argindx_inout).object_name;
            c_overload   CONSTANT PLS_INTEGER
                      := NVL (g_all_arguments (argindx_inout).overload, 0);
         BEGIN
            g_programs 
               (c_program)(c_overload).last_nondefault_parm := 0;
            argindx_inout := g_all_arguments.NEXT (argindx_inout);
         END record_the_procedure;

         PROCEDURE separate_return_clause_rows (
            argindx_inout   IN OUT   PLS_INTEGER
         )
         IS
            c_program    CONSTANT all_arguments.object_name%TYPE
                            := g_all_arguments (argindx_inout).object_name;
            c_overload   CONSTANT PLS_INTEGER
                      := NVL (g_all_arguments (argindx_inout).overload, 0);
            l_breakout            PLS_INTEGER                      := 1;

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
                          OR cc_arguments.is_toplevel_parameter
                                            (g_all_arguments (argindx_inout)
                                            )
                         );
               g_programs (g_all_arguments (argindx_inout).object_name)
                                                                (c_overload).return_clause.breakouts
                                                                (l_breakout) :=
                                            g_all_arguments (argindx_inout);
               l_breakout := l_breakout + 1;
            END LOOP;
         END separate_return_clause_rows;

         PROCEDURE add_new_parameter (argindx_inout IN OUT PLS_INTEGER)
         IS
            c_program    CONSTANT all_arguments.object_name%TYPE
                            := g_all_arguments (argindx_inout).object_name;
            c_overload   CONSTANT PLS_INTEGER
                      := NVL (g_all_arguments (argindx_inout).overload, 0);
            c_position   CONSTANT PLS_INTEGER
                               := g_all_arguments (argindx_inout).POSITION;
            l_breakout_pos        PLS_INTEGER                      := 1;

            PROCEDURE set_top_level_parameter (argindx_in IN PLS_INTEGER)
            IS
            BEGIN
               g_programs (c_program) (c_overload).PARAMETERS (c_position).toplevel :=
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
               g_programs 
                  (c_program) 
                     (c_overload)
                        .PARAMETERS 
                           (c_position)
                              .breakouts
                                  (l_breakout_pos) :=
                                       g_all_arguments (argindx_in);
            END add_breakout;
         BEGIN
            set_top_level_parameter (argindx_inout);

            LOOP
               argindx_inout := g_all_arguments.NEXT (argindx_inout);
               EXIT WHEN (   argindx_inout IS NULL
                          OR cc_arguments.is_toplevel_parameter
                                            (g_all_arguments (argindx_inout)
                                            )
                         );
               add_breakout (argindx_inout);
               l_breakout_pos := l_breakout_pos + 1;
            END LOOP;
         END add_new_parameter;
      BEGIN                             -- main get_column_info
         l_argindx := g_all_arguments.FIRST;

         LOOP
            EXIT WHEN l_argindx IS NULL;

            IF cc_arguments.procedure_without_parameters
                                               (g_all_arguments (l_argindx)
                                               )
            THEN
               record_the_procedure (l_argindx);
            --
            ELSIF cc_arguments.is_return_clause (g_all_arguments (l_argindx)
                                                )
            THEN
               separate_return_clause_rows (l_argindx);
            --
            ELSIF cc_arguments.is_toplevel_parameter
                                                (g_all_arguments (l_argindx)
                                                )
            THEN
               add_new_parameter (l_argindx);
            END IF;
         END LOOP;
      END normalize_arg_info;
   BEGIN
      initialize (program_in);
      
      g_all_arguments := cc_arguments.fullset (program_in);

      IF g_all_arguments.COUNT > 0
      THEN
         normalize_arg_info;
      END IF;
   END load_arguments;
END cc_smartargs;
/