CREATE OR REPLACE PACKAGE nocopy_test
IS
   TYPE numbers_t IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;

   PROCEDURE pass_by_value (
      nums        IN OUT   numbers_t
   );

   PROCEDURE pass_by_ref (
      nums        IN OUT NOCOPY   numbers_t
   );

   PROCEDURE compare_methods (num IN PLS_INTEGER);
END;
/

CREATE OR REPLACE PACKAGE BODY nocopy_test
IS
   PROCEDURE pass_by_value (
      nums        IN OUT   numbers_t
   )
   IS
   BEGIN
      FOR indx IN nums.FIRST .. nums.LAST
      LOOP
         nums (indx) := nums (indx) * 2;
      END LOOP;
   END;

   PROCEDURE pass_by_ref (
      nums        IN OUT NOCOPY   numbers_t
   )
   IS
   BEGIN
      FOR indx IN nums.FIRST .. nums.LAST
      LOOP
         nums (indx) := nums (indx) * 2;
      END LOOP;
   END;

   PROCEDURE compare_methods (num IN PLS_INTEGER)
   IS
      l_numbers   numbers_t;

      PROCEDURE loadtab
      IS
      BEGIN
         DBMS_SESSION.free_unused_user_memory;
         l_numbers.DELETE;

         FOR indx IN 1 .. 100000
         LOOP
            l_numbers (indx) := indx;
         END LOOP;
      END;
   BEGIN
      loadtab;
      
      sf_timer.start_timer;

      FOR indx IN 1 .. num
      LOOP
         pass_by_value (l_numbers);
      END LOOP;

      sf_timer.show_elapsed_time ('By value ' || num);
      
      loadtab;
      
      sf_timer.start_timer;

      FOR indx IN 1 .. num
      LOOP
         pass_by_ref (l_numbers);
      END LOOP;

      sf_timer.show_elapsed_time ('By reference (NOCOPY) ' || num);
   END;
END;
/

BEGIN
   nocopy_test.compare_methods (500);
   
/*
Oracle 10g Release 2:
    By value without error 1000 Elapsed: 20.49 seconds.
    NOCOPY without error 1000 Elapsed: 12.32 seconds
    
11.2

By value without error 1000" completed in: 11.84 seconds
"NOCOPY without error 1000" completed in: 8.05 seconds

12.1

By value without error 1000 - Elapsed CPU : 11.3 seconds. Factored: .00011 seconds.
NOCOPY without error 1000 - Elapsed CPU : 7.24 seconds. Factored: .00007 seconds.
    
*/
END;
/