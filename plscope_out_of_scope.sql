/* Find out of scope references in code */

WITH declared_in
     AS (SELECT decl.NAME variable_name,
                ctxt.TYPE || '-' || ctxt.NAME declared_in
           FROM USER_IDENTIFIERS decl, USER_IDENTIFIERS ctxt
          WHERE     decl.USAGE_CONTEXT_ID = ctxt.USAGE_ID
                AND decl.TYPE = 'VARIABLE'
                AND decl.USAGE = 'DECLARATION'
                AND decl.OBJECT_NAME = ctxt.OBJECT_NAME
                AND decl.OBJECT_TYPE = ctxt.OBJECT_TYPE),
     vars_used_in
     AS (SELECT decl.NAME variable_name,
                ctxt.TYPE || '-' || ctxt.NAME referenced_in
           FROM USER_IDENTIFIERS decl, USER_IDENTIFIERS ctxt
          WHERE     decl.USAGE_CONTEXT_ID = ctxt.USAGE_ID
                AND decl.TYPE = 'VARIABLE'
                AND decl.USAGE IN ('REFERENCE', 'ASSIGNMENT')
                AND decl.OBJECT_NAME = ctxt.OBJECT_NAME
                AND decl.OBJECT_TYPE = ctxt.OBJECT_TYPE)
SELECT * FROM vars_used_in 
MINUS
SELECT * FROM declared_in
/