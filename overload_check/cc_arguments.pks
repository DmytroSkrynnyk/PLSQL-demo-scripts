CREATE OR REPLACE PACKAGE cc_arguments
/*
Codecheck: the QA utility for PL/SQL code
Copyright (C) 2002, Steven Feuerstein
All rights reserved

cc_arguments: API to argument information consolidated from
              ALL_ARGUMENTS and DBMS_DESCRIBE
*/
IS 
   c_top_level    CONSTANT PLS_INTEGER := 0;
   c_return_pos      CONSTANT PLS_INTEGER := 0;
   --
   -- Parameter mode values used in DBMS_DESCRIBE
   c_in              CONSTANT PLS_INTEGER := 0;
   c_out             CONSTANT PLS_INTEGER := 1;
   c_inout           CONSTANT PLS_INTEGER := 2;
   --
   -- Indicators for prsence of default value
   c_has_default CONSTANT PLS_INTEGER := 1;
   c_has_no_default CONSTANT PLS_INTEGER := 0;
   
   /* A single record holding all the information for one argument. */
   TYPE one_argument_rt IS RECORD (
      owner                all_arguments.owner%TYPE,
      package_name         all_arguments.package_name%TYPE,
      object_name          all_arguments.object_name%TYPE,
      overload             PLS_INTEGER, -- from DBMS_DESCRIBE
      POSITION             all_arguments.position%TYPE,
      data_level           all_arguments.data_level%TYPE,
      argument_name        all_arguments.argument_name%TYPE,
      datatype             PLS_INTEGER, -- from DBMS_DESCRIBE
      DEFAULT_VALUE        PLS_INTEGER, -- from DBMS_DESCRIBE
      in_out               PLS_INTEGER, -- from DBMS_DESCRIBE
      character_set_name   all_arguments.character_set_name%TYPE,
      type_owner           all_arguments.type_owner%TYPE,
      type_name            all_arguments.type_name%TYPE,
      type_subname         all_arguments.type_subname%TYPE,
      type_link            all_arguments.type_link%TYPE,
      pls_type             all_arguments.pls_type%TYPE,
      char_length          all_arguments.char_length%TYPE,
      char_used            all_arguments.char_used%TYPE
   );

   -- Contents of ALL_ARGS/DBMS_DESCRIBE, loaded sequentially
   TYPE arguments_tt IS TABLE OF one_argument_rt
      INDEX BY BINARY_INTEGER; 
	  	  
   FUNCTION mode_name (code_in IN PLS_INTEGER)
      RETURN VARCHAR2;
	  
   FUNCTION has_default (default_in IN PLS_INTEGER)
      RETURN BOOLEAN;

   FUNCTION not_defaulted (arg_in in one_argument_rt)
      RETURN BOOLEAN;
   
   function is_toplevel_parameter (arg_in in one_argument_rt) return boolean;

   FUNCTION is_return_clause (arg_in IN one_argument_rt)
      RETURN BOOLEAN;
      
   function procedure_without_parameters (arg_in IN one_argument_rt)
      RETURN BOOLEAN;
	     
		 	  
   FUNCTION in_same_family (
      arg1_in   IN   one_argument_rt,
      arg2_in   IN   one_argument_rt
   )
      RETURN BOOLEAN;
   PROCEDURE show (
      program_in   IN   VARCHAR2,
      start_in     IN   PLS_INTEGER := NULL,
      end_in       IN   PLS_INTEGER := NULL
   );

   FUNCTION onerow (
      object_name_in     IN   VARCHAR2,
      package_name_in    IN   VARCHAR2,
      owner_in           IN   VARCHAR2,
      overload_in        IN   PLS_INTEGER,
      argument_name_in   IN   VARCHAR2,
      position_in        IN   PLS_INTEGER,
      level_in           IN   PLS_INTEGER
   )
      RETURN all_arguments%ROWTYPE;

   FUNCTION fullset (
      program_in          IN   VARCHAR2,
      show_in             IN   BOOLEAN := FALSE
   )
      RETURN arguments_tt;
	  
   PROCEDURE compare_aa_to_dd (
	     program_in IN VARCHAR2);
		 	  
END cc_arguments;
/
