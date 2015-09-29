CREATE OR REPLACE PACKAGE BODY cc_types
/*
Codecheck: the QA utility for PL/SQL code
Copyright (C) 2002, Steven Feuerstein
All rights reserved

cc_types: API to datatype reference and rules
*/
IS
   SUBTYPE name_t IS VARCHAR2 (100);

   TYPE names_by_name_tt IS TABLE OF name_t
      INDEX BY BINARY_INTEGER; --*/name_t;

   TYPE names_by_code_tt IS TABLE OF name_t
      INDEX BY BINARY_INTEGER;

   TYPE booleans_tt IS TABLE OF BOOLEAN
      INDEX BY BINARY_INTEGER;

   TYPE type_families_tt IS TABLE OF booleans_tt
      INDEX BY BINARY_INTEGER;

   -- Holds the names of the datatypes 
   c_datatype_names    names_by_code_tt;
   -- Holds the codes for datatypes that are non-scalar types
   c_composite_types   booleans_tt;
   -- Datatypes to avoid
   trouble_types       names_by_name_tt;
   type_families       type_families_tt;

   FUNCTION NAME (code_in IN PLS_INTEGER)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN c_datatype_names (code_in);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;

   FUNCTION is_composite_type (type_in IN PLS_INTEGER)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN c_composite_types.EXISTS (type_in);
   END;

   FUNCTION is_record_type (type_in IN PLS_INTEGER)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN type_in = c_record;
   END;

   FUNCTION is_rowtype (type_in IN PLS_INTEGER, type_subname_in IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN type_in = c_record AND type_subname_in IS NULL;
   END;

   PROCEDURE show_datatypes_to_avoid (include_header_in IN BOOLEAN := TRUE)
   IS
      indx   VARCHAR2 (30) := trouble_types.FIRST;
   BEGIN
      IF include_header_in
      THEN
         cc_util.pl ('');
         cc_util.pl ('Datatypes to Avoid and Why:');
      END IF;

      cc_util.pl ('');

      LOOP
         EXIT WHEN indx IS NULL;
         cc_util.pl (trouble_types (indx));
         indx := trouble_types.NEXT (indx);
      END LOOP;

      cc_util.pl ('');
      cc_util.pl ('Note: Limitations in DBMS_DESCRIBE and USER_ARGUMENTS result'
                 );
      cc_util.pl ('      in an inability to distinguish between certain datatypes,'
                 );
      cc_util.pl ('      such as VARCHAR2 and CHAR. So review the list carefully.'
                 );
      cc_util.pl ('');
   END;

   FUNCTION is_a_trouble_type (code_in IN PLS_INTEGER)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN trouble_types.EXISTS (code_in);
   END;

   FUNCTION in_same_family (
      type1_in IN PLS_INTEGER, type2_in IN PLS_INTEGER)
      RETURN BOOLEAN
   IS
   BEGIN
      IF NOT type_families.EXISTS (type1_in)
        THEN 
           RETURN FALSE;
        ELSE 
           RETURN type_families (type1_in).EXISTS (type2_in);
      END IF;
   END;

   PROCEDURE load_in_same_family
   IS
      TYPE one_family_tt IS TABLE OF PLS_INTEGER;

      PROCEDURE load_permutations (
         val1_in   IN   PLS_INTEGER
        ,val2_in   IN   PLS_INTEGER
      )
      IS
      BEGIN
         type_families (val1_in) (val1_in) := TRUE;
         type_families (val2_in) (val2_in) := TRUE;
         type_families (val1_in) (val2_in) := TRUE;
         type_families (val2_in) (val1_in) := TRUE;
      END load_permutations;

      PROCEDURE load_one_family (family_in IN one_family_tt)
      IS
      BEGIN
         FOR o_index IN family_in.FIRST .. family_in.LAST
         LOOP
            FOR i_index IN family_in.FIRST .. family_in.LAST
            LOOP			
               load_permutations (family_in(o_index), 
			      family_in(i_index));
            END LOOP;
         END LOOP;
      END load_one_family;
   BEGIN
      load_one_family (one_family_tt (c_varchar2
                                 ,c_varchar
                                 ,c_char
                                 ,c_nchar
                                 ,c_long
                                 )
                      );
      load_one_family (one_family_tt (c_date 
	                             ,c_timestamp)
					  );
      load_one_family (one_family_tt (c_timestamp
                                 ,c_timestamp_tz
								 ,c_timestamp_ltz)
                      );
      load_one_family (one_family_tt (c_number
                                 ,c_integer
                                 ,c_binary_integer
                                 ,c_pls_integer
                                 )
                      );
   END;

   PROCEDURE load_trouble_types
   IS
   BEGIN
      -- Datatypes to be avoided 
      trouble_types (c_varchar) :=
                           'Using VARCHAR or NVARCHAR? Use VARCHAR2 instead.';
      trouble_types (c_char) :=
                    'Using CHAR or NCHAR? Use VARCHAR2 or NVARCHAR2 instead.';
      trouble_types (c_long) := 'Using LONG? Use CLOB instead.';
      trouble_types (c_longraw) := 'Using LONGRAW? Use BLOB instead.';
      trouble_types (c_binary_integer) :=
                             'Using BINARY_INTEGER? Use PLS_INTEGER instead.';
   END;

   PROCEDURE load_type_translators
   IS
   BEGIN
       -- Allow for easy translation between ALL_ARGUMENTS
      -- and DBMS_DESCRIBE representations.
      c_datatype_names (c_varchar2) := 'VARCHAR2';
      c_datatype_names (c_number) := 'NUMBER';
      c_datatype_names (c_binary_integer) := 'BINARY_INTEGER';
      c_datatype_names (c_long) := 'LONG';
      c_datatype_names (c_rowid) := 'ROWID';
      c_datatype_names (c_date) := 'DATE';
      c_datatype_names (c_raw) := 'RAW';
      c_datatype_names (c_longraw) := 'LONG RAW';
      c_datatype_names (c_char) := 'CHAR';
      c_datatype_names (c_mlslabel) := 'MLSLABEL';
      c_datatype_names (c_record) := 'RECORD';
      c_datatype_names (c_indexby_table) := 'INDEX-BY TABLE';
      c_datatype_names (c_boolean) := 'BOOLEAN';
      c_datatype_names (c_object_type) := 'OBJECT TYPE';
      c_datatype_names (c_nested_table) := 'NESTED TABLE';
      c_datatype_names (c_varray) := 'VARRAY';
      c_datatype_names (c_clob) := 'CLOB';
      c_datatype_names (c_blob) := 'BLOB';
      c_datatype_names (c_bfile) := 'BFILE';
   END;

   PROCEDURE load_composite_types
   IS
   BEGIN
      c_composite_types (c_record) := TRUE;
      c_composite_types (c_indexby_table) := TRUE;
      c_composite_types (c_object_type) := TRUE;
      c_composite_types (c_nested_table) := TRUE;
      c_composite_types (c_varray) := TRUE;
   END;
BEGIN
   load_in_same_family;
   load_trouble_types;
   load_type_translators;
   load_composite_types;
END cc_types;
/