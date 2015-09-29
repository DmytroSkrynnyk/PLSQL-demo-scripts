CREATE OR REPLACE PROCEDURE dd_source_scan (
   package_filter_in     IN   VARCHAR2 := NULL,
   keyword_filter_in   IN   VARCHAR2 := NULL
)
IS 
   l_package   VARCHAR2 (100) := UPPER (package_filter_in);
   l_keyword   VARCHAR2 (100) := UPPER (keyword_filter_in);

   CURSOR source_cur (NAME_IN IN VARCHAR2, keyword_in IN VARCHAR2)
   IS
      SELECT name, line, text
        FROM all_source
       WHERE owner = 'SYS'
         AND name like name_in
		 AND type = 'PACKAGE'
         AND INSTR (UPPER (text), keyword_in) > 0;

   PROCEDURE pl (
      str         IN   VARCHAR2,
      len         IN   INTEGER := 80,
      expand_in   IN   BOOLEAN := TRUE
   )
   IS 
      v_len     PLS_INTEGER     := LEAST (len, 255);
      v_len2    PLS_INTEGER;
      v_chr10   PLS_INTEGER;
      v_str     VARCHAR2 (2000);
   BEGIN
      IF LENGTH (str) > v_len
      THEN
         v_chr10 := INSTR (str, CHR (10));

         IF v_chr10 > 0 AND v_len < v_chr10
         THEN
            v_len := v_chr10 - 1;
            v_len2 := v_chr10 + 1;
         ELSE
            v_len := v_len - 1;
            v_len2 := v_len;
         END IF;

         v_str := SUBSTR (str, 1, v_len);
         DBMS_OUTPUT.put_line (v_str);
         pl (SUBSTR (str, v_len2), len, expand_in);
      ELSE
         DBMS_OUTPUT.put_line (str);
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         /* TVP 9/99: Might want to use buffer size to STOP program */
         IF expand_in
         THEN
            DBMS_OUTPUT.ENABLE (1000000);
            DBMS_OUTPUT.put_line (v_str);
         ELSE
            RAISE;
         END IF;
   END;

   PROCEDURE assert (condition_in IN BOOLEAN, msg_in IN VARCHAR2 := NULL)
   IS
   BEGIN
      IF NOT condition_in OR condition_in IS NULL
      THEN
         IF msg_in IS NOT NULL
         THEN
            pl (msg_in);
         END IF;

         RAISE VALUE_ERROR;
      END IF;
   END;
BEGIN
   -- Need to provide at least one significant filter
   assert (NOT (NVL (l_package, '%') = '%' AND NVL (l_keyword, '%') = '%'));
   pl ('');
   pl ('Supplied Packages named "' || l_package ||
       '" containing text like "' || l_keyword || '"');
   pl ('');

   FOR rec IN source_cur (l_package, l_keyword)
   LOOP
      pl ('> ' || rec.name || '(' || rec.line || ') - ' || rec.text);
   END LOOP;
END;