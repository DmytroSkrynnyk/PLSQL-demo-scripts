-- Cr_Basic_12102_Usr
CLEAR SCREEN
CONNECT Sys/oracle@x/r12102 AS SYSDBA
declare
  User_Doesnt_Exist exception;
  pragma Exception_Init(User_Doesnt_Exist, -01918);
begin
  execute immediate 'drop user Usr cascade';
exception when User_Doesnt_Exist then null;
end;
/
grant
  Create Session,
  Create Procedure
to Usr identified by p
/
CONNECT Usr/p@x/r12102
alter session set Plsql_Warnings = 'Error:All'
/
alter session set Plsql_CCflags = 'Provoke_Compile_Error:false'
/

-- To do: provoke PLS-07205: SIMPLE_INTEGER is mixed with BINARY_INTEGER or PLS_INTEGER

create procedure Semantic_Test authid Definer is
  Numeric_Overflow exception; pragma Exception_Init(Numeric_Overflow, -01426);
  i constant integer not null := 2**31 - 1;
  p pls_integer not null := i;
  s simple_integer := p;
  function f(n in integer) return varchar2 is
  begin
    return To_Char(n, '9999999999999999');
  end f;
begin
  DBMS_Output.Put_Line(Chr(10)||'Semantic_Test');
  DBMS_Output.Put_Line(f(p));

  begin
    p := p + 1;
    raise Program_Error;
  exception when Numeric_Overflow then
    DBMS_Output.Put_Line('pls_integer p overflowed as expected');
  end;
  -- Show that p is unchanged.
  if p <> i then
    raise Program_Error;
  end if;

   s := s + 1;
   DBMS_Output.Put_Line('simple integer s wrapped around as expected: '||f(s));

   -- Show that simple_integer has an implicit not null constraint
   $if $$Provoke_Compile_Error $then
     s := null;
   $end
end Semantic_Test;
/
LIST
SHOW ERRORS
begin Semantic_Test(); end;
/

create procedure Performance_Test authid Definer is
  p_One constant pls_integer not null := 1;
  s_One constant simple_integer not null := p_One;
  p_Lower_Limit constant pls_integer not null := -2**31;
  p_Upper_Limit constant pls_integer not null := 2**31 - 1;
  s_Lower_Limit constant simple_integer not null := p_Lower_Limit;
  s_Upper_Limit constant simple_integer not null := p_Upper_Limit;
  p_Runner pls_integer not null := p_Lower_Limit;
  s_Runner simple_integer not null := s_Lower_Limit;
begin
  DBMS_Output.Put_Line(Chr(10)||'Performance_Test');

  declare
    t0 constant integer not null := DBMS_Utility.Get_CPU_Time();
  begin
    while p_Runner < p_Upper_Limit loop
      p_Runner := p_Runner + p_One;
    end loop;
    DBMS_Output.Put_Line('pls_integer:   '||To_Char((DBMS_Utility.Get_CPU_Time() - t0), '999999'));
  end;
  -- Ensure not optimized to "null"
  if p_Runner <> p_Upper_Limit then
    raise Program_Error;
  end if;

  declare
    t0 constant integer not null := DBMS_Utility.Get_CPU_Time();
  begin
    while s_Runner < s_Upper_Limit loop
      s_Runner := s_Runner + s_One;
    end loop;
    DBMS_Output.Put_Line('simple_integer:'||To_Char((DBMS_Utility.Get_CPU_Time() - t0), '999999'));
  end;
  -- Ensure not optimized to "null"
  if s_Runner <> s_Upper_Limit then
    raise Program_Error;
  end if;
end Performance_Test;
/
LIST
SHOW ERRORS
------------------------------------------------------------
alter session set Plsql_Code_Type = 'interpreted'
/
alter procedure Performance_Test compile reuse settings
/
begin Performance_Test(); end;
/
-- Performance_Test
-- pls_integer:      4554
-- simple_integer:   4599


alter session set Plsql_Code_Type = 'native'
/
alter procedure Performance_Test compile reuse settings
/
begin Performance_Test(); end;
/
-- Performance_Test
-- pls_integer:      4572
-- simple_integer:   4639
