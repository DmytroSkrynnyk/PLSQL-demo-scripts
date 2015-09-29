PROCEDURE add_new_parameter (argindx_inout IN OUT PLS_INTEGER)
IS
   l_breakout_pos   PLS_INTEGER := 1;
BEGIN
   g_programs
      (g_all_arguments (argindx_inout).object_name)
         (NVL (g_all_arguments (argindx_inout).overload,0))
            .PARAMETERS
              (g_all_arguments (argindx_inout).POSITION)
                 .toplevel := g_all_arguments (argindx_in);

   IF cc_arguments.not_defaulted (
         g_all_arguments (argindx_in))
   THEN
      g_programs
         (g_all_arguments (argindx_inout).object_name)
            (NVL (g_all_arguments (argindx_inout).overload, 0))
              .last_nondefault_parm :=
                   g_all_arguments (argindx_inout).POSITION;
   END IF;

   LOOP
      argindx_inout := g_all_arguments.NEXT (argindx_inout);

      EXIT WHEN (   argindx_inout IS NULL
                 OR cc_arguments.is_toplevel_parameter (
                       g_all_arguments (argindx_inout))
                );

      g_programs
         (g_all_arguments (argindx_inout).object_name)
            (NVL (g_all_arguments (argindx_inout).overload,0))
               .PARAMETERS (g_all_arguments (argindx_inout).POSITION)
                  .breakouts (l_breakout_pos) :=
                      g_all_arguments (argindx_in);
      l_breakout_pos := l_breakout_pos + 1;
   END LOOP;
END add_new_parameter;