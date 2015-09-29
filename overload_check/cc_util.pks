CREATE OR REPLACE PACKAGE cc_util
/*
Codecheck: the QA utility for PL/SQL code
Copyright (C) 2002, Steven Feuerstein
All rights reserved

cc_util: holds the general utilities used by Codecheck packages
*/
IS   
   -- Encapsulation over DBMS_OUTPUT.PUT_LINE

   PROCEDURE pl (str IN VARCHAR2, len IN INTEGER := 80);
   PROCEDURE pl (val IN BOOLEAN);
   PROCEDURE pl (str IN VARCHAR2, bool IN BOOLEAN);
  
   -- In-line conditional function, a simplified DECODE
   
   FUNCTION ifelse (
      condition_in IN BOOLEAN
     ,iftrue IN VARCHAR2
     ,iffalse IN VARCHAR2
     ,ifnull IN VARCHAR2 := NULL
   )
      RETURN VARCHAR2;   
  
   -- Compatible functionality with SQL NVL2 function
   
   FUNCTION NVL2 (
	   val_in      IN   VARCHAR2,
	   ifnull      IN   VARCHAR2,
	   ifnotnull   IN   VARCHAR2
	)
	   RETURN VARCHAR2;
          	  
END cc_util;
/
