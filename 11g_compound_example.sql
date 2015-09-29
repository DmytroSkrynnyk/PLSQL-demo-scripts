/* How many rows modified? */

create or replace trigger trig_1
  for insert or update or delete on emp_test
  compound trigger

  n pls_integer not null := 0;

  after each row is
  begin
      n := n + 1;
  end after each row;

  after statement is
  begin
    DBMS_Output.Put_Line('rows affected: '||n);
  end after statement;
end;
/
insert into emp_test select * from emp where empno = 7369
/
delete from emp_test where ename = 'SMITH'
/
update emp_test set sal = sal*1.1
/