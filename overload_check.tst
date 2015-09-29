create or replace package ambigs
is
   procedure a (n number, d date default sysdate);
   procedure a (n number);
   procedure a (n integer);
end;
/

BEGIN
   codecheck.overloadings ('AMBIGS');
END;
/

create or replace package no_ambigs
is
   procedure a (n number, d date);
   procedure a (n number);
end;
/

BEGIN
   codecheck.overloadings ('NO_AMBIGS');
END;
/

