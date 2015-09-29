CREATE OR REPLACE TYPE ROW_LOCATION UNDER TYPE_OBJECT
( -- object oriented ROWTYPE for LOCATIONS table
  -- $Revision: 8696 $
  -- created : 2007-08-24 15:04:04

  -- attributes
    LOCATION_ID     NUMBER(4)
  , STREET_ADDRESS  VARCHAR2(40)
  , POSTAL_CODE     VARCHAR2(12)
  , CITY            VARCHAR2(30)
  , STATE_PROVINCE  VARCHAR2(25)
  , COUNTRY_ID      CHAR(2)
  , RCN             NUMBER

  -- define constructors 
  , CONSTRUCTOR FUNCTION ROW_LOCATION RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION ROW_LOCATION(LOCATION_ID NUMBER, STREET_ADDRESS VARCHAR2, POSTAL_CODE VARCHAR2, CITY VARCHAR2, STATE_PROVINCE VARCHAR2, COUNTRY_ID CHAR, RCN NUMBER) RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION ROW_LOCATION(IN_LOCATION_ID NUMBER) RETURN SELF AS RESULT

  -- define member functions 
  , MEMBER FUNCTION ROW_EXISTS(IN_LOCATION_ID NUMBER) RETURN BOOLEAN
  , OVERRIDING MEMBER FUNCTION compare(in_type1 TYPE_OBJECT,in_type2 TYPE_OBJECT) RETURN INTEGER

  -- define member procedures
  , MEMBER PROCEDURE ROW_INSERT
  , MEMBER PROCEDURE ROW_UPDATE
  , MEMBER PROCEDURE ROW_MERGE
  , MEMBER PROCEDURE ROW_SAVE
  , MEMBER PROCEDURE ROW_DELETE
  , MEMBER PROCEDURE ROW_SELECT(IN_LOCATION_ID NUMBER)
  , MEMBER PROCEDURE ROW_DEFAULT
  , MEMBER PROCEDURE ROW_LOCK
  , MEMBER PROCEDURE ROW_LOCK(IN_LOCATION_ID NUMBER)
) NOT FINAL
/
CREATE OR REPLACE TYPE BODY ROW_LOCATION IS
-- $Revision: 8696 $

  -- constructors
  CONSTRUCTOR FUNCTION ROW_LOCATION RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'ROW_LOCATION';
    SELF.ROW_DEFAULT();
    RETURN;

  END;

  ---------------------------------------------------------------

  CONSTRUCTOR FUNCTION ROW_LOCATION(LOCATION_ID NUMBER, STREET_ADDRESS VARCHAR2, POSTAL_CODE VARCHAR2, CITY VARCHAR2, STATE_PROVINCE VARCHAR2, COUNTRY_ID CHAR, RCN NUMBER) RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'HR.ROW_LOCATION';

    SELF.LOCATION_ID    := LOCATION_ID;
    SELF.STREET_ADDRESS := STREET_ADDRESS;
    SELF.POSTAL_CODE    := POSTAL_CODE;
    SELF.CITY           := CITY;
    SELF.STATE_PROVINCE := STATE_PROVINCE;
    SELF.COUNTRY_ID     := COUNTRY_ID;
    SELF.RCN            := RCN;
    RETURN;

  END;

  ---------------------------------------------------------------

  CONSTRUCTOR FUNCTION ROW_LOCATION(IN_LOCATION_ID NUMBER) RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'HR.ROW_LOCATION';
    SELF.ROW_SELECT(IN_LOCATION_ID => IN_LOCATION_ID);
    RETURN;

  END;

  ---------------------------------------------------------------

  MEMBER FUNCTION ROW_EXISTS(IN_LOCATION_ID NUMBER) RETURN BOOLEAN
  IS
    v_count  PLS_INTEGER;
  BEGIN

    SELECT COUNT(*)
    INTO v_count
    FROM HR.LOCATIONS
    WHERE LOCATION_ID = IN_LOCATION_ID;
    RETURN (v_count <> 0);

  END;

  ---------------------------------------------------------------

  -- member functions
  OVERRIDING MEMBER FUNCTION COMPARE(in_type1 TYPE_OBJECT,in_type2 TYPE_OBJECT) RETURN INTEGER
  IS
    type1         ROW_LOCATION := TREAT(in_type1 AS ROW_LOCATION);
    type2         ROW_LOCATION := TREAT(in_type2 AS ROW_LOCATION);
  BEGIN

    IF      type1.LOCATION_ID    = type2.LOCATION_ID
      AND ( type1.STREET_ADDRESS = type2.STREET_ADDRESS OR (type1.STREET_ADDRESS IS NULL AND type2.STREET_ADDRESS IS NULL) )
      AND ( type1.POSTAL_CODE    = type2.POSTAL_CODE    OR (type1.POSTAL_CODE    IS NULL AND type2.POSTAL_CODE    IS NULL) )
      AND   type1.CITY           = type2.CITY
      AND ( type1.STATE_PROVINCE = type2.STATE_PROVINCE OR (type1.STATE_PROVINCE IS NULL AND type2.STATE_PROVINCE IS NULL) )
      AND ( type1.COUNTRY_ID     = type2.COUNTRY_ID     OR (type1.COUNTRY_ID     IS NULL AND type2.COUNTRY_ID     IS NULL) )
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

    INSERT INTO HR.LOCATIONS ( LOCATION_ID
                              ,STREET_ADDRESS
                              ,POSTAL_CODE
                              ,CITY
                              ,STATE_PROVINCE
                              ,COUNTRY_ID
                    ) VALUES ( SELF.LOCATION_ID
                              ,SELF.STREET_ADDRESS
                              ,SELF.POSTAL_CODE
                              ,SELF.CITY
                              ,SELF.STATE_PROVINCE
                              ,SELF.COUNTRY_ID
                   ) RETURNING
                               LOCATION_ID
                              ,STREET_ADDRESS
                              ,POSTAL_CODE
                              ,CITY
                              ,STATE_PROVINCE
                              ,COUNTRY_ID
                              ,RCN
                    INTO
                               SELF.LOCATION_ID
                              ,SELF.STREET_ADDRESS
                              ,SELF.POSTAL_CODE
                              ,SELF.CITY
                              ,SELF.STATE_PROVINCE
                              ,SELF.COUNTRY_ID
                              ,SELF.RCN
                             ;
  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_UPDATE
  IS
  BEGIN

    UPDATE HR.LOCATIONS
    SET STREET_ADDRESS = SELF.STREET_ADDRESS
       ,POSTAL_CODE    = SELF.POSTAL_CODE
       ,CITY           = SELF.CITY
       ,STATE_PROVINCE = SELF.STATE_PROVINCE
       ,COUNTRY_ID     = SELF.COUNTRY_ID
    WHERE LOCATION_ID = SELF.LOCATION_ID
      AND RCN         = SELF.RCN
    RETURNING LOCATION_ID
             ,STREET_ADDRESS
             ,POSTAL_CODE
             ,CITY
             ,STATE_PROVINCE
             ,COUNTRY_ID
         INTO SELF.LOCATION_ID
             ,SELF.STREET_ADDRESS
             ,SELF.POSTAL_CODE
             ,SELF.CITY
             ,SELF.STATE_PROVINCE
             ,SELF.COUNTRY_ID
    ;

    IF SQL%ROWCOUNT <> 1 THEN
      RAISE_APPLICATION_ERROR(-20999,'Optimistic locking : ROW is to old');
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_MERGE 
  IS
  BEGIN

    MERGE INTO HR.LOCATIONS A
    USING ( SELECT SELF.LOCATION_ID    AS LOCATION_ID
                  ,SELF.STREET_ADDRESS AS STREET_ADDRESS
                  ,SELF.POSTAL_CODE    AS POSTAL_CODE
                  ,SELF.CITY           AS CITY
                  ,SELF.STATE_PROVINCE AS STATE_PROVINCE
                  ,SELF.COUNTRY_ID     AS COUNTRY_ID
            FROM DUAL ) B
    ON (    A.LOCATION_ID = B.LOCATION_ID)
    WHEN MATCHED THEN UPDATE SET   STREET_ADDRESS = B.STREET_ADDRESS
                                  ,POSTAL_CODE    = B.POSTAL_CODE
                                  ,CITY           = B.CITY
                                  ,STATE_PROVINCE = B.STATE_PROVINCE
                                  ,COUNTRY_ID     = B.COUNTRY_ID
    WHEN NOT MATCHED THEN INSERT ( LOCATION_ID
                                  ,STREET_ADDRESS
                                  ,POSTAL_CODE
                                  ,CITY
                                  ,STATE_PROVINCE
                                  ,COUNTRY_ID
                        ) VALUES ( B.LOCATION_ID
                                  ,B.STREET_ADDRESS
                                  ,B.POSTAL_CODE
                                  ,B.CITY
                                  ,B.STATE_PROVINCE
                                  ,B.COUNTRY_ID
                                );

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_SAVE 
  IS
  BEGIN

    IF ROW_EXISTS(IN_LOCATION_ID => SELF.LOCATION_ID) THEN
      SELF.ROW_UPDATE;
    ELSE
      SELF.ROW_INSERT;
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_DELETE
  IS
  BEGIN

    DELETE FROM HR.LOCATIONS
    WHERE LOCATION_ID = SELF.LOCATION_ID
      AND RCN         = SELF.RCN
		;

    IF SQL%ROWCOUNT <> 1 THEN
      RAISE_APPLICATION_ERROR(-20999,'Optimistic locking : ROW is to old');
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_SELECT(IN_LOCATION_ID NUMBER)
  IS
  BEGIN

    SELECT LOCATION_ID
          ,STREET_ADDRESS
          ,POSTAL_CODE
          ,CITY
          ,STATE_PROVINCE
          ,COUNTRY_ID
          ,RCN
      INTO SELF.LOCATION_ID
          ,SELF.STREET_ADDRESS
          ,SELF.POSTAL_CODE
          ,SELF.CITY
          ,SELF.STATE_PROVINCE
          ,SELF.COUNTRY_ID
          ,SELF.RCN
    FROM HR.LOCATIONS
    WHERE LOCATION_ID = IN_LOCATION_ID;

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
    FROM HR.LOCATIONS
    WHERE LOCATION_ID = SELF.LOCATION_ID
    FOR UPDATE
    ;

    IF SELF.RCN <> lock_RCN THEN
      SELF.ROW_SELECT( IN_LOCATION_ID   => SELF.LOCATION_ID
                     );
    END IF;

  END;

  ---------------------------------------------------------------

  MEMBER PROCEDURE ROW_LOCK(IN_LOCATION_ID NUMBER)
  IS
  BEGIN

    SELECT LOCATION_ID
          ,STREET_ADDRESS
          ,POSTAL_CODE
          ,CITY
          ,STATE_PROVINCE
          ,COUNTRY_ID
          ,RCN
      INTO SELF.LOCATION_ID
          ,SELF.STREET_ADDRESS
          ,SELF.POSTAL_CODE
          ,SELF.CITY
          ,SELF.STATE_PROVINCE
          ,SELF.COUNTRY_ID
          ,SELF.RCN
    FROM HR.LOCATIONS
    WHERE LOCATION_ID = IN_LOCATION_ID
    FOR UPDATE
    ;

  END;

  ---------------------------------------------------------------

END;
/
