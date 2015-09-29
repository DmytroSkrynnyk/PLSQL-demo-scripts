CREATE OR REPLACE TYPE ROW_REGION UNDER TYPE_OBJECT
( -- object oriented ROWTYPE for REGIONS table
  -- $Revision: 8696 $
  -- created : 2007-08-24 15:04:04

  -- attributes
    REGION_ID    NUMBER
  , REGION_NAME  VARCHAR2(25)
  , RCN          NUMBER

  -- define constructors 
  , CONSTRUCTOR FUNCTION ROW_REGION RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION ROW_REGION(REGION_ID NUMBER, REGION_NAME VARCHAR2, RCN NUMBER) RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION ROW_REGION(IN_REGION_ID NUMBER) RETURN SELF AS RESULT

  -- define member functions 
  , MEMBER FUNCTION ROW_EXISTS(IN_REGION_ID NUMBER) RETURN BOOLEAN
  , OVERRIDING MEMBER FUNCTION compare(in_type1 TYPE_OBJECT,in_type2 TYPE_OBJECT) RETURN INTEGER

  -- define member procedures
  , MEMBER PROCEDURE ROW_INSERT
  , MEMBER PROCEDURE ROW_UPDATE
  , MEMBER PROCEDURE ROW_MERGE
  , MEMBER PROCEDURE ROW_SAVE
  , MEMBER PROCEDURE ROW_DELETE
  , MEMBER PROCEDURE ROW_SELECT(IN_REGION_ID NUMBER)
  , MEMBER PROCEDURE ROW_DEFAULT
  , MEMBER PROCEDURE ROW_LOCK
  , MEMBER PROCEDURE ROW_LOCK(IN_REGION_ID NUMBER)
) NOT FINAL
/
CREATE OR REPLACE TYPE BODY ROW_REGION IS
-- $Revision: 8696 $

  -- constructors
  CONSTRUCTOR FUNCTION ROW_REGION RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'ROW_REGION';
    SELF.ROW_DEFAULT();

    RETURN;

  END;

  ---------------------------------------------------------------

  CONSTRUCTOR FUNCTION ROW_REGION(REGION_ID NUMBER, REGION_NAME VARCHAR2, RCN NUMBER) RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'HR.ROW_REGION';

    SELF.REGION_ID   := REGION_ID;
    SELF.REGION_NAME := REGION_NAME;
    SELF.RCN         := RCN;

    RETURN;

  END;

  ---------------------------------------------------------------

  CONSTRUCTOR FUNCTION ROW_REGION(IN_REGION_ID NUMBER) RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'HR.ROW_REGION';
    SELF.ROW_SELECT(IN_REGION_ID => IN_REGION_ID);

    RETURN;

  END;

  ---------------------------------------------------------------

  MEMBER FUNCTION ROW_EXISTS(IN_REGION_ID NUMBER) RETURN BOOLEAN
  IS
    v_count  PLS_INTEGER;
  BEGIN

    SELECT COUNT(*)
    INTO v_count
    FROM HR.REGIONS
    WHERE REGION_ID = IN_REGION_ID;

    RETURN (v_count <> 0);

  END;

  ---------------------------------------------------------------

  -- member functions
  OVERRIDING MEMBER FUNCTION COMPARE(in_type1 TYPE_OBJECT,in_type2 TYPE_OBJECT) RETURN INTEGER
  IS
    type1         ROW_REGION := TREAT(in_type1 AS ROW_REGION);
    type2         ROW_REGION := TREAT(in_type2 AS ROW_REGION);
  BEGIN

    IF      type1.REGION_ID   = type2.REGION_ID
      AND ( type1.REGION_NAME = type2.REGION_NAME OR (type1.REGION_NAME IS NULL AND type2.REGION_NAME IS NULL) )
      AND ( type1.RCN         = type2.RCN         OR (type1.RCN         IS NULL AND type2.RCN         IS NULL) )
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

    INSERT INTO HR.REGIONS ( REGION_ID
                            ,REGION_NAME
                  ) VALUES ( SELF.REGION_ID
                            ,SELF.REGION_NAME
                 ) RETURNING
                             REGION_ID
                            ,REGION_NAME
                            ,RCN
                  INTO
                             SELF.REGION_ID
                            ,SELF.REGION_NAME
                            ,SELF.RCN
                           ;
  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_UPDATE
  IS
  BEGIN

    UPDATE HR.REGIONS
    SET REGION_NAME = SELF.REGION_NAME
    WHERE REGION_ID = SELF.REGION_ID
		  AND RCN       = SELF.RCN
    RETURNING REGION_ID
             ,REGION_NAME
             ,RCN
         INTO SELF.REGION_ID
             ,SELF.REGION_NAME
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

    MERGE INTO HR.REGIONS A
    USING ( SELECT SELF.REGION_ID   AS REGION_ID
                  ,SELF.REGION_NAME AS REGION_NAME
            FROM DUAL ) B
    ON (    A.REGION_ID = B.REGION_ID)
    WHEN MATCHED THEN UPDATE SET   REGION_NAME = B.REGION_NAME
    WHEN NOT MATCHED THEN INSERT ( REGION_ID
                                  ,REGION_NAME
                        ) VALUES ( B.REGION_ID
                                  ,B.REGION_NAME
                                );

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_SAVE 
  IS
  BEGIN

    IF ROW_EXISTS(IN_REGION_ID => SELF.REGION_ID) THEN
      SELF.ROW_UPDATE;
    ELSE
      SELF.ROW_INSERT;
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_DELETE
  IS
  BEGIN

    DELETE FROM HR.REGIONS
    WHERE REGION_ID = SELF.REGION_ID
		  AND RCN       = SELF.RCN
		;

    IF SQL%ROWCOUNT <> 1 THEN
      RAISE_APPLICATION_ERROR(-20999,'Optimistic locking : ROW is to old');
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_SELECT(IN_REGION_ID NUMBER)
  IS
  BEGIN

    SELECT REGION_ID
          ,REGION_NAME
          ,RCN
      INTO SELF.REGION_ID
          ,SELF.REGION_NAME
          ,SELF.RCN
    FROM HR.REGIONS
    WHERE REGION_ID = IN_REGION_ID;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_DEFAULT
  IS
  BEGIN

    SELF.RCN         := 1;
		
  END;


  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_LOCK
  IS
    lock_RCN                 NUMBER;
  BEGIN

    SELECT RCN
      INTO lock_RCN
    FROM HR.REGIONS
    WHERE REGION_ID = SELF.REGION_ID
    FOR UPDATE
    ;

    IF SELF.RCN <> lock_RCN THEN
      SELF.ROW_SELECT( IN_REGION_ID   => SELF.REGION_ID
                     );
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_LOCK(IN_REGION_ID NUMBER)
  IS
  BEGIN

    SELECT REGION_ID
          ,REGION_NAME
          ,RCN
      INTO SELF.REGION_ID
          ,SELF.REGION_NAME
          ,SELF.RCN
    FROM HR.REGIONS
    WHERE REGION_ID = IN_REGION_ID
    FOR UPDATE
    ;

  END;

  ---------------------------------------------------------------

END;
/
