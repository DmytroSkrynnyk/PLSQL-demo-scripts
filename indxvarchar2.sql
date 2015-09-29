ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD'
/

CREATE OR REPLACE PACKAGE plch_pkg authid definer
IS
   TYPE counts_t IS TABLE OF DATE
      INDEX BY VARCHAR2 (100);
END;
/

DECLARE
   c_now date := date '2015-08-30';
   l_counts   plch_pkg.counts_t;
   l_max      DATE;
BEGIN
   FOR indx IN 1 .. 10
   LOOP
      l_counts (ADD_MONTHS (c_now, -indx)) :=
         ADD_MONTHS (c_now, indx);
   END LOOP;

   DBMS_OUTPUT.put_line ('Count = ' || l_counts.COUNT);

   --SELECT MAX (COLUMN_VALUE) INTO l_max FROM TABLE (l_counts);

   DBMS_OUTPUT.put_line ('Max1 = ' || l_max);
   l_max := l_counts.LAST;
   DBMS_OUTPUT.put_line ('Max2 = ' || l_max);
END;
/