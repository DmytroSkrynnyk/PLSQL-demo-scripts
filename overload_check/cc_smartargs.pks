CREATE OR REPLACE PACKAGE cc_smartargs
/*
Codecheck: the QA utility for PL/SQL code
Copyright (C) 2002, Steven Feuerstein
All rights reserved

cc_smartargs: Enhanced ("smart") argument information
*/
IS
   TYPE one_parameter_rt IS RECORD (
      toplevel    cc_arguments.one_argument_rt
     ,breakouts   cc_arguments.arguments_tt
   );

   -- List of top level parameters (level = 0 in ALL_ARGS)
   TYPE parameters_tt IS TABLE OF one_parameter_rt
      INDEX BY                     /* Sequential position in parameter list */
              PLS_INTEGER;

   -- Overloadings for a single program name
   TYPE one_overloading_rt IS RECORD (
      PARAMETERS             parameters_tt
     ,return_clause          one_parameter_rt
     ,last_nondefault_parm   PLS_INTEGER
   );

   TYPE overloadings_t IS TABLE OF one_overloading_rt
      INDEX BY /* overloading # - 0 if not overloaded */ PLS_INTEGER;

   -- All distinct programs in a package/program
   TYPE programs_t IS TABLE OF overloadings_t
      INDEX BY all_arguments.object_name%TYPE;

   -- Populate raw arguments and multi-level collection.
   PROCEDURE load_arguments (
      program_in   IN   VARCHAR2 := NULL
     ,show_in      IN   BOOLEAN := FALSE
   );

-- Programs to access contents of g_programs (post loading)
   FUNCTION first_program
      RETURN VARCHAR2;

   FUNCTION last_program
      RETURN VARCHAR2;

   FUNCTION next_program (program_in IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION prior_program (program_in IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION num_programs
      RETURN PLS_INTEGER;

-- Programs to access contents of g_programs(overloading), that is
   -- all the overloadings for a given program name.
   FUNCTION first_overloading (program_in IN VARCHAR2)
      RETURN PLS_INTEGER;

   FUNCTION last_overloading (program_in IN VARCHAR2)
      RETURN PLS_INTEGER;

   FUNCTION next_overloading (
      program_in       IN   VARCHAR2
     ,overloading_in   IN   PLS_INTEGER
   )
      RETURN PLS_INTEGER;

   FUNCTION prior_overloading (
      program_in       IN   VARCHAR2
     ,overloading_in   IN   PLS_INTEGER
   )
      RETURN PLS_INTEGER;

   FUNCTION num_overloadings (program_in IN VARCHAR2)
      RETURN PLS_INTEGER;

   FUNCTION has_overloadings (program_in IN VARCHAR2)
      RETURN BOOLEAN;

-- Information about a single overloading of a program name
   FUNCTION parameter_count (program_in IN VARCHAR2, overload_in IN PLS_INTEGER)
      RETURN INTEGER;

   FUNCTION has_no_parameters (
      program_in    IN   VARCHAR2
     ,overload_in   IN   PLS_INTEGER
   )
      RETURN BOOLEAN;

   FUNCTION is_function (program_in IN VARCHAR2, overload_in IN PLS_INTEGER)
      RETURN BOOLEAN;

   FUNCTION first_invocation (
      program_in    IN   VARCHAR2
     ,overload_in   IN   PLS_INTEGER
   )
      RETURN PLS_INTEGER;

   FUNCTION last_invocation (program_in IN VARCHAR2, overload_in IN PLS_INTEGER)
      RETURN PLS_INTEGER;

   -- Argument info for a single overloading,
   -- including all the breakout, multi-level information
   FUNCTION full_parameter_list (
      program_in    IN   VARCHAR2
     ,overload_in   IN   PLS_INTEGER
   )
      RETURN parameters_tt;

   -- Just the "top level" parameter list.
   FUNCTION parameter_list (
      program_in     IN   VARCHAR2
     ,overload_in    IN   PLS_INTEGER
     ,startparm_in   IN   PLS_INTEGER := 1
     ,endparm_in     IN   PLS_INTEGER := NULL
   )
      RETURN cc_arguments.arguments_tt;

/*
   FUNCTION first_arg RETURN PLS_INTEGER;
   FUNCTION next_arg  (row_in in pls_integer)RETURN PLS_INTEGER;
   FUNCTION argset (row_in in pls_integer) RETURN cc_arguments.one_argument_rt;
   FUNCTION arg_datatype (row_in in pls_integer) RETURN PLS_INTEGER;
*/
-- Programs to access names of object specified in load_arguments
   FUNCTION package_name
      RETURN VARCHAR2;

   FUNCTION ispackage
      RETURN BOOLEAN;

   FUNCTION object_name
      RETURN VARCHAR2;

   FUNCTION owner_name
      RETURN VARCHAR2;

   FUNCTION full_arg_spec (arg_in IN cc_arguments.one_argument_rt)
      RETURN VARCHAR2;

   FUNCTION ovld_header (
      program_in    IN   VARCHAR2
     ,overload_in   IN   PLS_INTEGER
     ,startarg_in   IN   PLS_INTEGER := NULL
     ,endarg_in     IN   PLS_INTEGER := NULL
   )
      RETURN VARCHAR2;

-- Show contents of arrays
   PROCEDURE show_args (
      program_in           IN   VARCHAR2 := NULL
     ,start_in             IN   PLS_INTEGER := NULL
     ,end_in               IN   PLS_INTEGER := NULL
     ,multilevel_only_in   IN   BOOLEAN := TRUE
   );

   PROCEDURE show_headers (program_in IN VARCHAR2 := NULL);
END cc_smartargs;
/