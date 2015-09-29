WITH
FUNCTION full_name (fname_in in varchar2, lname_in in varchar2)
   RETURN VARCHAR2
IS
BEGIN   
   RETURN fname_in || ' '|| lname_in;
END;
SELECT full_name (first_name, last_name) FROM employees;