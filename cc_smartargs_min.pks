CREATE OR REPLACE PACKAGE cc_smartargs
IS
   SUBTYPE parameter_position_t is PLS_INTEGER;
   SUBTYPE overloading_#_t IS PLS_INTEGER;
   SUBTYPE subprogram_name_t IS all_arguments.object_name%TYPE;
   
   TYPE one_parameter_rt IS RECORD (
      toplevel    cc_arguments.one_argument_rt
     ,breakouts   cc_arguments.arguments_tt
   );

   -- List of top level parameters (level = 0 in ALL_ARGS)
   TYPE parameters_tt IS TABLE OF one_parameter_rt
      INDEX BY parameter_position_t;

   -- Overloadings for a single program name
   TYPE one_overloading_rt IS RECORD (
      PARAMETERS             parameters_tt
     ,return_clause          one_parameter_rt
     ,last_nondefault_parm   PLS_INTEGER
   );

   TYPE overloadings_t IS TABLE OF one_overloading_rt
      INDEX BY overloading_#_t;

   TYPE programs_t IS TABLE OF overloadings_t
      INDEX BY subprogram_name_t;

   -- Populate raw arguments and multi-level collection.
   PROCEDURE load_arguments (
      program_in   IN   VARCHAR2 := NULL
     ,show_in      IN   BOOLEAN := FALSE
   );
END cc_smartargs;
/