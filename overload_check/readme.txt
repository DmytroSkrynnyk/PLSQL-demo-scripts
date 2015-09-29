Codecheck - a code analysis utility
Version: 1.1.0
Status: BETA

PLEASE DO NOT DISTRIBUTE WITHOUT THE PERMISSION OF THE AUTHOR! 

Author: Steven Feuerstein, steven@stevenfeuerstein.com

Copyright 2002, Steven Feuerstein
All rights reserved


>>>> Installation:

To install Codecheck, execute the cc_install.sql script from within SQL*Plus:

SQL> @cc_install

Note: to install the ut_codecheck package without errors, you will need
to have utPLSQL installed. If you do not, don't worry! The ut_codecheck
is only used to test the utility. It is not required to use Codecheck.

>>>> Requirements: 

Privileges necessary to create sequences, tables, views and packages.

>>>> Instructions:

See Codecheck.doc, though you will not find instructions in the 
traditional sense, but the "story" of the creation of Codecheck.

Here are some very brief directions:

To analyze the overloadings of your package to determine whether
any two programs can be invoked in a way that is ambiguous and
will cause a compilation failure:

SET SERVEROUTPUT ON FORMAT WRAPPED SIZE 1000000
BEGIN
   codecheck.overloadings ('<package name>');
END;   

>>>> Contact information:

If you have any questions or problems, contact Steven Feuerstein
at steven@stevenfeuerstein.com
