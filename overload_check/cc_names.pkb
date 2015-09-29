CREATE OR REPLACE PACKAGE BODY cc_names
/*
Codecheck: the QA utility for PL/SQL code
Copyright (C) 2002, Steven Feuerstein
All rights reserved

cc_names: API to DBMS_UTILITY.NAME_RESOLVE
*/
IS
   FUNCTION is_package (type_in IN PLS_INTEGER)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN (type_in = c_package);
   END;

   FUNCTION for_program (program_in IN VARCHAR2)
      RETURN names_rt
   IS
      TYPE notused_rt IS RECORD (
         must_be_one     PLS_INTEGER
        ,dblink          VARCHAR2 (100)
        ,object_number   NUMBER
      );

      l_notused   notused_rt;
      retval      names_rt;
      empty       names_rt;
   BEGIN
      l_notused.must_be_one := 1;
      DBMS_UTILITY.name_resolve (program_in
                                ,l_notused.must_be_one
                                ,retval.owner
                                ,retval.package_name
                                ,retval.object_name
                                ,l_notused.dblink
                                ,retval.object_type
                                ,l_notused.object_number
                                );
      retval.ispackage := is_package (retval.object_type);
      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN empty;
   END for_program;

   FUNCTION combined (
      owner_in     IN   VARCHAR2
     ,package_in   IN   VARCHAR2
     ,object_in    IN   VARCHAR2
   )
      RETURN combined_name_t
   IS
      retval   combined_name_t := object_in;
   BEGIN
      IF package_in IS NOT NULL
      THEN
         retval := owner_in || '.' || package_in;
      ELSE
         retval := owner_in;
      END IF;

      IF object_in IS NOT NULL
      THEN
         retval := retval || '.' || object_in;
      END IF;

      RETURN retval;
   END;

   FUNCTION combined (names_in IN names_rt)
      RETURN combined_name_t
   IS
   BEGIN
      RETURN combined (names_in.owner
                      ,names_in.package_name
                      ,names_in.object_name
                      );
   END;

   FUNCTION name_ok (
      NAME_IN     IN   VARCHAR2
     ,prefix_in   IN   VARCHAR2 := NULL
     ,suffix_in   IN   VARCHAR2 := NULL
     ,upper_in    IN   BOOLEAN := TRUE
   )
      RETURN BOOLEAN
   IS
      l_name         combined_name_t := NAME_IN;
      l_prefix       combined_name_t := prefix_in;
      l_suffix       combined_name_t := suffix_in;
      l_prefix_len   PLS_INTEGER  := LENGTH (prefix_in);
      l_suffix_len   PLS_INTEGER  := LENGTH (suffix_in);
      retval         BOOLEAN      := TRUE;
   BEGIN
      IF upper_in
      THEN
         l_name := UPPER (NAME_IN);
         l_prefix := UPPER (prefix_in);
         l_suffix := UPPER (suffix_in);
      END IF;

      IF prefix_in IS NOT NULL
      THEN
         retval := SUBSTR (l_name, 1, l_prefix_len) = l_prefix;
      END IF;

      IF suffix_in IS NOT NULL AND retval
      THEN
         retval := SUBSTR (l_name, -1 * l_suffix_len) = l_suffix;
      END IF;

      RETURN retval;
   END name_ok;

   FUNCTION parameter_name_ok (
      NAME_IN                   IN   VARCHAR2
     ,prefix_in                 IN   VARCHAR2 := NULL
     ,suffix_in                 IN   VARCHAR2 := NULL
     ,mode_in                   IN   VARCHAR2 := NULL
     ,mode_as_suffix_delim_in   IN   VARCHAR2 := NULL
     ,upper_in                  IN   BOOLEAN := TRUE
   )
      RETURN BOOLEAN
   IS
      l_suffix   combined_name_t;
   BEGIN
      IF mode_as_suffix_delim_in IS NULL
      THEN
         l_suffix := suffix_in;
      ELSE
         l_suffix := mode_as_suffix_delim_in || mode_in;
      END IF;

      RETURN name_ok (NAME_IN, prefix_in, l_suffix, upper_in);
   END;

   FUNCTION constructed_name (
      prefix_in   IN   VARCHAR2 := NULL
     ,suffix_in   IN   VARCHAR2 := NULL
     ,
	  model_IN     IN   VARCHAR2 := '<name>',upper_in    IN   BOOLEAN := TRUE
   )
      RETURN combined_name_t
   IS
      retval   combined_name_t := prefix_in || model_IN || suffix_in;
   BEGIN
      IF upper_in
      THEN
         RETURN UPPER (retval);
      ELSE
         RETURN retval;
      END IF;
   END;

   FUNCTION constructed_parameter_name (
      prefix_in                 IN   VARCHAR2 := NULL
     ,suffix_in                 IN   VARCHAR2 := NULL
     ,mode_in                   IN   VARCHAR2 := NULL
     ,mode_as_suffix_delim_in   IN   VARCHAR2 := NULL,
	  model_IN     IN   VARCHAR2 := '<name>'
     ,upper_in                  IN   BOOLEAN := TRUE
   )
      RETURN combined_name_t
   IS
      retval   combined_name_t;
   BEGIN
      IF mode_as_suffix_delim_in IS NOT NULL
      THEN
         retval := prefix_in || model_IN || mode_as_suffix_delim_in || mode_in;
      ELSE
         retval := prefix_in || model_IN || suffix_in;
      END IF;

      IF upper_in
      THEN
         RETURN UPPER (retval);
      ELSE
         RETURN retval;
      END IF;
   END;
END cc_names;
/