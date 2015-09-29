CREATE TABLE person 
   (person_id number(4), 
    person_nm varchar2(10));

CREATE TYPE object_t AS OBJECT (keyno NUMBER, name VARCHAR2(100));

CREATE TYPE varray_t AS VARRAY(100) OF anobject_t;

CREATE TYPE table_t is table of integer;

CREATE PACKAGE indexby 
IS
  TYPE table_t is TABLE OF integer index by binary_integer;
end;
/
   
CREATE OR REPLACE PROCEDURE cc_types_check (
   c_varchar2         VARCHAR2,
   c_varchar          VARCHAR,
   c_char             CHAR,
   c_nchar            NCHAR,
   c_nvarchar2        NVARCHAR2,
--
   c_number           NUMBER,
   c_integer          INTEGER,
   c_binary_integer   BINARY_INTEGER,
   c_pls_integer      PLS_INTEGER,
   c_positive positive,
   c_natural natural,
   c_decimal decimal,
   c_float float,
--
   c_rowid            ROWID,
   c_urowid           UROWID,
   c_date             DATE,
   c_timestamp        TIMESTAMP,
   c_interval_ym      interval year to month,
   c_interval_ds      interval day to second,
   c_timestamp_tz     timestamp with time zone,
   c_timestamp_ltz    timestamp with local time zone,
--      
   c_boolean          BOOLEAN,
   c_mlslabel         MLSLABEL,
   c_refcursor        sys_refcursor,
--
   c_long             LONG,
   c_raw              RAW,
   c_longraw          long raw,
   c_clob             CLOB,
   c_blob             BLOB,
   c_bfile            BFILE,
   c_nclob            NCLOB,
--   
   c_object           object_t,
   c_record           person%rowtype,
   c_nested_table     table_t,
   c_varray           varray_t,
   c_indexby_table    indexby.table_t,
--
   c_xmltype xmltype,
   c_uritype uritype,
   c_utlfiletype utl_file.file_type,
   c_anydata anydata,
   c_anydataset anydataset,
   c_anytype anytype
)
IS
BEGIN
   NULL;
END;
/
