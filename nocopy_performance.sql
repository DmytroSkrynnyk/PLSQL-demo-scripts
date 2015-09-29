CREATE OR REPLACE PACKAGE nocopy_test
   AUTHID DEFINER
IS
   TYPE numbers_t IS TABLE OF VARCHAR2 (32767)
      INDEX BY BINARY_INTEGER;

   PROCEDURE pass_by_value (nums IN OUT numbers_t);

   PROCEDURE pass_by_reference (nums IN OUT NOCOPY numbers_t);

   PROCEDURE init;

   PROCEDURE by_value_performance;

   PROCEDURE by_reference_performance;
END;
/

CREATE OR REPLACE PACKAGE BODY nocopy_test
IS
   l_numbers   numbers_t;

   PROCEDURE pass_by_value (nums IN OUT numbers_t)
   IS
      indx   INT;
   BEGIN
      indx := nums.COUNT;
   END;

   PROCEDURE pass_by_reference (nums IN OUT NOCOPY numbers_t)
   IS
      indx   INT;
   BEGIN
      indx := nums.COUNT;
   END;

   PROCEDURE init
   IS
   BEGIN
      l_numbers.delete;

      FOR indx IN 1 .. 10000
      LOOP
         l_numbers (indx) := RPAD (indx, 32000, 'x');
      END LOOP;
   END;

   PROCEDURE by_value_performance
   IS
      l_start   PLS_INTEGER;

      PROCEDURE show_elapsed (NAME_IN IN VARCHAR2)
      IS
      BEGIN
         DBMS_OUTPUT.put_line (
               NAME_IN
            || ' elapsed CPU time: '
            || TO_CHAR (DBMS_UTILITY.get_cpu_time - l_start));
      END show_elapsed;
   BEGIN
      l_start := DBMS_UTILITY.get_cpu_time;

      FOR indx IN 1 .. 20
      LOOP
         pass_by_value (l_numbers);
      END LOOP;

      show_elapsed ('By value');
   END;

   PROCEDURE by_reference_performance
   IS
      l_start   PLS_INTEGER;

      PROCEDURE show_elapsed (NAME_IN IN VARCHAR2)
      IS
      BEGIN
         DBMS_OUTPUT.put_line (
               NAME_IN
            || ' elapsed CPU time: '
            || TO_CHAR (DBMS_UTILITY.get_cpu_time - l_start));
      END show_elapsed;
   BEGIN
      l_start := DBMS_UTILITY.get_cpu_time;

      FOR indx IN 1 .. 20
      LOOP
         pass_by_reference (l_numbers);
      END LOOP;

      show_elapsed ('By reference');
   END;
END;
/

BEGIN
   nocopy_test.init;
   nocopy_test.by_value_performance;
   nocopy_test.by_reference_performance;
END;
/