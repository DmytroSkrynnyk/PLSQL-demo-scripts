CREATE OR REPLACE PACKAGE cc_names
/*
Codecheck: the QA utility for PL/SQL code
Copyright (C) 2002, Steven Feuerstein
All rights reserved

cc_names: API to DBMS_UTILITY.NAME_RESOLVE
*/
IS
   c_synonym CONSTANT PLS_INTEGER := 5;
   c_procedure CONSTANT PLS_INTEGER := 7;
   c_function CONSTANT PLS_INTEGER := 8;
   c_package CONSTANT PLS_INTEGER := 9;

   SUBTYPE combined_name_t IS VARCHAR2 (200);

   TYPE names_rt IS RECORD (
      object_name    VARCHAR2 (200)
     ,object_type    PLS_INTEGER
     ,package_name   VARCHAR2 (200)
     ,owner          VARCHAR2 (200)
     ,ispackage      BOOLEAN
   );

   FUNCTION is_package (type_in IN PLS_INTEGER) RETURN BOOLEAN; 
   
   FUNCTION for_program (program_in IN VARCHAR2)
      RETURN names_rt;

   FUNCTION combined (
      owner_in     IN   VARCHAR2
     ,package_in   IN   VARCHAR2
     ,object_in    IN   VARCHAR2
   )
      RETURN combined_name_t;

   FUNCTION combined (names_in IN names_rt)
      RETURN combined_name_t;
	  
   FUNCTION name_ok (
      NAME_IN     IN   VARCHAR2,
      prefix_in   IN   VARCHAR2 := NULL,
      suffix_in   IN   VARCHAR2 := NULL,
      upper_in    IN   BOOLEAN := TRUE
   )
      RETURN BOOLEAN;

   FUNCTION constructed_name (
      prefix_in   IN   VARCHAR2 := NULL,
      suffix_in   IN   VARCHAR2 := NULL,
	  model_IN     IN   VARCHAR2 := '<name>',
      
      upper_in    IN   BOOLEAN := TRUE
   )
      RETURN combined_name_t;

   FUNCTION parameter_name_ok (
      NAME_IN                   IN   VARCHAR2,
      prefix_in                 IN   VARCHAR2 := NULL,
      suffix_in                 IN   VARCHAR2 := NULL,
      mode_in                   IN   VARCHAR2 := NULL,
      mode_as_suffix_delim_in   IN   VARCHAR2 := NULL,
      upper_in                  IN   BOOLEAN := TRUE
   )
      RETURN BOOLEAN;	  
	  
   FUNCTION constructed_parameter_name (
      prefix_in                 IN   VARCHAR2 := NULL,
      suffix_in                 IN   VARCHAR2 := NULL,
      mode_in                   IN   VARCHAR2 := NULL,
      mode_as_suffix_delim_in   IN   VARCHAR2 := NULL
      ,
	  model_IN     IN   VARCHAR2 := '<name>',
	  upper_in                  IN   BOOLEAN := TRUE
   )
      RETURN combined_name_t;		  
END cc_names;
/