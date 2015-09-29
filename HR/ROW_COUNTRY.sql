CREATE OR REPLACE TYPE ROW_COUNTRY UNDER TYPE_OBJECT
( -- object oriented ROWTYPE for COUNTRIES table
  -- $Revision: 8696 $
  -- created : 2007-08-24 17:15:37

  -- attributes
    COUNTRY_ID    CHAR(2)
  , COUNTRY_NAME  VARCHAR2(40)
  , REGION_ID     NUMBER
  , RCN           NUMBER

  -- define constructors 
  , CONSTRUCTOR FUNCTION ROW_COUNTRY RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION ROW_COUNTRY(COUNTRY_ID CHAR, COUNTRY_NAME VARCHAR2, REGION_ID NUMBER, RCN NUMBER) RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION ROW_COUNTRY(IN_COUNTRY_ID CHAR) RETURN SELF AS RESULT

  -- define member functions 
  , MEMBER FUNCTION ROW_EXISTS(IN_COUNTRY_ID CHAR) RETURN BOOLEAN
  , OVERRIDING MEMBER FUNCTION compare(in_type1 TYPE_OBJECT,in_type2 TYPE_OBJECT) RETURN INTEGER

  -- define member procedures
  , MEMBER PROCEDURE ROW_INSERT
  , MEMBER PROCEDURE ROW_UPDATE
  , MEMBER PROCEDURE ROW_MERGE
  , MEMBER PROCEDURE ROW_SAVE
  , MEMBER PROCEDURE ROW_DELETE
  , MEMBER PROCEDURE ROW_SELECT(IN_COUNTRY_ID CHAR)
  , MEMBER PROCEDURE ROW_DEFAULT
	, MEMBER PROCEDURE ROW_LOCK
  , MEMBER PROCEDURE ROW_LOCK(IN_COUNTRY_ID CHAR)
) NOT FINAL
/
CREATE OR REPLACE TYPE BODY ROW_COUNTRY IS
-- $Revision: 8696 $

  -- constructors
  CONSTRUCTOR FUNCTION ROW_COUNTRY RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'ROW_COUNTRY';
    SELF.ROW_DEFAULT();
    RETURN;

  END;

  ---------------------------------------------------------------

  CONSTRUCTOR FUNCTION ROW_COUNTRY(COUNTRY_ID CHAR, COUNTRY_NAME VARCHAR2, REGION_ID NUMBER, RCN NUMBER) RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'HR.ROW_COUNTRY';

    SELF.COUNTRY_ID   := COUNTRY_ID;
    SELF.COUNTRY_NAME := COUNTRY_NAME;
    SELF.REGION_ID    := REGION_ID;
    SELF.RCN          := RCN;
    RETURN;

  END;

  ---------------------------------------------------------------

  CONSTRUCTOR FUNCTION ROW_COUNTRY(IN_COUNTRY_ID CHAR) RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'HR.ROW_COUNTRY';
    SELF.ROW_SELECT(IN_COUNTRY_ID => IN_COUNTRY_ID);
    RETURN;

  END;

  ---------------------------------------------------------------

  MEMBER FUNCTION ROW_EXISTS(IN_COUNTRY_ID CHAR) RETURN BOOLEAN
  IS
    v_count  PLS_INTEGER;
  BEGIN

    SELECT COUNT(*)
    INTO v_count
    FROM HR.COUNTRIES
    WHERE COUNTRY_ID = IN_COUNTRY_ID;
    RETURN (v_count <> 0);

  END;

  ---------------------------------------------------------------

  -- member functions
  OVERRIDING MEMBER FUNCTION COMPARE(in_type1 TYPE_OBJECT,in_type2 TYPE_OBJECT) RETURN INTEGER
  IS
    type1         ROW_COUNTRY := TREAT(in_type1 AS ROW_COUNTRY);
    type2         ROW_COUNTRY := TREAT(in_type2 AS ROW_COUNTRY);
  BEGIN

    IF      type1.COUNTRY_ID   = type2.COUNTRY_ID
      AND ( type1.COUNTRY_NAME = type2.COUNTRY_NAME OR (type1.COUNTRY_NAME IS NULL AND type2.COUNTRY_NAME IS NULL) )
      AND ( type1.REGION_ID    = type2.REGION_ID    OR (type1.REGION_ID    IS NULL AND type2.REGION_ID    IS NULL) )
      AND ( type1.RCN          = type2.RCN          OR (type1.RCN          IS NULL AND type2.RCN          IS NULL) )
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

    INSERT INTO HR.COUNTRIES ( COUNTRY_ID
                              ,COUNTRY_NAME
                              ,REGION_ID
                    ) VALUES ( SELF.COUNTRY_ID
                              ,SELF.COUNTRY_NAME
                              ,SELF.REGION_ID
                   ) RETURNING
                               COUNTRY_ID
                              ,COUNTRY_NAME
                              ,REGION_ID
                    INTO
                               SELF.COUNTRY_ID
                              ,SELF.COUNTRY_NAME
                              ,SELF.REGION_ID
                             ;
  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_UPDATE
  IS
  BEGIN

    UPDATE HR.COUNTRIES
    SET COUNTRY_NAME = SELF.COUNTRY_NAME
       ,REGION_ID    = SELF.REGION_ID
    WHERE COUNTRY_ID = SELF.COUNTRY_ID
      AND RCN        = SELF.RCN
    RETURNING COUNTRY_ID
             ,COUNTRY_NAME
             ,REGION_ID
             ,RCN
         INTO SELF.COUNTRY_ID
             ,SELF.COUNTRY_NAME
             ,SELF.REGION_ID
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

    MERGE INTO HR.COUNTRIES A
    USING ( SELECT SELF.COUNTRY_ID   AS COUNTRY_ID
                  ,SELF.COUNTRY_NAME AS COUNTRY_NAME
                  ,SELF.REGION_ID    AS REGION_ID
            FROM DUAL ) B
    ON (    A.COUNTRY_ID = B.COUNTRY_ID)
    WHEN MATCHED THEN UPDATE SET   COUNTRY_NAME = B.COUNTRY_NAME
                                  ,REGION_ID    = B.REGION_ID
    WHEN NOT MATCHED THEN INSERT ( COUNTRY_ID
                                  ,COUNTRY_NAME
                                  ,REGION_ID
                        ) VALUES ( B.COUNTRY_ID
                                  ,B.COUNTRY_NAME
                                  ,B.REGION_ID
                                );

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_SAVE 
  IS
  BEGIN

    IF ROW_EXISTS(IN_COUNTRY_ID => SELF.COUNTRY_ID) THEN
      SELF.ROW_UPDATE;
    ELSE
      SELF.ROW_INSERT;
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_DELETE
  IS
  BEGIN

    DELETE FROM HR.COUNTRIES
    WHERE COUNTRY_ID = SELF.COUNTRY_ID
      AND RCN        = SELF.RCN
		;

    IF SQL%ROWCOUNT <> 1 THEN
      RAISE_APPLICATION_ERROR(-20999,'Optimistic locking : ROW is to old');
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_SELECT(IN_COUNTRY_ID CHAR)
  IS
  BEGIN

    SELECT COUNTRY_ID
          ,COUNTRY_NAME
          ,REGION_ID
          ,RCN
      INTO SELF.COUNTRY_ID
          ,SELF.COUNTRY_NAME
          ,SELF.REGION_ID
          ,SELF.RCN
    FROM HR.COUNTRIES
    WHERE COUNTRY_ID = IN_COUNTRY_ID;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_DEFAULT
  IS
  BEGIN

    SELF.RCN          := 1;

  END;


  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_LOCK
  IS
    lock_RCN                 NUMBER;
  BEGIN

    SELECT RCN
      INTO lock_RCN
    FROM HR.COUNTRIES
    WHERE COUNTRY_ID = SELF.COUNTRY_ID
    FOR UPDATE
    ;

    IF SELF.RCN <> lock_RCN THEN
      SELF.ROW_SELECT( IN_COUNTRY_ID   => SELF.COUNTRY_ID
                     );
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_LOCK(IN_COUNTRY_ID CHAR)
  IS
  BEGIN

    SELECT COUNTRY_ID
          ,COUNTRY_NAME
          ,REGION_ID
          ,RCN
      INTO SELF.COUNTRY_ID
          ,SELF.COUNTRY_NAME
          ,SELF.REGION_ID
          ,SELF.RCN
    FROM HR.COUNTRIES
    WHERE COUNTRY_ID = IN_COUNTRY_ID
    FOR UPDATE
    ;

  END;

  ---------------------------------------------------------------

END;
/
