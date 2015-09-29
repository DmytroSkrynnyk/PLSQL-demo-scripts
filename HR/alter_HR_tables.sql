-- Created on 22.08.2007 by TERLETSKYY 

-- Add/modify columns , row change number
ALTER TABLE COUNTRIES ADD RCN NUMBER DEFAULT 1; 
ALTER TABLE DEPARTMENTS ADD RCN NUMBER DEFAULT 1;
ALTER TABLE EMPLOYEES ADD RCN NUMBER DEFAULT 1; 
ALTER TABLE JOB_HISTORY ADD RCN NUMBER DEFAULT 1; 
ALTER TABLE JOBS ADD RCN NUMBER DEFAULT 1; 
ALTER TABLE LOCATIONS ADD RCN NUMBER DEFAULT 1; 
ALTER TABLE REGIONS ADD RCN NUMBER DEFAULT 1;

CREATE OR REPLACE TRIGGER TBI$DEPARTMENTS
  BEFORE INSERT
  ON  DEPARTMENTS
  FOR EACH ROW
/* -------------------------------------------------------------------------------------
Name       : TBI$Trigger
             BEFORE-INSERT-TRIGGER AUF TABELLE WPH.HANDELS_BUCH
Version    : 1
Autor      : ERwin
------------------------------------------------------------------------------------- */
WHEN ( NEW.DEPARTMENT_ID IS NULL)
DECLARE
BEGIN
  SELECT DEPARTMENTS_SEQ.NEXTVAL INTO :NEW.DEPARTMENT_ID FROM DUAL;
END;
/

CREATE OR REPLACE TRIGGER TBI$EMPLOYEES
  BEFORE INSERT
  ON  EMPLOYEES
  FOR EACH ROW
/* -------------------------------------------------------------------------------------
Name       : TBI$Trigger
             BEFORE-INSERT-TRIGGER AUF TABELLE WPH.HANDELS_BUCH
Version    : 1
Autor      : ERwin
------------------------------------------------------------------------------------- */
WHEN ( NEW.EMPLOYEE_ID IS NULL)
DECLARE
BEGIN
  SELECT EMPLOYEES_SEQ.NEXTVAL INTO :NEW.EMPLOYEE_ID FROM DUAL;
END;
/

CREATE OR REPLACE TRIGGER TBI$LOCATIONS
  BEFORE INSERT
  ON  LOCATIONS
  FOR EACH ROW
/* -------------------------------------------------------------------------------------
Name       : TBI$Trigger
             BEFORE-INSERT-TRIGGER AUF TABELLE WPH.HANDELS_BUCH
Version    : 1
Autor      : ERwin
------------------------------------------------------------------------------------- */
WHEN ( NEW.LOCATION_ID IS NULL)
DECLARE
BEGIN
  SELECT LOCATIONS_SEQ.NEXTVAL INTO :NEW.LOCATION_ID FROM DUAL;
END;
/


CREATE OR REPLACE TRIGGER TBU$COUNTRIES
  BEFORE UPDATE
  on  COUNTRIES
  for each row
/* -------------------------------------------------------------------------------------
Name       : TBU$Trigger
             BEFORE-UPDATE-TRIGGER AUF TABELLE WPH.HANDELS_BUCH
Version    : 1
Autor      : ERwin
------------------------------------------------------------------------------------- */
BEGIN
  :NEW.RCN  := :OLD.RCN + 1;
END;
/

CREATE OR REPLACE TRIGGER TBU$DEPARTMENTS
  BEFORE UPDATE
  on  DEPARTMENTS
  for each row
/* -------------------------------------------------------------------------------------
Name       : TBU$Trigger
             BEFORE-UPDATE-TRIGGER AUF TABELLE WPH.HANDELS_BUCH
Version    : 1
Autor      : ERwin
------------------------------------------------------------------------------------- */
BEGIN
  :NEW.RCN  := :OLD.RCN + 1;
END;
/

CREATE OR REPLACE TRIGGER TBU$EMPLOYEES
  BEFORE UPDATE
  on  EMPLOYEES
  for each row
/* -------------------------------------------------------------------------------------
Name       : TBU$Trigger
             BEFORE-UPDATE-TRIGGER AUF TABELLE WPH.HANDELS_BUCH
Version    : 1
Autor      : ERwin
------------------------------------------------------------------------------------- */
BEGIN
  :NEW.RCN  := :OLD.RCN + 1;
END;
/

CREATE OR REPLACE TRIGGER TBU$JOB_HISTORY
  BEFORE UPDATE
  on  JOB_HISTORY
  for each row
/* -------------------------------------------------------------------------------------
Name       : TBU$Trigger
             BEFORE-UPDATE-TRIGGER AUF TABELLE WPH.HANDELS_BUCH
Version    : 1
Autor      : ERwin
------------------------------------------------------------------------------------- */
BEGIN
  :NEW.RCN  := :OLD.RCN + 1;
END;
/

CREATE OR REPLACE TRIGGER TBU$JOBS
  BEFORE UPDATE
  on  JOBS
  for each row
/* -------------------------------------------------------------------------------------
Name       : TBU$Trigger
             BEFORE-UPDATE-TRIGGER AUF TABELLE WPH.HANDELS_BUCH
Version    : 1
Autor      : ERwin
------------------------------------------------------------------------------------- */
BEGIN
  :NEW.RCN  := :OLD.RCN + 1;
END;
/

CREATE OR REPLACE TRIGGER TBU$LOCATIONS
  BEFORE UPDATE
  on  LOCATIONS
  for each row
/* -------------------------------------------------------------------------------------
Name       : TBU$Trigger
             BEFORE-UPDATE-TRIGGER AUF TABELLE WPH.HANDELS_BUCH
Version    : 1
Autor      : ERwin
------------------------------------------------------------------------------------- */
BEGIN
  :NEW.RCN  := :OLD.RCN + 1;
END;
/

CREATE OR REPLACE TRIGGER TBU$REGIONS
  BEFORE UPDATE
  on  REGIONS
  for each row
/* -------------------------------------------------------------------------------------
Name       : TBU$Trigger
             BEFORE-UPDATE-TRIGGER AUF TABELLE WPH.HANDELS_BUCH
Version    : 1
Autor      : ERwin
------------------------------------------------------------------------------------- */
BEGIN
  :NEW.RCN  := :OLD.RCN + 1;
END;
/

