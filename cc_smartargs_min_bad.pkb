CREATE OR REPLACE PROCEDURE load_arguments (program_in IN VARCHAR2)
IS
   TYPE names_rt IS RECORD
   (
      object_name    VARCHAR2 (200),
      object_type    PLS_INTEGER,
      package_name   VARCHAR2 (200),
      owner          VARCHAR2 (200),
      ispackage      BOOLEAN
   );

   l_names                names_rt;

   TYPE one_argument_rt IS RECORD
   (
      owner                all_arguments.owner%TYPE,
      package_name         all_arguments.package_name%TYPE,
      object_name          all_arguments.object_name%TYPE,
      overload             PLS_INTEGER,                  
      position             all_arguments.position%TYPE,
      data_level           all_arguments.data_level%TYPE,
      argument_name        all_arguments.argument_name%TYPE,
      datatype             PLS_INTEGER,                  
      DEFAULT_VALUE        PLS_INTEGER,                  
      in_out               PLS_INTEGER,                  
      character_set_name   all_arguments.character_set_name%TYPE,
      type_owner           all_arguments.type_owner%TYPE,
      type_name            all_arguments.type_name%TYPE,
      type_subname         all_arguments.type_subname%TYPE,
      type_link            all_arguments.type_link%TYPE,
      pls_type             all_arguments.pls_type%TYPE,
      char_length          all_arguments.char_length%TYPE,
      char_used            all_arguments.char_used%TYPE
   );

   TYPE arguments_tt IS TABLE OF one_argument_rt
      INDEX BY BINARY_INTEGER;

   l_all_arguments        arguments_tt;
   
   TYPE one_parameter_rt IS RECORD (
      toplevel    one_argument_rt
     ,breakouts   arguments_tt
   );

   /* Index by parameter position */
   TYPE parameters_tt IS TABLE OF one_parameter_rt
      INDEX BY PLS_INTEGER;

   TYPE one_overloading_rt IS RECORD (
      PARAMETERS             parameters_tt
     ,return_clause          one_parameter_rt
     ,last_nondefault_parm   PLS_INTEGER
   );

   /* Index by overloading number */
   TYPE overloadings_t IS TABLE OF one_overloading_rt
      INDEX BY PLS_INTEGER;

   /* Index by program name */
   TYPE programs_t IS TABLE OF overloadings_t
      INDEX BY VARCHAR2(1000);
      
   g_programs             programs_t;

   TYPE notused_rt IS RECORD
   (
      must_be_one     PLS_INTEGER,
      dblink          VARCHAR2 (100),
      object_number   NUMBER
   );

   l_notused              notused_rt;
   
   retval                 names_rt;
   empty                  names_rt;
   l_argindx              PLS_INTEGER;
   l_breakout_pos         PLS_INTEGER;
   l_index                PLS_INTEGER;
   l_names                names_rt;
   retval                 arguments_tt;
   l_overload             DBMS_DESCRIBE.number_table;
   l_position             DBMS_DESCRIBE.number_table;
   l_level                DBMS_DESCRIBE.number_table;
   l_argument_name        DBMS_DESCRIBE.varchar2_table;
   l_datatype             DBMS_DESCRIBE.number_table;
   l_default_value        DBMS_DESCRIBE.number_table;
   l_in_out               DBMS_DESCRIBE.number_table;
   l_length               DBMS_DESCRIBE.number_table;
   l_precision            DBMS_DESCRIBE.number_table;
   l_scale                DBMS_DESCRIBE.number_table;
   l_radix                DBMS_DESCRIBE.number_table;
   l_spare                DBMS_DESCRIBE.number_table;
   l_argument             all_arguments%ROWTYPE;
BEGIN
   g_programs.delete;
   l_all_arguments.delete;
   
   DBMS_UTILITY.name_resolve (program_in,
                              l_notused.must_be_one,
                              l_name.owner,
                              l_name.package_name,
                              l_name.object_name,
                              l_notused.dblink,
                              l_name.object_type,
                              l_notused.object_number);

   FOR rec
      IN (SELECT DISTINCT owner, package_name, object_name
            FROM all_arguments
           WHERE     owner = l_name.owner
             AND (   (    package_name = l_name.package_name
                      AND (   object_name = l_name.object_name
                           OR object_name_in IS NULL))
                  OR (    package_name IS NULL
                      AND l_name.package_name IS NULL
                      AND object_name = l_name.object_name)))
   LOOP
      DECLARE
         l_name   varchar2(400);
      BEGIN
         IF rec_in.package_name IS NOT NULL
         THEN
            l_name := rec_in.owner || '.' || rec_in.package_name;
         ELSE
            l_name := rec_in.owner;
         END IF;

         IF rec_in.object_name IS NOT NULL
         THEN
            l_name := l_name || '.' || rec_in.object_name;
         END IF;

         DBMS_DESCRIBE.describe_procedure (l_name,
                                           NULL,
                                           NULL,
                                           l_overload,
                                           l_position,
                                           l_level,
                                           l_argument_name,
                                           l_datatype,
                                           l_default_value,
                                           l_in_out,
                                           l_length,
                                           l_precision,
                                           l_scale,
                                           l_radix,
                                           l_spare);
         l_index := l_argument_name.FIRST;
      END;

      LOOP
         EXIT WHEN l_index IS NULL;
         l_argindx := NVL (retval.LAST, 0) + 1;

         retval (argindx_in).object_name := rec_in.object_name;
         retval (argindx_in).package_name := rec_in.package_name;
         retval (argindx_in).owner := rec_in.owner;
         retval (argindx_in).overload := l_overload (ddindx_in);
         retval (argindx_in).position := l_position (ddindx_in);
         retval (argindx_in).data_level := l_level (ddindx_in);
         retval (argindx_in).argument_name := l_argument_name (ddindx_in);
         retval (argindx_in).datatype := l_datatype (ddindx_in);
         retval (argindx_in).DEFAULT_VALUE := l_default_value (ddindx_in);
         retval (argindx_in).in_out := l_in_out (ddindx_in);
         
         SELECT *
           INTO l_argument
           FROM all_arguments
          WHERE object_name = l_all_arguments.object_name
            AND (   package_name = l_all_arguments.package_name
              OR (package_name IS NULL AND l_all_arguments.package_name IS NULL)
               )
            AND owner = l_all_arguments.owner
            AND (   overload = l_all_arguments.overload
              OR (    overload IS NULL
                  AND (l_all_arguments.overload = 0 OR l_all_arguments.overload IS NULL)
                 )
             )
            AND POSITION = l_all_arguments.position
            AND LEVEL = l_all_arguments.data_level
            AND argument_name = l_all_arguments.argument_name;

         l_all_arguments.character_set_name := l_argument.character_set_name;
         l_all_arguments.type_owner := l_argument.type_owner;
         l_all_arguments.type_name := l_argument.type_name;
         l_all_arguments.type_subname := l_argument.type_subname;
         l_all_arguments.type_link := l_argument.type_link;
         l_all_arguments.pls_type := l_argument.pls_type;
         l_all_arguments.char_length := l_argument.char_length;
         l_all_arguments.char_used := l_argument.char_used;

         l_index := l_argument_name.NEXT (l_index);
      END LOOP;
   END LOOP;

   IF l_all_arguments.COUNT > 0
   THEN
      l_argindx := l_all_arguments.FIRST;

      LOOP
         EXIT WHEN l_argindx IS NULL;

         /* Is it a procedure with no arguments? */
         IF     l_all_arguments (l_argindx).position = 1
            AND l_all_arguments (l_argindx).data_level = 0
            AND l_all_arguments (l_argindx).argument_name IS NULL
         THEN
            g_programs (
               l_all_arguments (l_argindx).object_name) (
               NVL (l_all_arguments (l_argindx).overload, 0)).last_nondefault_parm :=
               0;
            l_argindx := l_all_arguments.NEXT (l_argindx);
         
         /* Is it a function? */
         ELSIF l_all_arguments (l_argindx).position = 0
         THEN
            g_programs (
               l_all_arguments (l_argindx).object_name) (
               NVL (l_all_arguments (l_argindx).overload, 0)).return_clause.toplevel :=
               l_all_arguments (l_argindx);

            LOOP
               l_argindx := l_all_arguments.NEXT (l_argindx);
               EXIT WHEN (   l_argindx IS NULL
                          OR l_all_arguments (l_argindx).data_level = 0);
               g_programs (
                  l_all_arguments (l_argindx).object_name) (
                  NVL (l_all_arguments (l_argindx).overload, 0)).return_clause.breakouts (
                  l_breakout) :=
                  l_all_arguments (l_argindx);
               l_breakout := l_breakout + 1;
            END LOOP;
            
         /* Otherwise add the argument (and ignore "breakouts", such as record fields. */
         ELSIF l_all_arguments (l_argindx).data_level = 0
         THEN
            l_breakout_pos := 1;

            g_programs (
               l_all_arguments (l_argindx).object_name) (
               NVL (l_all_arguments (l_argindx).overload, 0)).parameters (
               c_position).toplevel :=
               l_all_arguments (argindx_in);

            IF l_all_arguments (argindx_in).DEFAULT_VALUE = 0
            THEN
               g_programs (
                  l_all_arguments (l_argindx).object_name) (
                  NVL (l_all_arguments (l_argindx).overload, 0)).last_nondefault_parm :=
                  l_all_arguments (l_argindx).position;
            END IF;

            LOOP
               l_argindx := l_all_arguments.NEXT (l_argindx);
               EXIT WHEN (   l_argindx IS NULL
                          OR l_all_arguments (l_argindx).data_level = 0);
               g_programs (
                  (l_all_arguments (l_argindx).object_name).NVL (
                     l_all_arguments (l_argindx).overload,
                     0)).parameters (l_all_arguments (l_argindx).position).breakouts (
                  l_breakout_pos) :=
                  l_all_arguments (l_argindx);
               l_breakout_pos := l_breakout_pos + 1;
            END LOOP;
         END IF;
      END LOOP;
   END IF;
END load_arguments;
/