clear screen
set serveroutput on size unlimited
set arraysize 1
drop type now_and_then_tt;
drop type now_tt;
drop type now_and_then_t;
drop type now_t;

CREATE OR REPLACE TYPE now_t AS OBJECT
(
  now VARCHAR2(8)
)
/
CREATE or replace TYPE now_tt AS
TABLE OF now_t;
/
CREATE OR REPLACE FUNCTION now RETURN now_tt AS
  l_returnvalue now_tt := now_tt();
  l_now         VARCHAR2(8);
BEGIN
  FOR counter IN 1 .. 4 LOOP
    l_now := to_char(SYSDATE, 'HH24:MI:SS');
    dbms_lock.sleep(1);
    l_returnvalue.extend;
    l_returnvalue(l_returnvalue.last) := now_t(l_now);
  END LOOP;
  RETURN l_returnvalue;
END;
/
sho err

SELECT *
  FROM TABLE(now)
/
pause Press any key to continue...

CREATE TYPE now_and_then_t AS OBJECT
(
  now      VARCHAR2(8),
  and_then VARCHAR2(8)
)
/
CREATE TYPE now_and_then_tt AS
TABLE OF now_and_then_t;
/
CREATE OR REPLACE FUNCTION now_and_then(cursor_in SYS_REFCURSOR) RETURN now_and_then_tt AS
  l_returnvalue now_and_then_tt := now_and_then_tt();
  l_now         VARCHAR2(8);
  l_then        VARCHAR2(8);
BEGIN
  LOOP
    FETCH cursor_in
      INTO l_now;
    EXIT WHEN cursor_in%NOTFOUND;
    l_then := to_char(SYSDATE, 'HH24:MI:SS');
    l_returnvalue.extend;
    l_returnvalue(l_returnvalue.last) := now_and_then_t(l_now, l_then);
  END LOOP;
  RETURN l_returnvalue;
END;
/
sho err

SELECT *
  FROM TABLE(now_and_then(CURSOR (SELECT *
                             FROM TABLE(now))))
/
pause Press any key to continue...

CREATE OR REPLACE FUNCTION now RETURN now_tt
  PIPELINED AS
  l_returnvalue now_t;
  l_now         VARCHAR2(8);
BEGIN
  FOR counter IN 1 .. 4 LOOP
    dbms_lock.sleep(2);
    l_now         := to_char(SYSDATE, 'HH24:MI:SS');
    l_returnvalue := now_t(l_now);
    PIPE ROW (l_returnvalue);
  END LOOP;
  RETURN;
END;
/
sho err

SELECT *
  FROM TABLE(now)
/
pause Press any key to continue...

SELECT *
  FROM TABLE(now_and_then(CURSOR (SELECT *
                             FROM TABLE(now))))
/
pause Press any key to continue...

CREATE OR REPLACE FUNCTION now_and_then(cursor_in SYS_REFCURSOR) RETURN now_and_then_tt
  PIPELINED AS
  l_returnvalue now_and_then_t;
  l_now         VARCHAR2(8);
  l_then        VARCHAR2(8);
BEGIN
  LOOP
    FETCH cursor_in
      INTO l_now;
    EXIT WHEN cursor_in%NOTFOUND;
    l_then        := to_char(SYSDATE, 'HH24:MI:SS');
    l_returnvalue := now_and_then_t(l_now, l_then);
    PIPE ROW(l_returnvalue);
  END LOOP;
  RETURN;
END;
/
sho err

SELECT *
  FROM TABLE(now_and_then(CURSOR (SELECT *
                             FROM TABLE(now))))
/

