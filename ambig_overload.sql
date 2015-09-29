ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL'
/

CREATE OR replace PACKAGE salespkg AUTHID DEFINER
IS
   PROCEDURE calc_total (zone_in IN VARCHAR2);

   PROCEDURE calc_total (reg_in IN VARCHAR2);

END salespkg; 
/

CREATE OR replace PACKAGE BODY salespkg
IS
   PROCEDURE calc_total (zone_in IN VARCHAR2)
   IS
   BEGIN DBMS_OUTPUT.PUT_LINE ('zone'); END;

   PROCEDURE calc_total (reg_in IN VARCHAR2)
   IS
   BEGIN DBMS_OUTPUT.PUT_LINE ('region'); END;

END salespkg; 
/

BEGIN
   salespkg.calc_total ('zone15');
END;
/

BEGIN
   salespkg.calc_total (zone_in => 'zone15');
END;
/

CREATE OR replace PACKAGE salespkg AUTHID DEFINER
IS
   PROCEDURE calc_total (reg_in IN CHAR);

   PROCEDURE calc_total (reg_in IN VARCHAR2);

END salespkg; 
/
CREATE OR replace PACKAGE BODY salespkg
IS
   PROCEDURE calc_total (reg_in IN CHAR)
   IS
   BEGIN DBMS_OUTPUT.PUT_LINE ('region'); END;

   PROCEDURE calc_total (reg_in IN VARCHAR2)
   IS
   BEGIN DBMS_OUTPUT.PUT_LINE ('region'); END;

END salespkg; 
/   

BEGIN
   salespkg.calc_total ('reg11');
END;
/

BEGIN
   salespkg.calc_total (reg_in => 'reg11');
END;
/

DECLARE
   l_char   CHAR (2) := 'ab';
BEGIN
   salespkg.calc_total (reg_in => l_char);
END;
/

CREATE OR replace PACKAGE salespkg AUTHID DEFINER
IS
   PROCEDURE calc_total (zone_in IN CHAR, date_in in DATE DEFAULT SYSDATE);

   PROCEDURE calc_total (zone_in IN VARCHAR2);

END salespkg; 
/

CREATE OR replace PACKAGE BODY salespkg
IS
   PROCEDURE calc_total (zone_in IN CHAR, date_in in DATE DEFAULT SYSDATE)
   IS
   BEGIN DBMS_OUTPUT.PUT_LINE ('zone with date'); END;

   PROCEDURE calc_total (zone_in IN VARCHAR2)
   IS
   BEGIN DBMS_OUTPUT.PUT_LINE ('zone'); END;

END salespkg; 
/  

BEGIN
   salespkg.calc_total ('reg11');
END;
/ 

BEGIN
   salespkg.calc_total ('reg11', sysdate);
END;
/ 
