CREATE OR REPLACE PROCEDURE delemps (enametab IN DBMS_SQL.VARCHAR2_TABLE)
IS   
   cur PLS_INTEGER := DBMS_SQL.OPEN_CURSOR;
   
   empnotab DBMS_SQL.NUMBER_TABLE;
   fdbk PLS_INTEGER;
BEGIN
   p.l (enametab.count);
   DBMS_SQL.PARSE (cur,
     'DELETE FROM employee2 WHERE last_name LIKE UPPER (:ename) ' ||
     ' RETURNING employee_id INTO :empnos',
     DBMS_SQL.NATIVE);

   DBMS_SQL.BIND_ARRAY (cur, 'ename', enametab);
   DBMS_SQL.BIND_ARRAY (cur, 'empnos', empnotab);

   fdbk := DBMS_SQL.EXECUTE (cur);
   DBMS_SQL.VARIABLE_VALUE (cur, 'empnos', empnotab);
   p.l (empnotab.count);

   FOR indx IN empnotab.FIRST .. empnotab.LAST
   LOOP
      p.l (empnotab(indx));
   END LOOP;
   DBMS_SQL.CLOSE_CURSOR (cur);
END;
/           
