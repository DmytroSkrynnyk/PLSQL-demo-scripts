CREATE OR REPLACE PACKAGE ut_codecheck
/*
Codecheck: the QA utility for PL/SQL code
Copyright (C) 2002, Steven Feuerstein
All rights reserved

ut_codecheck: utPLSQL-compliant unit test package for Codecheck
*/
IS 
   PROCEDURE ut_setup;
   PROCEDURE ut_teardown;
   
   PROCEDURE ut_overloadings;
END ut_codecheck;
/
