CREATE OR REPLACE PROCEDURE genoldnewcompare (
   tab_in       IN   VARCHAR2
  ,sch_in       IN   VARCHAR2 := NULL
  ,display_in   IN   BOOLEAN := FALSE
  ,file_in      IN   VARCHAR2 := NULL
  ,dir_in       IN   VARCHAR2 := NULL
)
IS
   SUBTYPE identifier_t IS VARCHAR2 (100);

   v_tab         identifier_t := UPPER (tab_in);
   v_sch         identifier_t := NVL (UPPER (sch_in), USER);
   -- Send output to file or screen?
   v_to_screen   BOOLEAN      := file_in IS NULL;

   -- Array of output
   TYPE lines_t IS TABLE OF VARCHAR2 (1000)
      INDEX BY BINARY_INTEGER;

   output        lines_t;

   -- Now pl simply writes to the array.
   CURSOR cols_cur
   IS
      SELECT *
        FROM all_tab_columns
       WHERE owner = v_sch AND table_name = v_tab;

   PROCEDURE pl (str IN VARCHAR2)
   IS
   BEGIN
      output (NVL (output.LAST, 0) + 1) := str;
   END;

   -- Dump to screen or file.
   PROCEDURE dump_output
   IS
   BEGIN
      IF v_to_screen
      THEN
         FOR indx IN output.FIRST .. output.LAST
         LOOP
            DBMS_OUTPUT.put_line (output (indx));
         END LOOP;
      ELSE
         -- Send output to the specified file.
         DECLARE
            fid   UTL_FILE.file_type;
         BEGIN
            fid := UTL_FILE.fopen (dir_in, file_in, 'W');

            FOR indx IN output.FIRST .. output.LAST
            LOOP
               UTL_FILE.put_line (fid, output (indx));
            END LOOP;

            UTL_FILE.fclose (fid);
         EXCEPTION
            WHEN OTHERS
            THEN
               DBMS_OUTPUT.put_line (   'Failure to write output to '
                                     || dir_in
                                     || '/'
                                     || file_in
                                    );
               UTL_FILE.fclose (fid);
         END;
      END IF;
   END dump_output;
BEGIN
   FOR rec IN cols_cur
   LOOP
      pl ('IF   (   :OLD.' || rec.column_name || ' != :NEW.'
          || rec.column_name
         );
      pl (   '  OR (:OLD.'
          || rec.column_name
          || ' IS NULL AND :NEW.'
          || rec.column_name
          || ' IS NOT NULL)'
         );
      pl (   '  OR (:OLD.'
          || rec.column_name
          || ' IS NOT NULL AND :NEW.'
          || rec.column_name
          || ' IS NULL))'
         );
      pl ('THEN');
      pl ('   -- Logic to handle changed value here...');
      pl ('END IF;');
   END LOOP;

   dump_output;
END genoldnewcompare;
/