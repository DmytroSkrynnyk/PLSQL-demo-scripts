CREATE OR REPLACE PACKAGE hash
IS
    FUNCTION val (str IN VARCHAR2) RETURN NUMBER;

END hash;
/
