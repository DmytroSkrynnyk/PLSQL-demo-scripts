ALTER SESSION SET PLSQL_CCFLAGS =
     'nocopy_use_strings:true,nocopy_use_global:true'
/

CREATE OR REPLACE PACKAGE nocopy_test AUTHID DEFINER
IS
   TYPE numbers_t IS TABLE OF  
      $IF $$nocopy_use_strings $THEN VARCHAR2 (32767)
      $ELSE NUMBER
      $END
   INDEX BY BINARY_INTEGER;

   l_numbers   numbers_t;

   PROCEDURE pass_by_value (nums IN OUT numbers_t);

   PROCEDURE pass_by_ref (nums IN OUT NOCOPY numbers_t);

   PROCEDURE init (nums IN OUT NOCOPY numbers_t);
END;
/

CREATE OR REPLACE PACKAGE BODY nocopy_test
IS
   PROCEDURE pass_by_value (nums IN OUT numbers_t)
   IS
      indx   INT;
   BEGIN
      indx := nums.COUNT;
   END;

   PROCEDURE pass_by_ref (nums IN OUT NOCOPY numbers_t)
   IS
      indx   INT;
   BEGIN
      indx := nums.COUNT;
   END;

   PROCEDURE init (nums IN OUT NOCOPY numbers_t)
   IS
   BEGIN
      nums.delete;

      FOR indx IN 1 .. 10000
      LOOP
         nums (indx) :=  
            $IF $$nocopy_use_strings $THEN RPAD (indx, 32000, 'x');
            $ELSE indx;
            $END
      END LOOP;
   END;
END;
/

CREATE OR REPLACE PROCEDURE nocopy_test_by_value
   AUTHID DEFINER
IS
   l_start   PLS_INTEGER;
   l_numbers   nocopy_test.numbers_t;

   PROCEDURE show_elapsed (NAME_IN IN VARCHAR2)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (
            $IF $$nocopy_use_global $THEN 'Global '  
            $ELSE 'Local ' $END
         || $IF $$nocopy_use_strings $THEN 'Strings '  
            $ELSE 'Numbers ' $END
         || NAME_IN
         || ' elapsed CPU time: '
         || TO_CHAR (DBMS_UTILITY.get_cpu_time - l_start));
   END show_elapsed;
BEGIN
   nocopy_test.init ( 
      $IF $$nocopy_use_global $THEN nocopy_test.l_numbers  
      $ELSE l_numbers $END
   );
   
   l_start := DBMS_UTILITY.get_cpu_time;

   FOR indx IN 1 .. 20
   LOOP
      nocopy_test.pass_by_value ( 
         $IF $$nocopy_use_global $THEN nocopy_test.l_numbers  
         $ELSE l_numbers $END
      );
   END LOOP;

   show_elapsed ('By value');
END;
/

CREATE OR REPLACE PROCEDURE nocopy_test_by_ref
   AUTHID DEFINER
IS
   l_start     PLS_INTEGER;
   l_numbers   nocopy_test.numbers_t;

   PROCEDURE show_elapsed (NAME_IN IN VARCHAR2)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (
            $IF $$nocopy_use_global $THEN 'Global '  
            $ELSE 'Local ' $END
         || $IF $$nocopy_use_strings $THEN 'Strings '  
            $ELSE 'Numbers ' $END
         || NAME_IN
         || ' elapsed CPU time: '
         || TO_CHAR (DBMS_UTILITY.get_cpu_time - l_start));
   END show_elapsed;
BEGIN
   nocopy_test.init ( 
      $IF $$nocopy_use_global $THEN nocopy_test.l_numbers  
      $ELSE l_numbers $END
   );

   l_start := DBMS_UTILITY.get_cpu_time;

   FOR indx IN 1 .. 20
   LOOP
      nocopy_test.pass_by_ref ( 
         $IF $$nocopy_use_global $THEN nocopy_test.l_numbers  
         $ELSE l_numbers $END
      );
   END LOOP;

   show_elapsed ('By reference (NOCOPY)');
END;
/

BEGIN
   nocopy_test_by_value;
END;
/

BEGIN
   nocopy_test_by_ref;
END;
/

ALTER SESSION SET PLSQL_CCFLAGS =
     'nocopy_use_strings:false,nocopy_use_global:true'
/

ALTER PACKAGE nocopy_test COMPILE
/

ALTER PROCEDURE nocopy_test_by_value COMPILE
/

ALTER PROCEDURE nocopy_test_by_ref COMPILE
/


BEGIN
   nocopy_test_by_value;
END;
/

BEGIN
   nocopy_test_by_ref;
END;
/

ALTER SESSION SET PLSQL_CCFLAGS =
     'nocopy_use_strings:true,nocopy_use_global:false'
/

ALTER PACKAGE nocopy_test COMPILE
/

ALTER PROCEDURE nocopy_test_by_value COMPILE
/

ALTER PROCEDURE nocopy_test_by_ref COMPILE
/

BEGIN
   nocopy_test_by_value;
END;
/

BEGIN
   nocopy_test_by_ref;
END;
/