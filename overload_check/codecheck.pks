CREATE OR REPLACE PACKAGE codecheck
/*
Codecheck: the QA utility for PL/SQL code
Copyright (C) 2002, Steven Feuerstein
All rights reserved

Codecheck: the code check engine
*/
IS
   -- Reports on invalid overloadings defined in the specified package
   PROCEDURE overloadings (
      package_in                IN   VARCHAR2,
      verbose_in                IN   BOOLEAN := FALSE,
      reload_argument_info_in   IN   BOOLEAN := TRUE
   );

   PROCEDURE naming_conventions (
      program_in                IN   VARCHAR2,
      check_parameters_in       IN   BOOLEAN := TRUE,
      check_programs_in     IN   BOOLEAN := TRUE,
	  prog_prefix_in in varchar2 := null,
	  prog_suffix_in in varchar2 := null,
	  type_as_prefix_delim_in   IN   VARCHAR2 := NULL,
	  param_prefix_in in varchar2 := null,
	  param_suffix_in in varchar2 := null,
	  mode_as_suffix_delim_in   IN   VARCHAR2 := NULL,
	  upper_in in boolean := true,
	  verbose_in                IN   BOOLEAN := FALSE,
      reload_argument_info_in   IN   BOOLEAN := TRUE
   );

/*
   PROCEDURE datatype_usage (
      program_in                IN   VARCHAR2 := NULL,
      show_in                   IN   BOOLEAN := FALSE ,
      reload_argument_info_in   IN   BOOLEAN := TRUE ,
      testing_in                IN   BOOLEAN := FALSE
   );
*/
   FUNCTION VERSION
      RETURN VARCHAR2;
END codecheck;
/