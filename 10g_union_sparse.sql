CREATE OR REPLACE TYPE numbers_t IS TABLE OF NUMBER
/

DECLARE
   n1   numbers_t
           := numbers_t (1,
                         2,
                         3,
                         4);
   n2   numbers_t := numbers_t ();
   n3   numbers_t := numbers_t ();
BEGIN
   n1.delete (2);
   DBMS_OUTPUT.put_line ('count1=' || n1.COUNT);
   n3 := n1 MULTISET UNION n2;
   DBMS_OUTPUT.put_line ('first3=' || n3.FIRST);
   DBMS_OUTPUT.put_line ('last3=' || n3.LAST);
   DBMS_OUTPUT.put_line ('count3=' || n3.COUNT);

   FOR indx IN n3.FIRST .. n3.LAST
   LOOP
      BEGIN
         DBMS_OUTPUT.put_line (indx || '=' || n3 (indx));
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            DBMS_OUTPUT.put_line ('Undefined=' || indx);
      END;
   END LOOP;
END;
/