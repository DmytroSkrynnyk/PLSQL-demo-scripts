CREATE OR REPLACE FUNCTION i_was_called_by (program_in IN VARCHAR2)
   RETURN BOOLEAN
IS
   c_stack   CONSTANT VARCHAR2 (32767) 
      := DBMS_UTILITY.format_call_stack;
BEGIN
   RETURN INSTR (SUBSTR (c_stack,
       INSTR (c_stack,
              CHR (10),1,5)+ 1,
              INSTR (c_stack, CHR (10),1,6)
                - INSTR (c_stack,CHR (10),1,5)
                         + 1),
       program_in) > 0;
END;
/

CREATE OR REPLACE FUNCTION i_was_called_by_12c (program_in IN VARCHAR2)
   RETURN BOOLEAN
IS
   c_stack   CONSTANT VARCHAR2 (32767) := DBMS_UTILITY.format_call_stack;
   c_new_line  CONSTANT CHAR (1)       := CHR (10);
   
BEGIN
   RETURN INSTR (SUBSTR (c_stack,
                           INSTR (c_stack,
                                  c_new_line,
                                  1,
                                  5)
                         + 1,
                           INSTR (c_stack,
                                  c_new_line,
                                  1,
                                  6)
                         - INSTR (c_stack,
                                  c_new_line,
                                  1,
                                  5)
                         + 1),
                 program_in) > 0;
END;
/

CREATE OR REPLACE PROCEDURE proc1
   IS
   BEGIN
      DBMS_OUTPUT.put_line (DBMS_UTILITY.format_call_stack);

      IF i_was_called_by ('PKG1') THEN
         DBMS_OUTPUT.put_line ('OK');

      ELSE
         DBMS_OUTPUT.put_line ('API violated');

      END IF;
      
      utl_call_stack_helper.show_call_stack_at(3);

   END;
/

CREATE OR REPLACE PACKAGE pkg1
IS

   PROCEDURE proc2;

END pkg1;
/

CREATE OR REPLACE PACKAGE BODY pkg1
IS

   PROCEDURE proc2
   IS
   BEGIN
      proc1;

   END;

END pkg1;
/

CREATE OR REPLACE PROCEDURE proc3
IS
BEGIN

   FOR indx IN 1 .. 1000
   LOOP
      NULL;

   END LOOP;
   pkg1.proc2;

END;
/
BEGIN
   proc3;

END;
/