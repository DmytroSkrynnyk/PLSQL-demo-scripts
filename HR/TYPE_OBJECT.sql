CREATE OR REPLACE TYPE TYPE_OBJECT AUTHID CURRENT_USER AS OBJECT
(
  /* ------------------------------------------------------------------------
  Name        : TABLE_OBJECT
  Version     : $Revision: 4009 $
  Aufgabe     : Basis Type für alle DB-Objekte.
  Datum       : 20.05.2003
  Autor       : Andriy Terletskyy
  QS          :
  QS-Datum    :
  ---------------------------------------------------------------------------
  */
  
  -- Attributes
  object_type_name VARCHAR2(100) 
  
  -- Member functions and procedures
 ,MEMBER PROCEDURE DBMS_OUTPUT(SELF IN TYPE_OBJECT)
 ,MEMBER FUNCTION  TO_STRING                                           RETURN VARCHAR2
 ,MEMBER FUNCTION  TO_CLOB                                             RETURN CLOB
 ,MEMBER FUNCTION  compare(in_type1 TYPE_OBJECT, in_type2 TYPE_OBJECT) RETURN INTEGER
 ,ORDER  MEMBER FUNCTION compare2(in_other TYPE_OBJECT)                RETURN INTEGER
) NOT FINAL NOT INSTANTIABLE
/
CREATE OR REPLACE TYPE BODY TYPE_OBJECT
IS
 -- $Revision: 4009 $

------------------------------------------
  MEMBER PROCEDURE DBMS_OUTPUT(SELF IN TYPE_OBJECT)
  IS
  BEGIN
    SYS.DBMS_OUTPUT.PUT_LINE(SELF.TO_STRING());
  END;
------------------------------------------
  -- Gibt object Attributen aus. Ohne Collection (AnyType Engpass)
  MEMBER FUNCTION TO_STRING RETURN VARCHAR2 
  IS
  BEGIN
    RETURN dbms_lob.substr(SELF.TO_CLOB(), 32760);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'ERROR : '|| SQLERRM;
  END;
------------------------------------------
  -- Gibt volständige Object aus.
  -- Erzeugt Dynamische PL/SQL-Skript, um Namedcollection auszugeben
  MEMBER FUNCTION TO_CLOB RETURN CLOB 
  IS
  BEGIN
     RETURN xmltype(SELF).extract('/').getCLOBVal() ;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN 'ERROR : '|| SQLERRM;
  END;
  
------------------------------------------

  MEMBER FUNCTION  compare(in_type1 TYPE_OBJECT, in_type2 TYPE_OBJECT) RETURN INTEGER
  IS
  BEGIN
    RETURN 1; -- default immer ungleich
  END;

------------------------------------------

  ORDER MEMBER FUNCTION compare2(in_other TYPE_OBJECT)    RETURN INTEGER
  IS
  BEGIN
    RETURN compare(SELF,in_other);
  END;
  
END;
/
