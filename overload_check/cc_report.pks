CREATE OR REPLACE PACKAGE cc_report
/*
Codecheck: the QA utility for PL/SQL code
Copyright (C) 2002, Steven Feuerstein
All rights reserved

cc_report: reporting API
*/
IS
   PROCEDURE initialize (package_in IN VARCHAR2);
   
   PROCEDURE ambig_ovld (
      owner_in IN VARCHAR2
     ,package_name_in IN VARCHAR2
     ,object_name_in IN VARCHAR2
     ,overload1_in IN PLS_INTEGER
     ,startarg1_in IN PLS_INTEGER
     ,endarg1_in IN PLS_INTEGER
     ,overload2_in IN PLS_INTEGER
     ,startarg2_in IN PLS_INTEGER
     ,endarg2_in IN PLS_INTEGER
   );
   
   PROCEDURE ambig_ovld_noargs (
      owner_in IN VARCHAR2
     ,package_name_in IN VARCHAR2
     ,object_name_in IN VARCHAR2
     ,overload1_in IN PLS_INTEGER
     ,overload2_in IN PLS_INTEGER
   );   

   PROCEDURE show_ambig_ovld_results (
      package_in IN VARCHAR2
     ,verbose_in IN BOOLEAN := FALSE
   );

   PROCEDURE bad_name (
      name_in IN VARCHAR2
     ,shouldbe_name_in in VARCHAR2
   ); 
   
      PROCEDURE show_bad_names (
      program_in IN VARCHAR2
     ,verbose_in IN BOOLEAN := FALSE
   );
END cc_report;
/

