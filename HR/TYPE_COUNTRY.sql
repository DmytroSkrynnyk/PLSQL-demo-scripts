CREATE OR REPLACE TYPE TYPE_COUNTRY UNDER ROW_COUNTRY
( -- object oriented ROWTYPE for COUNTRYS table
  -- $Revision: 8696 $
  -- created : 2007-08-24 15:04:03

  -- attributes
    REGION_NAME       VARCHAR2(25)

  -- define constructors 
  , CONSTRUCTOR FUNCTION TYPE_COUNTRY RETURN SELF AS RESULT
  , CONSTRUCTOR FUNCTION TYPE_COUNTRY(IN_COUNTRY_ID CHAR) RETURN SELF AS RESULT

  -- define member functions 
	, OVERRIDING MEMBER PROCEDURE ROW_SAVE
) NOT FINAL
/
CREATE OR REPLACE TYPE BODY TYPE_COUNTRY IS
-- $Revision: 8696 $

  -- constructors
  CONSTRUCTOR FUNCTION TYPE_COUNTRY RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'TYPE_COUNTRY';
    SELF.ROW_DEFAULT();
    RETURN;

  END;

  ---------------------------------------------------------------

  CONSTRUCTOR FUNCTION TYPE_COUNTRY(IN_COUNTRY_ID CHAR) RETURN SELF AS RESULT
  IS
  BEGIN

    SELF.OBJECT_TYPE_NAME  := 'HR.TYPE_COUNTRY';
    SELF.ROW_SELECT(IN_COUNTRY_ID => IN_COUNTRY_ID);

		SELF.REGION_NAME        := ROW_REGION(IN_REGION_ID => SELF.REGION_ID).REGION_NAME;

    RETURN;

  END;

  ---------------------------------------------------------------

  OVERRIDING MEMBER PROCEDURE ROW_SAVE
  IS
	  r_region TYPE_REGION;
  BEGIN

    
    IF SELF.REGION_ID  IS NULL AND SELF.REGION_NAME IS NOT NULL THEN
		  -- new region instance
			r_region := NEW TYPE_REGION();
			-- set region name
			r_region.REGION_NAME := SELF.REGION_NAME;
			-- save region row
			r_region.ROW_SAVE;
			-- set a new region ID
			SELF.REGION_ID := r_region.REGION_ID;
		END IF;
	
	  -- save country row 
		IF SELF.ROW_EXISTS(IN_COUNTRY_ID => SELF.COUNTRY_ID) THEN
			SELF.ROW_UPDATE;
		ELSE
			SELF.ROW_INSERT;
		END IF;

  END;

END;
/
