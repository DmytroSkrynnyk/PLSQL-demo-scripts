CREATE OR REPLACE TYPE ROW_JOB UNDER TYPE_OBJECT
( -- object oriented ROWTYPE for JOBS table
  -- $Revision: 8696 $
  -- created : 2007-08-24 15:04:03

  -- attributes
    JOB_ID      VARCHAR2(10)
  , JOB_TITLE   VARCHAR2(35)
  , MIN_SALARY  NUMBER(6)
  , MAX_SALARY  NUMBER(6)
  , RCN         NUMBER

  -- define constructors 
  , CONSTRUCTOR FUNCTION ROW_JOB RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION ROW_JOB(JOB_ID VARCHAR2, JOB_TITLE VARCHAR2, MIN_SALARY NUMBER, MAX_SALARY NUMBER, RCN NUMBER) RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION ROW_JOB(IN_JOB_ID VARCHAR2) RETURN SELF AS RESULT

  -- define member functions 
  , MEMBER FUNCTION ROW_EXISTS(IN_JOB_ID VARCHAR2) RETURN BOOLEAN
  , OVERRIDING MEMBER FUNCTION compare(in_type1 TYPE_OBJECT,in_type2 TYPE_OBJECT) RETURN INTEGER

  -- define member procedures
  , MEMBER PROCEDURE ROW_INSERT
  , MEMBER PROCEDURE ROW_UPDATE
  , MEMBER PROCEDURE ROW_MERGE
  , MEMBER PROCEDURE ROW_SAVE
  , MEMBER PROCEDURE ROW_DELETE
  , MEMBER PROCEDURE ROW_SELECT(IN_JOB_ID VARCHAR2)
  , MEMBER PROCEDURE ROW_DEFAULT
  , MEMBER PROCEDURE ROW_LOCK
  , MEMBER PROCEDURE ROW_LOCK(IN_JOB_ID VARCHAR2)
) NOT FINAL
/
CREATE OR REPLACE TYPE BODY ROW_JOB IS
-- $Revision: 8696 $

  -- constructors
  CONSTRUCTOR FUNCTION ROW_JOB RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'ROW_JOB';
    SELF.ROW_DEFAULT();
    RETURN;

  END;

  ---------------------------------------------------------------

  CONSTRUCTOR FUNCTION ROW_JOB(JOB_ID VARCHAR2, JOB_TITLE VARCHAR2, MIN_SALARY NUMBER, MAX_SALARY NUMBER, RCN NUMBER) RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'HR.ROW_JOB';

    SELF.JOB_ID     := JOB_ID;
    SELF.JOB_TITLE  := JOB_TITLE;
    SELF.MIN_SALARY := MIN_SALARY;
    SELF.MAX_SALARY := MAX_SALARY;
    SELF.RCN        := RCN;
    RETURN;

  END;

  ---------------------------------------------------------------

  CONSTRUCTOR FUNCTION ROW_JOB(IN_JOB_ID VARCHAR2) RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'HR.ROW_JOB';
    SELF.ROW_SELECT(IN_JOB_ID => IN_JOB_ID);
    RETURN;

  END;

  ---------------------------------------------------------------

  MEMBER FUNCTION ROW_EXISTS(IN_JOB_ID VARCHAR2) RETURN BOOLEAN
  IS
    v_count  PLS_INTEGER;
  BEGIN

    SELECT COUNT(*)
    INTO v_count
    FROM HR.JOBS
    WHERE JOB_ID = IN_JOB_ID;
    RETURN (v_count <> 0);

  END;

  ---------------------------------------------------------------

  -- member functions
  OVERRIDING MEMBER FUNCTION COMPARE(in_type1 TYPE_OBJECT,in_type2 TYPE_OBJECT) RETURN INTEGER
  IS
    type1         ROW_JOB := TREAT(in_type1 AS ROW_JOB);
    type2         ROW_JOB := TREAT(in_type2 AS ROW_JOB);
  BEGIN

    IF      type1.JOB_ID     = type2.JOB_ID
      AND   type1.JOB_TITLE  = type2.JOB_TITLE
      AND ( type1.MIN_SALARY = type2.MIN_SALARY OR (type1.MIN_SALARY IS NULL AND type2.MIN_SALARY IS NULL) )
      AND ( type1.MAX_SALARY = type2.MAX_SALARY OR (type1.MAX_SALARY IS NULL AND type2.MAX_SALARY IS NULL) )
      AND ( type1.RCN        = type2.RCN        OR (type1.RCN        IS NULL AND type2.RCN        IS NULL) )
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

    INSERT INTO HR.JOBS ( JOB_ID
                         ,JOB_TITLE
                         ,MIN_SALARY
                         ,MAX_SALARY
               ) VALUES ( SELF.JOB_ID
                         ,SELF.JOB_TITLE
                         ,SELF.MIN_SALARY
                         ,SELF.MAX_SALARY
              ) RETURNING
                          JOB_ID
                         ,JOB_TITLE
                         ,MIN_SALARY
                         ,MAX_SALARY
                         ,RCN
               INTO
                          SELF.JOB_ID
                         ,SELF.JOB_TITLE
                         ,SELF.MIN_SALARY
                         ,SELF.MAX_SALARY
                         ,SELF.RCN
                        ;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_UPDATE
  IS
  BEGIN

    UPDATE HR.JOBS
    SET JOB_TITLE  = SELF.JOB_TITLE
       ,MIN_SALARY = SELF.MIN_SALARY
       ,MAX_SALARY = SELF.MAX_SALARY
    WHERE JOB_ID = SELF.JOB_ID
      AND RCN    = SELF.RCN
    RETURNING JOB_ID
             ,JOB_TITLE
             ,MIN_SALARY
             ,MAX_SALARY
             ,RCN
         INTO SELF.JOB_ID
             ,SELF.JOB_TITLE
             ,SELF.MIN_SALARY
             ,SELF.MAX_SALARY
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

    MERGE INTO HR.JOBS A
    USING ( SELECT SELF.JOB_ID     AS JOB_ID
                  ,SELF.JOB_TITLE  AS JOB_TITLE
                  ,SELF.MIN_SALARY AS MIN_SALARY
                  ,SELF.MAX_SALARY AS MAX_SALARY
            FROM DUAL ) B
    ON (    A.JOB_ID = B.JOB_ID)
    WHEN MATCHED THEN UPDATE SET   JOB_TITLE  = B.JOB_TITLE
                                  ,MIN_SALARY = B.MIN_SALARY
                                  ,MAX_SALARY = B.MAX_SALARY
    WHEN NOT MATCHED THEN INSERT ( JOB_ID
                                  ,JOB_TITLE
                                  ,MIN_SALARY
                                  ,MAX_SALARY
                        ) VALUES ( B.JOB_ID
                                  ,B.JOB_TITLE
                                  ,B.MIN_SALARY
                                  ,B.MAX_SALARY
                                );

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_SAVE 
  IS
  BEGIN

    IF ROW_EXISTS(IN_JOB_ID => SELF.JOB_ID) THEN
      SELF.ROW_UPDATE;
    ELSE
      SELF.ROW_INSERT;
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_DELETE
  IS
  BEGIN

    DELETE FROM HR.JOBS
    WHERE JOB_ID = SELF.JOB_ID
      AND RCN    = SELF.RCN
		;

    IF SQL%ROWCOUNT <> 1 THEN
      RAISE_APPLICATION_ERROR(-20999,'Optimistic locking : ROW is to old');
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_SELECT(IN_JOB_ID VARCHAR2)
  IS
  BEGIN

    SELECT JOB_ID
          ,JOB_TITLE
          ,MIN_SALARY
          ,MAX_SALARY
          ,RCN
      INTO SELF.JOB_ID
          ,SELF.JOB_TITLE
          ,SELF.MIN_SALARY
          ,SELF.MAX_SALARY
          ,SELF.RCN
    FROM HR.JOBS
    WHERE JOB_ID = IN_JOB_ID;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_DEFAULT
  IS
  BEGIN

    SELF.RCN        := 1;

  END;


  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_LOCK
  IS
    lock_RCN                 NUMBER;
  BEGIN

    SELECT RCN
      INTO lock_RCN
    FROM HR.JOBS
    WHERE JOB_ID = SELF.JOB_ID
    FOR UPDATE
    ;

    IF SELF.RCN <> lock_RCN THEN
      SELF.ROW_SELECT( IN_JOB_ID   => SELF.JOB_ID
                     );
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_LOCK(IN_JOB_ID VARCHAR2)
  IS
  BEGIN

    SELECT JOB_ID
          ,JOB_TITLE
          ,MIN_SALARY
          ,MAX_SALARY
          ,RCN
      INTO SELF.JOB_ID
          ,SELF.JOB_TITLE
          ,SELF.MIN_SALARY
          ,SELF.MAX_SALARY
          ,SELF.RCN
    FROM HR.JOBS
    WHERE JOB_ID = IN_JOB_ID
    FOR UPDATE
    ;

  END;

  ---------------------------------------------------------------

END;
/
