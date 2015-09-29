CREATE OR REPLACE PROCEDURE by_reference_proc (
   by_ref_in IN NUMBER) AUTHID DEFINER
IS
BEGIN
   DBMS_OUTPUT.PUT_LINE ('References actual directly: ' || by_ref_in);
END;
/

CREATE OR REPLACE PROCEDURE by_value_proc (
   by_value_io IN OUT NUMBER,
   by_value_o     OUT NUMBER) AUTHID DEFINER
IS
BEGIN
   DBMS_OUTPUT.PUT_LINE ('Makes copy of by_value_io coming in');
   DBMS_OUTPUT.PUT_LINE ('Copies by_value_io and by_value_o going out');
   
   by_value_io := by_value_io * 2;
   by_value_o := 100;
   
   IF by_value_io > 200
   THEN
      RAISE VALUE_ERROR;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.PUT_LINE (
         'No copying going out if ending with exception');
      RAISE;
END;
/

DECLARE
   l_in_out NUMBER := 100;
   l_out NUMBER := 200;
BEGIN
   by_value_proc (l_in_out, l_out); 
   DBMS_OUTPUT.PUT_LINE ('l_in_out = ' || l_in_out);
   DBMS_OUTPUT.PUT_LINE ('l_out = ' || l_out);
END;
/


DECLARE
   l_in_out NUMBER := 1000;
   l_out NUMBER := 200;
BEGIN
   by_value_proc (l_in_out, l_out); 
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.PUT_LINE ('Error! l_in_out = ' || l_in_out);
      DBMS_OUTPUT.PUT_LINE ('Error! l_out = ' || l_out);
END;
/

   