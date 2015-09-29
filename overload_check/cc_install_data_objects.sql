create sequence cc_testcases_seq start with 100;

create table cc_testcases (
   id integer,
   owner varchar2(100),
   package_name varchar2(100),
   object_name varchar2(100),
   description varchar2(2000)
)
/
ALTER table cc_testcases add CONSTRAINT cc_testcases_pk
   primary key (id);
   
create sequence cc_ovld_outcomes_seq start with 200;

create table cc_ovld_outcomes (
      id integer,
	  testcase_id integer,
      overload1       VARCHAR2 (100),
	  startarg1 integer,
	  endarg1 integer,
	  overload2       VARCHAR2 (100),	  
	  startarg2 integer,
	  endarg2 integer	
	  /* These are not yet needed
	  object_name     VARCHAR2 (100),
      package_name    VARCHAR2 (100),
      owner           VARCHAR2 (100),
	  overload        INTEGER,
      POSITION        INTEGER,
      dataLEVEL       INTEGER,
      argument_name   VARCHAR2 (30),
      datatype        INTEGER,
      DEFAULT_VALUE   INTEGER,
      in_out          INTEGER,
      LENGTH          INTEGER,
      PRECISION       NUMBER,
      scale           NUMBER,
      radix           NUMBER
	  */  
)
/

ALTER table cc_ovld_outcomes add CONSTRAINT cc_ovld_outcomes_pk
   primary key (id);

ALTER table cc_ovld_outcomes add CONSTRAINT cc_ovld_outcomes_fk1
   FOREIGN KEY (testcase_id) REFERENCES cc_testcases;
 
-- Precisely and only what needs to be tested.
-- This is populated from cc_reports, only if
-- testing has been turned on.
   
create table cc_ambig_ovld_results (
  object_name     VARCHAR2 (100),
  package_name    VARCHAR2 (100),
  owner           VARCHAR2 (100),
  overload1       VARCHAR2 (100),
  startarg1 integer,
  endarg1 integer,
  overload2       VARCHAR2 (100),	  
  startarg2 integer,
  endarg2 integer	  
)
/ 

-- A view of control data that mirrors the results table.

CREATE OR REPLACE VIEW cc_ovld_control
AS
   SELECT tc.object_name, tc.package_name, tc.owner, 
          oo.overload1, oo.startarg1, oo.endarg1,
          oo.overload2, oo.startarg2, oo.endarg2
     FROM cc_testcases tc, cc_ovld_outcomes oo
    WHERE tc.ID = oo.testcase_id;
	
CREATE TABLE cc_analyses (
   name VARCHAR2(100),
   description VARCHAR2(1000)
);   	

ALTER table cc_analyses add CONSTRAINT cc_analyses_pk
   primary key (name);
   
INSERT INTO cc_analyses VALUES (
   'AMBIGUOUS OVERLOADING',
   'Ambiguous overloadings caused by too-similar parameter lists');

CREATE TABLE cc_error_info (
   errcode INTEGER,
   errmsg VARCHAR2(2000)
   );

ALTER TABLE cc_error_info ADD CONSTRAINT cc_error_info_pk
  PRIMARY KEY (errcode);
   
      