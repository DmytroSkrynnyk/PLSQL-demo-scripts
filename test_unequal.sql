CREATE TABLE test_unequal (n NUMBER)
/

INSERT INTO test_unequal
       SELECT CASE ROWNUM WHEN 500000 THEN ROWNUM ELSE 1 END
         FROM DUAL
   CONNECT BY LEVEL < 1000001
/

DECLARE
   n   NUMBER;
BEGIN
   sf_timer.start_timer;

   FOR indx IN 1 .. 100
   LOOP
      BEGIN
         SELECT n
           INTO n
           FROM test_unequal
          WHERE n <> 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;
   END LOOP;

   sf_timer.show_elapsed_time ('<>');

   FOR indx IN 1 .. 100
   LOOP
      BEGIN
         SELECT n
           INTO n
           FROM test_unequal
          WHERE n != 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;
   END LOOP;

   sf_timer.show_elapsed_time ('!=');

   FOR indx IN 1 .. 100
   LOOP
      BEGIN
         SELECT n
           INTO n
           FROM test_unequal
          WHERE n ^= 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;
   END LOOP;

   sf_timer.show_elapsed_time ('^= ');

/* Not supported!
   FOR indx IN 1 .. 100
   LOOP
      BEGIN
         SELECT n
           INTO n
           FROM test_unequal
          WHERE n ~= 1;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
      END;
   END LOOP;

   sf_timer.show_elapsed_time ('~=');
   */
END;
/

DROP TABLE test_unequal
/