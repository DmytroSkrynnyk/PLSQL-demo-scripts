CREATE OR REPLACE PROCEDURE showestack
-- invdefinv.sql
IS
BEGIN
   p.l (RPAD ('=', 60, '='));
   p.l (DBMS_UTILITY.format_call_stack);
   p.l (RPAD ('=', 60, '='));
END;
/
CREATE OR REPLACE PROCEDURE Proc1
AUTHID CURRENT_USER
IS
   num   PLS_INTEGER;
BEGIN
   SELECT COUNT (*)        
     INTO num
     FROM EMP;
   showestack;
   DBMS_OUTPUT.put_line (   'proc 1 invoker emp count '
                         || num);
END;
/
GRANT EXECUTE ON Proc1 TO hr;

CREATE OR REPLACE PROCEDURE Proc2
AUTHID DEFINER
IS
   num   PLS_INTEGER;
BEGIN
   SELECT COUNT (*)
     INTO num
     FROM EMP;
   showestack;
   DBMS_OUTPUT.put_line (   'proc 2 definer emp count '
                         || num);
   Proc1;
END;
/
GRANT EXECUTE ON Proc2 TO hr;

CREATE OR REPLACE PROCEDURE Proc3
AUTHID CURRENT_USER
IS
   num   PLS_INTEGER;
BEGIN
   SELECT COUNT (*)
     INTO num
     FROM EMP;
   showestack;
   DBMS_OUTPUT.put_line (   'proc 3 invoker emp count '
                         || num);
   proc1;
   Proc2;
END;
/

GRANT EXECUTE ON Proc3 TO hr;
GRANT EXECUTE ON Proc1 TO hr;
grant select on scott.emp to hr;
