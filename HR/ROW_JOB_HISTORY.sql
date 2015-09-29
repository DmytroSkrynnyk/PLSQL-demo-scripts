CREATE OR REPLACE TYPE ROW_JOB_HISTORY UNDER TYPE_OBJECT
( -- object oriented ROWTYPE for JOB_HISTORY table
  -- $Revision: 8696 $
  -- created : 2007-08-24 15:04:03

  -- attributes
    EMPLOYEE_ID    NUMBER(6)
  , START_DATE     DATE
  , END_DATE       DATE
  , JOB_ID         VARCHAR2(10)
  , DEPARTMENT_ID  NUMBER(4)
  , RCN            NUMBER

  -- define constructors 
  , CONSTRUCTOR FUNCTION ROW_JOB_HISTORY RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION ROW_JOB_HISTORY(EMPLOYEE_ID NUMBER, START_DATE DATE, END_DATE DATE, JOB_ID VARCHAR2, DEPARTMENT_ID NUMBER, RCN NUMBER) RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION ROW_JOB_HISTORY(IN_EMPLOYEE_ID NUMBER, IN_START_DATE DATE) RETURN SELF AS RESULT

  -- define member functions 
  , MEMBER FUNCTION ROW_EXISTS(IN_EMPLOYEE_ID NUMBER, IN_START_DATE DATE) RETURN BOOLEAN
  , OVERRIDING MEMBER FUNCTION compare(in_type1 TYPE_OBJECT,in_type2 TYPE_OBJECT) RETURN INTEGER

  -- define member procedures
  , MEMBER PROCEDURE ROW_INSERT
  , MEMBER PROCEDURE ROW_UPDATE
  , MEMBER PROCEDURE ROW_MERGE
  , MEMBER PROCEDURE ROW_SAVE
  , MEMBER PROCEDURE ROW_DELETE
  , MEMBER PROCEDURE ROW_SELECT(IN_EMPLOYEE_ID NUMBER, IN_START_DATE DATE)
  , MEMBER PROCEDURE ROW_DEFAULT
  , MEMBER PROCEDURE ROW_LOCK
  , MEMBER PROCEDURE ROW_LOCK(IN_EMPLOYEE_ID NUMBER, IN_START_DATE DATE)
) NOT FINAL
/
CREATE OR REPLACE TYPE BODY ROW_JOB_HISTORY IS
-- $Revision: 8696 $

  -- constructors
  CONSTRUCTOR FUNCTION ROW_JOB_HISTORY RETURN SELF AS RESULT
  IS
  BEGIN


    SELF.OBJECT_TYPE_NAME  := 'ROW_JOB_HISTORY';
    SELF.ROW_DEFAULT();
    RETURN;

  END;

  ---------------------------------------------------------------

  CONSTRUCTOR FUNCTION ROW_JOB_HISTORY(EMPLOYEE_ID NUMBER, START_DATE DATE, END_DATE DATE, JOB_ID VARCHAR2, DEPARTMENT_ID NUMBER, RCN NUMBER) RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'HR.ROW_JOB_HISTORY';

    SELF.EMPLOYEE_ID   := EMPLOYEE_ID;
    SELF.START_DATE    := START_DATE;
    SELF.END_DATE      := END_DATE;
    SELF.JOB_ID        := JOB_ID;
    SELF.DEPARTMENT_ID := DEPARTMENT_ID;
    SELF.RCN           := RCN;
    RETURN;

  END;

  ---------------------------------------------------------------

  CONSTRUCTOR FUNCTION ROW_JOB_HISTORY(IN_EMPLOYEE_ID NUMBER, IN_START_DATE DATE) RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'HR.ROW_JOB_HISTORY';
    SELF.ROW_SELECT(IN_EMPLOYEE_ID => IN_EMPLOYEE_ID, IN_START_DATE => IN_START_DATE);
    RETURN;

  END;

  ---------------------------------------------------------------

  MEMBER FUNCTION ROW_EXISTS(IN_EMPLOYEE_ID NUMBER, IN_START_DATE DATE) RETURN BOOLEAN
  IS
    v_count  PLS_INTEGER;
  BEGIN

    SELECT COUNT(*)
    INTO v_count
    FROM HR.JOB_HISTORY
    WHERE EMPLOYEE_ID = IN_EMPLOYEE_ID
      AND START_DATE  = IN_START_DATE;
    RETURN (v_count <> 0);

  END;

  ---------------------------------------------------------------

  -- member functions
  OVERRIDING MEMBER FUNCTION COMPARE(in_type1 TYPE_OBJECT,in_type2 TYPE_OBJECT) RETURN INTEGER
  IS
    type1         ROW_JOB_HISTORY := TREAT(in_type1 AS ROW_JOB_HISTORY);
    type2         ROW_JOB_HISTORY := TREAT(in_type2 AS ROW_JOB_HISTORY);
  BEGIN


    IF      type1.EMPLOYEE_ID   = type2.EMPLOYEE_ID
      AND   type1.START_DATE    = type2.START_DATE
      AND   type1.END_DATE      = type2.END_DATE
      AND   type1.JOB_ID        = type2.JOB_ID
      AND ( type1.DEPARTMENT_ID = type2.DEPARTMENT_ID OR (type1.DEPARTMENT_ID IS NULL AND type2.DEPARTMENT_ID IS NULL) )
      AND ( type1.RCN           = type2.RCN           OR (type1.RCN           IS NULL AND type2.RCN           IS NULL) )
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

    INSERT INTO HR.JOB_HISTORY ( EMPLOYEE_ID
                                ,START_DATE
                                ,END_DATE
                                ,JOB_ID
                                ,DEPARTMENT_ID
                      ) VALUES ( SELF.EMPLOYEE_ID
                                ,SELF.START_DATE
                                ,SELF.END_DATE
                                ,SELF.JOB_ID
                                ,SELF.DEPARTMENT_ID
                     ) RETURNING
                                 EMPLOYEE_ID
                                ,START_DATE
                                ,END_DATE
                                ,JOB_ID
                                ,DEPARTMENT_ID
                      INTO
                                 SELF.EMPLOYEE_ID
                                ,SELF.START_DATE
                                ,SELF.END_DATE
                                ,SELF.JOB_ID
                                ,SELF.DEPARTMENT_ID
                               ;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_UPDATE
  IS
  BEGIN

    UPDATE HR.JOB_HISTORY
    SET END_DATE      = SELF.END_DATE
       ,JOB_ID        = SELF.JOB_ID
       ,DEPARTMENT_ID = SELF.DEPARTMENT_ID
    WHERE EMPLOYEE_ID = SELF.EMPLOYEE_ID
      AND START_DATE  = SELF.START_DATE
      AND RCN         = SELF.RCN
    RETURNING EMPLOYEE_ID
             ,START_DATE
             ,END_DATE
             ,JOB_ID
             ,DEPARTMENT_ID
             ,RCN
         INTO SELF.EMPLOYEE_ID
             ,SELF.START_DATE
             ,SELF.END_DATE
             ,SELF.JOB_ID
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

    MERGE INTO HR.JOB_HISTORY A
    USING ( SELECT SELF.EMPLOYEE_ID   AS EMPLOYEE_ID
                  ,SELF.START_DATE    AS START_DATE
                  ,SELF.END_DATE      AS END_DATE
                  ,SELF.JOB_ID        AS JOB_ID
                  ,SELF.DEPARTMENT_ID AS DEPARTMENT_ID
            FROM DUAL ) B
    ON (    A.EMPLOYEE_ID = B.EMPLOYEE_ID
        AND A.START_DATE  = B.START_DATE)
    WHEN MATCHED THEN UPDATE SET   END_DATE      = B.END_DATE
                                  ,JOB_ID        = B.JOB_ID
                                  ,DEPARTMENT_ID = B.DEPARTMENT_ID
    WHEN NOT MATCHED THEN INSERT ( EMPLOYEE_ID
                                  ,START_DATE
                                  ,END_DATE
                                  ,JOB_ID
                                  ,DEPARTMENT_ID
                        ) VALUES ( B.EMPLOYEE_ID
                                  ,B.START_DATE
                                  ,B.END_DATE
                                  ,B.JOB_ID
                                  ,B.DEPARTMENT_ID
                                );

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_SAVE 
  IS
  BEGIN

    IF ROW_EXISTS(IN_EMPLOYEE_ID => SELF.EMPLOYEE_ID, IN_START_DATE => SELF.START_DATE) THEN
      SELF.ROW_UPDATE;
    ELSE
      SELF.ROW_INSERT;
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_DELETE
  IS
  BEGIN

    DELETE FROM HR.JOB_HISTORY
    WHERE EMPLOYEE_ID = SELF.EMPLOYEE_ID
      AND START_DATE  = SELF.START_DATE
      AND RCN         = SELF.RCN
		;

    IF SQL%ROWCOUNT <> 1 THEN
      RAISE_APPLICATION_ERROR(-20999,'Optimistic locking : ROW is to old');
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_SELECT(IN_EMPLOYEE_ID NUMBER, IN_START_DATE DATE)
  IS
  BEGIN

    SELECT EMPLOYEE_ID
          ,START_DATE
          ,END_DATE
          ,JOB_ID
          ,DEPARTMENT_ID
          ,RCN
      INTO SELF.EMPLOYEE_ID
          ,SELF.START_DATE
          ,SELF.END_DATE
          ,SELF.JOB_ID
          ,SELF.DEPARTMENT_ID
          ,SELF.RCN
    FROM HR.JOB_HISTORY
    WHERE EMPLOYEE_ID = IN_EMPLOYEE_ID
      AND START_DATE  = IN_START_DATE;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_DEFAULT
  IS
  BEGIN

    SELF.RCN           := 1;

  END;


  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_LOCK
  IS
    lock_RCN                 NUMBER;
  BEGIN

    SELECT RCN
      INTO lock_RCN
    FROM HR.JOB_HISTORY
    WHERE EMPLOYEE_ID = SELF.EMPLOYEE_ID
		  AND START_DATE  = SELF.START_DATE
    FOR UPDATE
    ;

    IF SELF.RCN <> lock_RCN THEN
      SELF.ROW_SELECT( IN_EMPLOYEE_ID   => SELF.EMPLOYEE_ID
			               , IN_START_DATE    => SELF.START_DATE
                     );
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_LOCK(IN_EMPLOYEE_ID NUMBER, IN_START_DATE DATE)
  IS
  BEGIN

    SELECT EMPLOYEE_ID
          ,START_DATE
          ,END_DATE
          ,JOB_ID
          ,DEPARTMENT_ID
          ,RCN
      INTO SELF.EMPLOYEE_ID
          ,SELF.START_DATE
          ,SELF.END_DATE
          ,SELF.JOB_ID
          ,SELF.DEPARTMENT_ID
          ,SELF.RCN
    FROM HR.JOB_HISTORY
    WHERE EMPLOYEE_ID = IN_EMPLOYEE_ID
      AND START_DATE  = IN_START_DATE
    FOR UPDATE
    ;

  END;

  ---------------------------------------------------------------

END;
/
