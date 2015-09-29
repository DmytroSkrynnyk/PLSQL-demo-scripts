/* Formatted on 2002/10/05 11:24 (Formatter Plus v4.7.0) */

set linesize 90
set pagesize 60
set verify off
column name format a40
column ovld1 format a5
column ovld2 format a5
column start1 format 9999
column end1 format 9999
column start2 format 9999
column end2 format 9999

ttitle 'Contents of cc_ambig_ovld_results'
SELECT OWNER|| '.' ||PACKAGE_NAME||'.'||OBJECT_NAME name,
OVERLOAD1  ovld1,STARTARG1 start1,    ENDARG1 end1,
OVERLOAD2  ovld2,STARTARG2 start2,   ENDARG2 end2
  FROM cc_ambig_ovld_results
  order by OWNER|| '.' ||PACKAGE_NAME||'.'||OBJECT_NAME ,
OVERLOAD1  ,STARTARG1,    ENDARG1,
OVERLOAD2  ,STARTARG2,    ENDARG2;

ttitle 'Contents of cc_ovld_outcomes'
SELECT OWNER|| '.' ||PACKAGE_NAME||'.'||OBJECT_NAME name,
OVERLOAD1  ovld1,STARTARG1 start1,    ENDARG1 end1,
OVERLOAD2  ovld2,STARTARG2 start2,   ENDARG2 end2
  FROM cc_ovld_outcomes
  order by OWNER|| '.' ||PACKAGE_NAME||'.'||OBJECT_NAME ,
OVERLOAD1  ,STARTARG1,    ENDARG1,
OVERLOAD2  ,STARTARG2,    ENDARG2;