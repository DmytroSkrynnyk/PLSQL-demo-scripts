DROP TYPE pet_t FORCE;
DROP TYPE zoo_t FORCE;

CREATE TYPE pet_t IS OBJECT (
   tag_no   INTEGER
  ,NAME     VARCHAR2 (60)
  ,breed    VARCHAR2 (100)
)
/

CREATE TYPE zoo_t IS TABLE OF pet_t
/

DROP TABLE wild_side;

CREATE TABLE wild_side (
   ID NUMBER PRIMARY KEY
 , DATA SYS.ANYDATA
)
/

DECLARE
   my_cat    pet_t
          := pet_t (50, 'Sister', 'Siamese');
   my_bird   pet_t
      := pet_t (100
               ,'Mercury'
               ,'African Grey Parrot'
               );
   my_pets   zoo_t := zoo_t (my_cat, my_bird);
BEGIN
   INSERT INTO wild_side
        VALUES (1
               ,SYS.ANYDATA.convertnumber
                                         (5));

   INSERT INTO wild_side
        VALUES (3
               ,SYS.ANYDATA.convertvarchar2
                      ('Pretty crazy stuff!'));

   INSERT INTO wild_side
        VALUES (5
               ,SYS.ANYDATA.convertdate
                                    (SYSDATE));

   INSERT INTO wild_side
        VALUES (2
               ,SYS.ANYDATA.convertobject
                                    (my_bird));

   INSERT INTO wild_side
        VALUES (7
               ,SYS.ANYDATA.convertcollection
                                    (my_pets));

   COMMIT;
END;
/

SELECT ID, ws.DATA.gettypename () thetype
  FROM wild_side ws;