DECLARE 
  PROGRAM_IN VARCHAR2(200);
  SUBPROGRAM_IN VARCHAR2(200);
  SHOW_IN BOOLEAN;

BEGIN 
  PROGRAM_IN := 'desctest.noparms3';
  SHOW_IN := true;

  SCOTT.codecheck.SELFTEST ( PROGRAM_IN, show_in => SHOW_IN );
  --SCOTT.codecheck.load_arguments ( PROGRAM_IN, show_in => SHOW_IN );
  -- SCOTT.codecheck.showargs ( PROGRAM_IN );
  COMMIT; 
END; 

