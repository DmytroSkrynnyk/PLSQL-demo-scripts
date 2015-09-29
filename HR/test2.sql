-- Created on 24.08.2007 by TERLETSKYY 
declare 
  -- Local variables here
	c TYPE_COUNTRY;
begin
  -- Test statements here
	c := NEW TYPE_COUNTRY();
	c.country_id   := '3Y';
	c.country_name := 'Penguinland';
	c.region_name  := 'Antarctic';
  c.row_save();
	c.dbms_output;
end;
