/* Formatted on 2002/11/06 22:52 (Formatter Plus v4.7.0) */
CREATE OR REPLACE PROCEDURE show_all_arguments (program_in IN VARCHAR2)
IS
   l_owner          all_arguments.owner%TYPE;
   l_package_name   all_arguments.owner%TYPE;
   l_object_name    all_arguments.owner%TYPE;

   -- Individual "break outs" for a parameter
   -- At this level, simply reflects contents of ALL_ARGS
   -- (ie, the recursive, nested structure is NOT captured).
   TYPE breakouts_t IS TABLE OF all_arguments%ROWTYPE
      INDEX BY /* Sequential within parameter position */ BINARY_INTEGER;

   -- Arguments for a single overloading
   TYPE parameters_t IS TABLE OF breakouts_t
      INDEX BY /* Parameter position */ BINARY_INTEGER;

   -- Overloadings for a single program name
   TYPE overloadings_t IS TABLE OF parameters_t
      INDEX BY /* Overloading # */ BINARY_INTEGER;

   -- All distinct programs in a package/program
   TYPE programs_t IS TABLE OF overloadings_t
      INDEX BY /*BINARY_INTEGER; --*/ all_arguments.object_name%TYPE;

   -- Dump of ALL_ARGUMENTS
   l_arguments      breakouts_t;
   
   -- Multi-level sorting of ALL_ARGUMENTS data
   l_programs       programs_t;

   CURSOR arguments_cur
   IS
      SELECT   *
          FROM all_arguments
         WHERE owner = l_owner
           AND (   (    package_name = l_package_name
                    AND (object_name = l_object_name OR l_object_name IS NULL
                        )
                   )
                OR (    package_name IS NULL
                    AND l_package_name IS NULL
                    AND object_name = l_object_name
                   )
               )
      ORDER BY owner,
               package_name,
               object_name,
               overload,
               SEQUENCE -- Force into correct order
                        ,
               POSITION,
               LEVEL;

   PROCEDURE pl (text_in IN VARCHAR2, indent_in IN PLS_INTEGER := 0)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (RPAD (' ', indent_in) || text_in);
   END;

   PROCEDURE pl (
      title_in         IN   VARCHAR2,
      context_in       IN   VARCHAR2,
      count_label_in   IN   VARCHAR2,
      value_in         IN   VARCHAR2,
      indent_in        IN   PLS_INTEGER
   )
   IS
   BEGIN
      DBMS_OUTPUT.put_line (   RPAD (' ', indent_in)
                            || title_in
                            || ' '
                            || context_in
                            || ' - # of '
                            || count_label_in
                            || ' = '
                            || value_in
                           );
   END;

   PROCEDURE process_name
   IS
      dblink          VARCHAR2 (100);
      part1_type      NUMBER;
      object_number   NUMBER;
   BEGIN
      DBMS_UTILITY.name_resolve (program_in,
                                 1,
                                 l_owner,
                                 l_package_name,
                                 l_object_name,
                                 dblink,
                                 part1_type,
                                 object_number
                                );
   END process_name;

   PROCEDURE load_arrays
   IS
      l_parm_position       PLS_INTEGER;
      l_breakout_position   PLS_INTEGER;

      PROCEDURE check_for_new_parameter (
	     argindx_in IN PLS_INTEGER,
		 breakout_pos_inout IN OUT PLS_INTEGER)
      IS
      BEGIN
         -- If data level is 0, position is the position in the 
         -- actual parameter list. Use this as the key into the 
         -- lowest level of my structures.
         IF l_arguments (argindx_in).data_level = 0
         THEN
            l_parm_position := l_arguments (argindx_in).POSITION;
            breakout_pos_inout := 0;
         ELSE
		    breakout_pos_inout := breakout_pos_inout + 1;
		 END IF;
      END check_for_new_parameter;
   BEGIN
      OPEN arguments_cur;
      FETCH arguments_cur BULK COLLECT INTO l_arguments;

      FOR argindx IN l_arguments.FIRST .. l_arguments.LAST
      LOOP
         check_for_new_parameter (argindx, l_breakout_position);         

         l_programs
           (l_arguments(argindx).object_name)
              (NVL (l_arguments(argindx).overload, '0'))
                 (l_parm_position)
                    (l_breakout_position):= l_arguments(argindx);

      END LOOP;
   END load_arrays;

   PROCEDURE dump_arguments_array
   IS
      FUNCTION strval (num IN INTEGER, padto IN INTEGER)
         RETURN VARCHAR2
      IS
      BEGIN
         RETURN LPAD (NVL (TO_CHAR (num), 'N/A'), padto) || ' ';
      END;
   BEGIN
      IF (l_arguments.COUNT > 0)
      THEN
         pl (' ');
		 pl (   'Dump of ALL_ARGUMENTS for "'
                               || program_in
                               || '"'
                              );
         pl ('Object               OvLd Lev Pos Type                 Name                          Mode  '
                              );
         pl ('-------------------- ---- --- --- -------------------- ---------------------------- ------ '
                              );

         FOR argrow IN l_arguments.FIRST .. l_arguments.LAST
         LOOP
            pl (   RPAD (l_arguments (argrow).object_name,
                                           20
                                          )
                                  || strval (l_arguments (argrow).overload, 4)
                                  || strval (l_arguments (argrow).data_level,
                                             3
                                            )
                                  || strval (l_arguments (argrow).POSITION, 4)
                                  || RPAD (l_arguments (argrow).data_type, 20)
                                  || RPAD (   LPAD (' ',
                                                       2
                                                     * l_arguments (argrow).data_level,
                                                    ' '
                                                   )
                                           || NVL (l_arguments (argrow).argument_name,
                                                   'Anonymous'
                                                  ),
                                           30
                                          )
                                  || RPAD (l_arguments (argrow).in_out, 6)
                                 );
         END LOOP;
      END IF;
   END dump_arguments_array;

   PROCEDURE dump_multilevel_array
   IS
      l_program   all_arguments.object_name%TYPE;

      PROCEDURE show_overloadings (
         programs_in      IN   programs_t,
         object_name_in   IN   all_arguments.object_name%TYPE
      )
      IS
         overloadings_for_name   overloadings_t
                                              := programs_in (object_name_in);
         overloading_index       PLS_INTEGER;
         top_level_parms         parameters_t;

         PROCEDURE show_parameters (top_level_parms_in IN parameters_t)
         IS
            breakouts       breakouts_t;
            parm_sequence   PLS_INTEGER;

            PROCEDURE show_breakouts (breakouts_in IN breakouts_t)
            IS
               one_argument        all_arguments%ROWTYPE;
               breakout_position   PLS_INTEGER;
            BEGIN -- main show_breakouts
               breakout_position := breakouts_in.FIRST;

               LOOP
                  EXIT WHEN breakout_position IS NULL;
                  one_argument := breakouts_in (breakout_position);
                  pl (   NVL (one_argument.argument_name, 'Anonymous')
                      || '('
                      || one_argument.data_type
                      || ') Lvl-Pos: '
                      || one_argument.data_level
                      || '-'
                      || one_argument.POSITION,
                      10
                     );
                  breakout_position := breakouts_in.NEXT (breakout_position);
               END LOOP;
            END show_breakouts;
         BEGIN -- main show_parameters
            parm_sequence := top_level_parms_in.FIRST;

            LOOP
               EXIT WHEN parm_sequence IS NULL;
               breakouts := top_level_parms_in (parm_sequence);
               pl ('Parameter',
                   parm_sequence,
                   'Breakouts',
                   breakouts.COUNT,
                   6
                  );
			   show_breakouts (breakouts);
               parm_sequence := top_level_parms_in.NEXT (parm_sequence);               
            END LOOP;
         END show_parameters;
      BEGIN -- main show_overloadings
         overloading_index := programs_in (object_name_in).FIRST;

         LOOP
            EXIT WHEN overloading_index IS NULL;
            top_level_parms := overloadings_for_name (overloading_index);
            pl ('Overloading',
                overloading_index,
                'Arguments',
                top_level_parms.COUNT,
                4
               );
            show_parameters (top_level_parms);
            overloading_index :=
                                overloadings_for_name.NEXT (overloading_index);
         END LOOP;
      END show_overloadings;
   BEGIN -- main dump_multilevel_array
      IF (l_arguments.COUNT > 0)
      THEN
         pl (' ');
		 pl (   'Dump of Multi-level Collection of ALL_ARGUMENTS for  "'
                               || program_in
                               || '"'
                              );
         pl (' ');	  
         pl ('Package',
              l_owner || '.' || l_package_name || '.' || l_object_name,
             'Distinct Programs',
             l_programs.COUNT,
             0
            );
         l_program := l_programs.FIRST;

         LOOP
            EXIT WHEN l_program IS NULL;
            pl ('Name',
                l_program,
                'Overloadings',
                l_programs (l_program).COUNT,
                2
               );
            show_overloadings (l_programs, l_program);
            l_program := l_programs.NEXT (l_program);
         END LOOP;
      END IF;
   END dump_multilevel_array;
BEGIN -- main show_all_arguments
   process_name;
   load_arrays;
   dump_arguments_array;
   dump_multilevel_array;
END show_all_arguments;
/