-- Created on 24.08.2007 by TERLETSKYY 
declare 
  -- Local variables here
  e TYPE_EMPLOYEE;
	m TYPE_EMPLOYEE;
begin
  -- Test statements here
	e := NEW TYPE_EMPLOYEE(IN_EMPLOYEE_ID => 101);
	e.DBMS_OUTPUT;

  m:= e.GET_MANAGER();
	m.DBMS_OUTPUT;
	
end;
