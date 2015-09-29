DECLARE
   PLS_INTEGER    VARCHAR2 (1);
   NO_DATA_FOUND   EXCEPTION;
BEGIN
   SELECT dummy
     INTO PLS_INTEGER
     FROM DUAL
    WHERE 1 = 2;

   IF PLS_INTEGER IS NULL
   THEN
      RAISE NO_DATA_FOUND;
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      DBMS_OUTPUT.put_line ('No dummy!');
END;