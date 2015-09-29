CREATE OR REPLACE PACKAGE cc_error
/*
Codecheck: the QA utility for PL/SQL code
Copyright (C) 2002, Steven Feuerstein
All rights reserved

cc_error: consolidates all error-handling functionality
*/
IS
   c_assertion_failure EXCEPTION;
   PRAGMA exception_init (c_assertion_failure, -20999);
   
   c_max_error_#   CONSTANT PLS_INTEGER := -20801;
   c_min_error_#   CONSTANT PLS_INTEGER := -20802;
   
   c_not_a_package CONSTANT PLS_INTEGER := -20801;
   e_not_a_package          EXCEPTION;
   PRAGMA EXCEPTION_INIT (e_not_a_package, -20801);

   c_no_arguments CONSTANT PLS_INTEGER := -20802;
   e_no_arguments          EXCEPTION;
   PRAGMA EXCEPTION_INIT (e_no_arguments, -20802);

   FUNCTION errmsg (error_in IN PLS_INTEGER)
      RETURN cc_error_info.errmsg%TYPE;

   PROCEDURE RAISE (error_in IN PLS_INTEGER, msg_in IN VARCHAR2 := NULL);

   PROCEDURE assert (
      condition_in    IN   BOOLEAN
     ,error_in        IN   PLS_INTEGER
     ,extra_info_in   IN   VARCHAR2
   );
END cc_error;
/
