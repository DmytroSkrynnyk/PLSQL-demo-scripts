CREATE OR REPLACE TYPE ROW_EMPLOYEE UNDER TYPE_OBJECT
( -- object oriented ROWTYPE for EMPLOYEES table
  -- $Revision: 8696 $
  -- created : 2007-08-24 15:04:03

  -- attributes
    EMPLOYEE_ID     NUMBER(6)
  , FIRST_NAME      VARCHAR2(20)
  , LAST_NAME       VARCHAR2(25)
  , EMAIL           VARCHAR2(25)
  , PHONE_NUMBER    VARCHAR2(20)
  , HIRE_DATE       DATE
  , JOB_ID          VARCHAR2(10)
  , SALARY          NUMBER(8,2)
  , COMMISSION_PCT  NUMBER(2,2)
  , MANAGER_ID      NUMBER(6)
  , DEPARTMENT_ID   NUMBER(4)
  , RCN             NUMBER

  -- define constructors 
  , CONSTRUCTOR FUNCTION ROW_EMPLOYEE RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION ROW_EMPLOYEE(EMPLOYEE_ID NUMBER, FIRST_NAME VARCHAR2, LAST_NAME VARCHAR2, EMAIL VARCHAR2, PHONE_NUMBER VARCHAR2, HIRE_DATE DATE, JOB_ID VARCHAR2, SALARY NUMBER, COMMISSION_PCT NUMBER, MANAGER_ID NUMBER, DEPARTMENT_ID NUMBER
                                     , RCN NUMBER) RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION ROW_EMPLOYEE(IN_EMAIL VARCHAR2) RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION ROW_EMPLOYEE(IN_EMPLOYEE_ID NUMBER) RETURN SELF AS RESULT

  -- define member functions 
  , MEMBER FUNCTION ROW_EXISTS(IN_EMAIL VARCHAR2) RETURN BOOLEAN
  , MEMBER FUNCTION ROW_EXISTS(IN_EMPLOYEE_ID NUMBER) RETURN BOOLEAN
  , OVERRIDING MEMBER FUNCTION compare(in_type1 TYPE_OBJECT,in_type2 TYPE_OBJECT) RETURN INTEGER

  -- define member procedures
  , MEMBER PROCEDURE ROW_INSERT
  , MEMBER PROCEDURE ROW_UPDATE
  , MEMBER PROCEDURE ROW_MERGE
  , MEMBER PROCEDURE ROW_SAVE
  , MEMBER PROCEDURE ROW_DELETE
  , MEMBER PROCEDURE ROW_SELECT(IN_EMAIL VARCHAR2)
  , MEMBER PROCEDURE ROW_SELECT(IN_EMPLOYEE_ID NUMBER)
  , MEMBER PROCEDURE ROW_DEFAULT
  , MEMBER PROCEDURE ROW_LOCK
  , MEMBER PROCEDURE ROW_LOCK(IN_EMAIL VARCHAR2)
  , MEMBER PROCEDURE ROW_LOCK(IN_EMPLOYEE_ID NUMBER)
) NOT FINAL
/
CREATE OR REPLACE TYPE BODY ROW_EMPLOYEE IS
-- $Revision: 8696 $

  -- constructors
  CONSTRUCTOR FUNCTION ROW_EMPLOYEE RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'ROW_EMPLOYEE';
    SELF.ROW_DEFAULT();
    RETURN;

  END;

  ---------------------------------------------------------------

  CONSTRUCTOR FUNCTION ROW_EMPLOYEE(EMPLOYEE_ID NUMBER, FIRST_NAME VARCHAR2, LAST_NAME VARCHAR2, EMAIL VARCHAR2, PHONE_NUMBER VARCHAR2, HIRE_DATE DATE, JOB_ID VARCHAR2, SALARY NUMBER, COMMISSION_PCT NUMBER, MANAGER_ID NUMBER, DEPARTMENT_ID NUMBER
                                   , RCN NUMBER) RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'HR.ROW_EMPLOYEE';

    SELF.EMPLOYEE_ID    := EMPLOYEE_ID;
    SELF.FIRST_NAME     := FIRST_NAME;
    SELF.LAST_NAME      := LAST_NAME;
    SELF.EMAIL          := EMAIL;
    SELF.PHONE_NUMBER   := PHONE_NUMBER;
    SELF.HIRE_DATE      := HIRE_DATE;
    SELF.JOB_ID         := JOB_ID;
    SELF.SALARY         := SALARY;
    SELF.COMMISSION_PCT := COMMISSION_PCT;
    SELF.MANAGER_ID     := MANAGER_ID;
    SELF.DEPARTMENT_ID  := DEPARTMENT_ID;
    SELF.RCN            := RCN;
    RETURN;

  END;

  ---------------------------------------------------------------

  CONSTRUCTOR FUNCTION ROW_EMPLOYEE(IN_EMAIL VARCHAR2) RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'HR.ROW_EMPLOYEE';
    SELF.ROW_SELECT(IN_EMAIL => IN_EMAIL);
    RETURN;

  END;

  ---------------------------------------------------------------

  CONSTRUCTOR FUNCTION ROW_EMPLOYEE(IN_EMPLOYEE_ID NUMBER) RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'HR.ROW_EMPLOYEE';
    SELF.ROW_SELECT(IN_EMPLOYEE_ID => IN_EMPLOYEE_ID);
    RETURN;

  END;

  ---------------------------------------------------------------

  MEMBER FUNCTION ROW_EXISTS(IN_EMAIL VARCHAR2) RETURN BOOLEAN
  IS
    v_count  PLS_INTEGER;
  BEGIN

    SELECT COUNT(*)
    INTO v_count
    FROM HR.EMPLOYEES
    WHERE EMAIL = IN_EMAIL;
    RETURN (v_count <> 0);

  END;

  ---------------------------------------------------------------

  MEMBER FUNCTION ROW_EXISTS(IN_EMPLOYEE_ID NUMBER) RETURN BOOLEAN
  IS
    v_count  PLS_INTEGER;
  BEGIN

    SELECT COUNT(*)
    INTO v_count
    FROM HR.EMPLOYEES
    WHERE EMPLOYEE_ID = IN_EMPLOYEE_ID;
    RETURN (v_count <> 0);

  END;

  ---------------------------------------------------------------

  -- member functions
  OVERRIDING MEMBER FUNCTION COMPARE(in_type1 TYPE_OBJECT,in_type2 TYPE_OBJECT) RETURN INTEGER
  IS
    type1         ROW_EMPLOYEE := TREAT(in_type1 AS ROW_EMPLOYEE);
    type2         ROW_EMPLOYEE := TREAT(in_type2 AS ROW_EMPLOYEE);
  BEGIN

    IF      type1.EMPLOYEE_ID    = type2.EMPLOYEE_ID
      AND ( type1.FIRST_NAME     = type2.FIRST_NAME     OR (type1.FIRST_NAME     IS NULL AND type2.FIRST_NAME     IS NULL) )
      AND   type1.LAST_NAME      = type2.LAST_NAME
      AND   type1.EMAIL          = type2.EMAIL
      AND ( type1.PHONE_NUMBER   = type2.PHONE_NUMBER   OR (type1.PHONE_NUMBER   IS NULL AND type2.PHONE_NUMBER   IS NULL) )
      AND   type1.HIRE_DATE      = type2.HIRE_DATE
      AND   type1.JOB_ID         = type2.JOB_ID
      AND ( type1.SALARY         = type2.SALARY         OR (type1.SALARY         IS NULL AND type2.SALARY         IS NULL) )
      AND ( type1.COMMISSION_PCT = type2.COMMISSION_PCT OR (type1.COMMISSION_PCT IS NULL AND type2.COMMISSION_PCT IS NULL) )
      AND ( type1.MANAGER_ID     = type2.MANAGER_ID     OR (type1.MANAGER_ID     IS NULL AND type2.MANAGER_ID     IS NULL) )
      AND ( type1.DEPARTMENT_ID  = type2.DEPARTMENT_ID  OR (type1.DEPARTMENT_ID  IS NULL AND type2.DEPARTMENT_ID  IS NULL) )
      AND ( type1.RCN            = type2.RCN            OR (type1.RCN            IS NULL AND type2.RCN            IS NULL) )
    THEN
      RETURN 0; --gleich
    ELSE
      RETURN 1; --ungleich
    END IF;

  END;

  ---------------------------------------------------------------

  -- member procedures
  MEMBER PROCEDURE ROW_INSERT
  IS
  BEGIN

    INSERT INTO HR.EMPLOYEES ( EMPLOYEE_ID
                              ,FIRST_NAME
                              ,LAST_NAME
                              ,EMAIL
                              ,PHONE_NUMBER
                              ,HIRE_DATE
                              ,JOB_ID
                              ,SALARY
                              ,COMMISSION_PCT
                              ,MANAGER_ID
                              ,DEPARTMENT_ID
                    ) VALUES ( SELF.EMPLOYEE_ID
                              ,SELF.FIRST_NAME
                              ,SELF.LAST_NAME
                              ,SELF.EMAIL
                              ,SELF.PHONE_NUMBER
                              ,SELF.HIRE_DATE
                              ,SELF.JOB_ID
                              ,SELF.SALARY
                              ,SELF.COMMISSION_PCT
                              ,SELF.MANAGER_ID
                              ,SELF.DEPARTMENT_ID
                   ) RETURNING
                               EMPLOYEE_ID
                              ,FIRST_NAME
                              ,LAST_NAME
                              ,EMAIL
                              ,PHONE_NUMBER
                              ,HIRE_DATE
                              ,JOB_ID
                              ,SALARY
                              ,COMMISSION_PCT
                              ,MANAGER_ID
                              ,DEPARTMENT_ID
                              ,RCN
                    INTO
                               SELF.EMPLOYEE_ID
                              ,SELF.FIRST_NAME
                              ,SELF.LAST_NAME
                              ,SELF.EMAIL
                              ,SELF.PHONE_NUMBER
                              ,SELF.HIRE_DATE
                              ,SELF.JOB_ID
                              ,SELF.SALARY
                              ,SELF.COMMISSION_PCT
                              ,SELF.MANAGER_ID
                              ,SELF.DEPARTMENT_ID
                              ,SELF.RCN
                             ;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_UPDATE
  IS
  BEGIN

    UPDATE HR.EMPLOYEES
    SET FIRST_NAME     = SELF.FIRST_NAME
       ,LAST_NAME      = SELF.LAST_NAME
       ,EMAIL          = SELF.EMAIL
       ,PHONE_NUMBER   = SELF.PHONE_NUMBER
       ,HIRE_DATE      = SELF.HIRE_DATE
       ,JOB_ID         = SELF.JOB_ID
       ,SALARY         = SELF.SALARY
       ,COMMISSION_PCT = SELF.COMMISSION_PCT
       ,MANAGER_ID     = SELF.MANAGER_ID
       ,DEPARTMENT_ID  = SELF.DEPARTMENT_ID
    WHERE EMPLOYEE_ID = SELF.EMPLOYEE_ID
 		   AND RCN        = SELF.RCN
    RETURNING EMPLOYEE_ID
             ,FIRST_NAME
             ,LAST_NAME
             ,EMAIL
             ,PHONE_NUMBER
             ,HIRE_DATE
             ,JOB_ID
             ,SALARY
             ,COMMISSION_PCT
             ,MANAGER_ID
             ,DEPARTMENT_ID
             ,RCN
         INTO SELF.EMPLOYEE_ID
             ,SELF.FIRST_NAME
             ,SELF.LAST_NAME
             ,SELF.EMAIL
             ,SELF.PHONE_NUMBER
             ,SELF.HIRE_DATE
             ,SELF.JOB_ID
             ,SELF.SALARY
             ,SELF.COMMISSION_PCT
             ,SELF.MANAGER_ID
             ,SELF.DEPARTMENT_ID
             ,SELF.RCN
    ;

    IF SQL%ROWCOUNT <> 1 THEN
      RAISE_APPLICATION_ERROR(-20999,'Optimistic locking : ROW is to old');
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_MERGE 
  IS
  BEGIN

    MERGE INTO HR.EMPLOYEES A
    USING ( SELECT SELF.EMPLOYEE_ID    AS EMPLOYEE_ID
                  ,SELF.FIRST_NAME     AS FIRST_NAME
                  ,SELF.LAST_NAME      AS LAST_NAME
                  ,SELF.EMAIL          AS EMAIL
                  ,SELF.PHONE_NUMBER   AS PHONE_NUMBER
                  ,SELF.HIRE_DATE      AS HIRE_DATE
                  ,SELF.JOB_ID         AS JOB_ID
                  ,SELF.SALARY         AS SALARY
                  ,SELF.COMMISSION_PCT AS COMMISSION_PCT
                  ,SELF.MANAGER_ID     AS MANAGER_ID
                  ,SELF.DEPARTMENT_ID  AS DEPARTMENT_ID
            FROM DUAL ) B
    ON (    A.EMPLOYEE_ID = B.EMPLOYEE_ID)
    WHEN MATCHED THEN UPDATE SET   FIRST_NAME     = B.FIRST_NAME
                                  ,LAST_NAME      = B.LAST_NAME
                                  ,EMAIL          = B.EMAIL
                                  ,PHONE_NUMBER   = B.PHONE_NUMBER
                                  ,HIRE_DATE      = B.HIRE_DATE
                                  ,JOB_ID         = B.JOB_ID
                                  ,SALARY         = B.SALARY
                                  ,COMMISSION_PCT = B.COMMISSION_PCT
                                  ,MANAGER_ID     = B.MANAGER_ID
                                  ,DEPARTMENT_ID  = B.DEPARTMENT_ID
    WHEN NOT MATCHED THEN INSERT ( EMPLOYEE_ID
                                  ,FIRST_NAME
                                  ,LAST_NAME
                                  ,EMAIL
                                  ,PHONE_NUMBER
                                  ,HIRE_DATE
                                  ,JOB_ID
                                  ,SALARY
                                  ,COMMISSION_PCT
                                  ,MANAGER_ID
                                  ,DEPARTMENT_ID
                        ) VALUES ( B.EMPLOYEE_ID
                                  ,B.FIRST_NAME
                                  ,B.LAST_NAME
                                  ,B.EMAIL
                                  ,B.PHONE_NUMBER
                                  ,B.HIRE_DATE
                                  ,B.JOB_ID
                                  ,B.SALARY
                                  ,B.COMMISSION_PCT
                                  ,B.MANAGER_ID
                                  ,B.DEPARTMENT_ID
                                );

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_SAVE 
  IS
  BEGIN

    IF ROW_EXISTS(IN_EMPLOYEE_ID => SELF.EMPLOYEE_ID) THEN
      SELF.ROW_UPDATE;
    ELSE
      SELF.ROW_INSERT;
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_DELETE
  IS
  BEGIN

    DELETE FROM HR.EMPLOYEES
    WHERE EMPLOYEE_ID = SELF.EMPLOYEE_ID
		  AND RCN         = SELF.RCN
		;

    IF SQL%ROWCOUNT <> 1 THEN
      RAISE_APPLICATION_ERROR(-20999,'Optimistic locking : ROW is to old');
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_SELECT(IN_EMAIL VARCHAR2)
  IS
  BEGIN

    SELECT EMPLOYEE_ID
          ,FIRST_NAME
          ,LAST_NAME
          ,EMAIL
          ,PHONE_NUMBER
          ,HIRE_DATE
          ,JOB_ID
          ,SALARY
          ,COMMISSION_PCT
          ,MANAGER_ID
          ,DEPARTMENT_ID
          ,RCN
      INTO SELF.EMPLOYEE_ID
          ,SELF.FIRST_NAME
          ,SELF.LAST_NAME
          ,SELF.EMAIL
          ,SELF.PHONE_NUMBER
          ,SELF.HIRE_DATE
          ,SELF.JOB_ID
          ,SELF.SALARY
          ,SELF.COMMISSION_PCT
          ,SELF.MANAGER_ID
          ,SELF.DEPARTMENT_ID
          ,SELF.RCN
    FROM HR.EMPLOYEES
    WHERE EMAIL = IN_EMAIL;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_SELECT(IN_EMPLOYEE_ID NUMBER)
  IS
  BEGIN

    SELECT EMPLOYEE_ID
          ,FIRST_NAME
          ,LAST_NAME
          ,EMAIL
          ,PHONE_NUMBER
          ,HIRE_DATE
          ,JOB_ID
          ,SALARY
          ,COMMISSION_PCT
          ,MANAGER_ID
          ,DEPARTMENT_ID
          ,RCN
      INTO SELF.EMPLOYEE_ID
          ,SELF.FIRST_NAME
          ,SELF.LAST_NAME
          ,SELF.EMAIL
          ,SELF.PHONE_NUMBER
          ,SELF.HIRE_DATE
          ,SELF.JOB_ID
          ,SELF.SALARY
          ,SELF.COMMISSION_PCT
          ,SELF.MANAGER_ID
          ,SELF.DEPARTMENT_ID
          ,SELF.RCN
    FROM HR.EMPLOYEES
    WHERE EMPLOYEE_ID = IN_EMPLOYEE_ID;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_DEFAULT
  IS
  BEGIN

    SELF.RCN            := 1;

  END;


  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_LOCK
  IS
    lock_RCN                 NUMBER;
  BEGIN

    SELECT RCN
      INTO lock_RCN
    FROM HR.EMPLOYEES
    WHERE EMPLOYEE_ID = SELF.EMPLOYEE_ID
    FOR UPDATE
    ;

    IF SELF.RCN <> lock_RCN THEN
      SELF.ROW_SELECT( IN_EMPLOYEE_ID   => SELF.EMPLOYEE_ID
                     );
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_LOCK(IN_EMAIL VARCHAR2)
  IS
  BEGIN

    SELECT EMPLOYEE_ID
          ,FIRST_NAME
          ,LAST_NAME
          ,EMAIL
          ,PHONE_NUMBER
          ,HIRE_DATE
          ,JOB_ID
          ,SALARY
          ,COMMISSION_PCT
          ,MANAGER_ID
          ,DEPARTMENT_ID
          ,RCN
      INTO SELF.EMPLOYEE_ID
          ,SELF.FIRST_NAME
          ,SELF.LAST_NAME
          ,SELF.EMAIL
          ,SELF.PHONE_NUMBER
          ,SELF.HIRE_DATE
          ,SELF.JOB_ID
          ,SELF.SALARY
          ,SELF.COMMISSION_PCT
          ,SELF.MANAGER_ID
          ,SELF.DEPARTMENT_ID
          ,SELF.RCN
    FROM HR.EMPLOYEES
    WHERE EMAIL = IN_EMAIL
    FOR UPDATE
    ;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_LOCK(IN_EMPLOYEE_ID NUMBER)
  IS
  BEGIN

    SELECT EMPLOYEE_ID
          ,FIRST_NAME
          ,LAST_NAME
          ,EMAIL
          ,PHONE_NUMBER
          ,HIRE_DATE
          ,JOB_ID
          ,SALARY
          ,COMMISSION_PCT
          ,MANAGER_ID
          ,DEPARTMENT_ID
          ,RCN
      INTO SELF.EMPLOYEE_ID
          ,SELF.FIRST_NAME
          ,SELF.LAST_NAME
          ,SELF.EMAIL
          ,SELF.PHONE_NUMBER
          ,SELF.HIRE_DATE
          ,SELF.JOB_ID
          ,SELF.SALARY
          ,SELF.COMMISSION_PCT
          ,SELF.MANAGER_ID
          ,SELF.DEPARTMENT_ID
          ,SELF.RCN
    FROM HR.EMPLOYEES
    WHERE EMPLOYEE_ID = IN_EMPLOYEE_ID
    FOR UPDATE
    ;

  END;

  ---------------------------------------------------------------

END;
/
