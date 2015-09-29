CREATE OR REPLACE TYPE ROW_DEPARTMENT UNDER TYPE_OBJECT
( -- object oriented ROWTYPE for DEPARTMENTS table
  -- $Revision: 8696 $
  -- created : 2007-08-24 15:04:02

  -- attributes
    DEPARTMENT_ID    NUMBER(4)
  , DEPARTMENT_NAME  VARCHAR2(30)
  , MANAGER_ID       NUMBER(6)
  , LOCATION_ID      NUMBER(4)
  , RCN              NUMBER

  -- define constructors 
  , CONSTRUCTOR FUNCTION ROW_DEPARTMENT RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION ROW_DEPARTMENT(DEPARTMENT_ID NUMBER, DEPARTMENT_NAME VARCHAR2, MANAGER_ID NUMBER, LOCATION_ID NUMBER, RCN NUMBER) RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION ROW_DEPARTMENT(IN_DEPARTMENT_ID NUMBER) RETURN SELF AS RESULT

  -- define member functions 
  , MEMBER FUNCTION ROW_EXISTS(IN_DEPARTMENT_ID NUMBER) RETURN BOOLEAN
  , OVERRIDING MEMBER FUNCTION compare(in_type1 TYPE_OBJECT,in_type2 TYPE_OBJECT) RETURN INTEGER

  -- define member procedures
  , MEMBER PROCEDURE ROW_INSERT
  , MEMBER PROCEDURE ROW_UPDATE
  , MEMBER PROCEDURE ROW_MERGE
  , MEMBER PROCEDURE ROW_SAVE
  , MEMBER PROCEDURE ROW_DELETE
  , MEMBER PROCEDURE ROW_SELECT(IN_DEPARTMENT_ID NUMBER)
  , MEMBER PROCEDURE ROW_DEFAULT
  , MEMBER PROCEDURE ROW_LOCK
  , MEMBER PROCEDURE ROW_LOCK(IN_DEPARTMENT_ID NUMBER)
) NOT FINAL
/
CREATE OR REPLACE TYPE BODY ROW_DEPARTMENT IS
-- $Revision: 8696 $

  -- constructors
  CONSTRUCTOR FUNCTION ROW_DEPARTMENT RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'ROW_DEPARTMENT';
    SELF.ROW_DEFAULT();
    RETURN;

  END;

  ---------------------------------------------------------------

  CONSTRUCTOR FUNCTION ROW_DEPARTMENT(DEPARTMENT_ID NUMBER, DEPARTMENT_NAME VARCHAR2, MANAGER_ID NUMBER, LOCATION_ID NUMBER, RCN NUMBER) RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'HR.ROW_DEPARTMENT';

    SELF.DEPARTMENT_ID   := DEPARTMENT_ID;
    SELF.DEPARTMENT_NAME := DEPARTMENT_NAME;
    SELF.MANAGER_ID      := MANAGER_ID;
    SELF.LOCATION_ID     := LOCATION_ID;
    SELF.RCN             := RCN;
    RETURN;

  END;

  ---------------------------------------------------------------

  CONSTRUCTOR FUNCTION ROW_DEPARTMENT(IN_DEPARTMENT_ID NUMBER) RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'HR.ROW_DEPARTMENT';
    SELF.ROW_SELECT(IN_DEPARTMENT_ID => IN_DEPARTMENT_ID);
    RETURN;

  END;

  ---------------------------------------------------------------

  MEMBER FUNCTION ROW_EXISTS(IN_DEPARTMENT_ID NUMBER) RETURN BOOLEAN
  IS
    v_count  PLS_INTEGER;
  BEGIN

    SELECT COUNT(*)
    INTO v_count
    FROM HR.DEPARTMENTS
    WHERE DEPARTMENT_ID = IN_DEPARTMENT_ID;
    RETURN (v_count <> 0);

  END;

  ---------------------------------------------------------------

  -- member functions
  OVERRIDING MEMBER FUNCTION COMPARE(in_type1 TYPE_OBJECT,in_type2 TYPE_OBJECT) RETURN INTEGER
  IS
    type1         ROW_DEPARTMENT := TREAT(in_type1 AS ROW_DEPARTMENT);
    type2         ROW_DEPARTMENT := TREAT(in_type2 AS ROW_DEPARTMENT);
  BEGIN

    IF      type1.DEPARTMENT_ID   = type2.DEPARTMENT_ID
      AND   type1.DEPARTMENT_NAME = type2.DEPARTMENT_NAME
      AND ( type1.MANAGER_ID      = type2.MANAGER_ID      OR (type1.MANAGER_ID      IS NULL AND type2.MANAGER_ID      IS NULL) )
      AND ( type1.LOCATION_ID     = type2.LOCATION_ID     OR (type1.LOCATION_ID     IS NULL AND type2.LOCATION_ID     IS NULL) )
      AND ( type1.RCN             = type2.RCN             OR (type1.RCN             IS NULL AND type2.RCN             IS NULL) )
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

    INSERT INTO HR.DEPARTMENTS ( DEPARTMENT_ID
                                ,DEPARTMENT_NAME
                                ,MANAGER_ID
                                ,LOCATION_ID
                      ) VALUES ( SELF.DEPARTMENT_ID
                                ,SELF.DEPARTMENT_NAME
                                ,SELF.MANAGER_ID
                                ,SELF.LOCATION_ID
                     ) RETURNING
                                 DEPARTMENT_ID
                                ,DEPARTMENT_NAME
                                ,MANAGER_ID
                                ,LOCATION_ID
                                ,RCN
                      INTO
                                 SELF.DEPARTMENT_ID
                                ,SELF.DEPARTMENT_NAME
                                ,SELF.MANAGER_ID
                                ,SELF.LOCATION_ID
                                ,SELF.RCN
                               ;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_UPDATE
  IS
  BEGIN

    UPDATE HR.DEPARTMENTS
    SET DEPARTMENT_NAME = SELF.DEPARTMENT_NAME
       ,MANAGER_ID      = SELF.MANAGER_ID
       ,LOCATION_ID     = SELF.LOCATION_ID
    WHERE DEPARTMENT_ID = SELF.DEPARTMENT_ID
		  AND RCN           = SELF.RCN
    RETURNING DEPARTMENT_ID
             ,DEPARTMENT_NAME
             ,MANAGER_ID
             ,LOCATION_ID
             ,RCN
         INTO SELF.DEPARTMENT_ID
             ,SELF.DEPARTMENT_NAME
             ,SELF.MANAGER_ID
             ,SELF.LOCATION_ID
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

    MERGE INTO HR.DEPARTMENTS A
    USING ( SELECT SELF.DEPARTMENT_ID   AS DEPARTMENT_ID
                  ,SELF.DEPARTMENT_NAME AS DEPARTMENT_NAME
                  ,SELF.MANAGER_ID      AS MANAGER_ID
                  ,SELF.LOCATION_ID     AS LOCATION_ID
            FROM DUAL ) B
    ON (    A.DEPARTMENT_ID = B.DEPARTMENT_ID)
    WHEN MATCHED THEN UPDATE SET   DEPARTMENT_NAME = B.DEPARTMENT_NAME
                                  ,MANAGER_ID      = B.MANAGER_ID
                                  ,LOCATION_ID     = B.LOCATION_ID
    WHEN NOT MATCHED THEN INSERT ( DEPARTMENT_ID
                                  ,DEPARTMENT_NAME
                                  ,MANAGER_ID
                                  ,LOCATION_ID
                        ) VALUES ( B.DEPARTMENT_ID
                                  ,B.DEPARTMENT_NAME
                                  ,B.MANAGER_ID
                                  ,B.LOCATION_ID
                                );

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_SAVE 
  IS
  BEGIN

    IF ROW_EXISTS(IN_DEPARTMENT_ID => SELF.DEPARTMENT_ID) THEN
      SELF.ROW_UPDATE;
    ELSE
      SELF.ROW_INSERT;
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_DELETE
  IS
  BEGIN

    DELETE FROM HR.DEPARTMENTS
    WHERE DEPARTMENT_ID = SELF.DEPARTMENT_ID
		  AND RCN           = SELF.RCN
		;

    IF SQL%ROWCOUNT <> 1 THEN
      RAISE_APPLICATION_ERROR(-20999,'Optimistic locking : ROW is to old');
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_SELECT(IN_DEPARTMENT_ID NUMBER)
  IS
  BEGIN


    SELECT DEPARTMENT_ID
          ,DEPARTMENT_NAME
          ,MANAGER_ID
          ,LOCATION_ID
          ,RCN
      INTO SELF.DEPARTMENT_ID
          ,SELF.DEPARTMENT_NAME
          ,SELF.MANAGER_ID
          ,SELF.LOCATION_ID
          ,SELF.RCN
    FROM HR.DEPARTMENTS
    WHERE DEPARTMENT_ID = IN_DEPARTMENT_ID;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_DEFAULT
  IS
  BEGIN

    SELF.RCN             := 1;

  END;


  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_LOCK
  IS
    lock_RCN                 NUMBER;
  BEGIN

    SELECT RCN
      INTO lock_RCN
    FROM HR.DEPARTMENTS
    WHERE DEPARTMENT_ID = SELF.DEPARTMENT_ID
    FOR UPDATE
    ;

    IF SELF.RCN <> lock_RCN THEN
      SELF.ROW_SELECT( IN_DEPARTMENT_ID   => SELF.DEPARTMENT_ID
                     );
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_LOCK(IN_DEPARTMENT_ID NUMBER)
  IS
  BEGIN

    SELECT DEPARTMENT_ID
          ,DEPARTMENT_NAME
          ,MANAGER_ID
          ,LOCATION_ID
          ,RCN
      INTO SELF.DEPARTMENT_ID
          ,SELF.DEPARTMENT_NAME
          ,SELF.MANAGER_ID
          ,SELF.LOCATION_ID
          ,SELF.RCN
    FROM HR.DEPARTMENTS
    WHERE DEPARTMENT_ID = IN_DEPARTMENT_ID
    FOR UPDATE
    ;

  END;

  ---------------------------------------------------------------

END;
/
