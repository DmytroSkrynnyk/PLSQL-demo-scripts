DROP  TYPE tickertype FORCE;
DROP  TYPE tickertypeset FORCE;
DROP  TABLE stocktable;
DROP  TABLE tickertable;

CREATE TABLE stocktable
(
   ticker        VARCHAR2 (20)
 , trade_date    DATE
 , open_price    NUMBER
 , close_price   NUMBER
)
/

BEGIN
   -- Populate the table.
   INSERT INTO stocktable
       VALUES ('ORCL'
             , SYSDATE
             , 15.2
             , 15.7
              );

   INSERT INTO stocktable
       VALUES ('DELL'
             , SYSDATE
             , 13.1
             , 13.5
              );

   INSERT INTO stocktable
       VALUES ('MSFT'
             , SYSDATE
             , 27
             , 27.04
              );

   FOR indx IN 1 .. 100000
   LOOP
      -- Might as well be optimistic!
      INSERT INTO stocktable
          VALUES ('STK' || indx
                , SYSDATE
                , indx
                , indx + 15
                 );
   END LOOP;

   COMMIT;
END;
/

CREATE TABLE tickertable
(
   ticker      VARCHAR2 (20)
 , pricedate   DATE
 , pricetype   VARCHAR2 (1)
 , price       NUMBER
)
/

/* 
   Note: Must use a nested table or varray of objects
   for the return type of a pipelined function
*/

CREATE TYPE tickertype AS OBJECT
   (ticker VARCHAR2 (20)
  , pricedate DATE
  , pricetype VARCHAR2 (1)
  , price NUMBER
   );
/

/*
Cannot use %ROWTYPE collection in package:

PLS-00642: local collection types not allowed in SQL statements

Even in 10g!
*/

CREATE TYPE tickertypeset AS TABLE OF tickertype;
/

CREATE OR REPLACE PACKAGE refcur_pkg
IS
   TYPE refcur_t IS REF CURSOR
      RETURN stocktable%ROWTYPE;
END refcur_pkg;
/

CREATE OR REPLACE FUNCTION stockpivot (dataset refcur_pkg.refcur_t)
   RETURN tickertypeset
IS
   c_limit CONSTANT PLS_INTEGER := 100;
   
   l_one_row   tickertype := tickertype (NULL, NULL, NULL, NULL);

   /* Container for rows fetched from the cursor variable. */
   TYPE dataset_tt IS TABLE OF stocktable%ROWTYPE
                         INDEX BY PLS_INTEGER;
   l_dataset   dataset_tt;

   /* The nested table that will be returned. */
   retval      tickertypeset := tickertypeset ();
BEGIN
   LOOP
      /* Fetch next 100 rows. */
      FETCH dataset BULK COLLECT INTO l_dataset
         LIMIT c_limit;

      EXIT WHEN l_dataset.COUNT = 0;

      /* Iterate through each row.... */
      FOR l_row IN 1 .. l_dataset.COUNT
      LOOP
         /* Create open price object type and add to collection. */
         l_one_row.ticker := l_dataset (l_row).ticker;
         l_one_row.pricetype := 'O';
         l_one_row.price := l_dataset (l_row).open_price;
         l_one_row.pricedate := l_dataset (l_row).trade_date;
         retval.EXTEND;
         retval (retval.LAST) := l_one_row;

         /* Create close price object type and add to collection. */
         l_one_row.pricetype := 'C';
         l_one_row.price := l_dataset (l_row).close_price;
         l_one_row.pricedate := l_dataset (l_row).trade_date;
         retval.EXTEND;
         retval (retval.LAST) := l_one_row;
      END LOOP;
   END LOOP;

   CLOSE dataset;

   RETURN retval;
END;
/

   INSERT INTO tickertable
      SELECT *
        FROM TABLE (stockpivot (CURSOR (SELECT *
                                          FROM stocktable)));
END;
/

/* Example of multiple transformations...

   "Unpivot" the data - written by Patrick Barel 200909
*/

CREATE OR REPLACE FUNCTION tickerpivot (dataset refcur_pkg.refcur_t)
   RETURN stocktypeset
IS
   l_one_row     stocktype := stocktype (NULL, NULL, NULL, NULL);

   TYPE dataset_tt IS TABLE OF tickertable%ROWTYPE
                         INDEX BY PLS_INTEGER;
   l_dataset   dataset_tt;

   /* The nested table that will be returned. */
   retval      stocktypeset := stocktypeset ();
BEGIN
   LOOP
      /* Move N rows from cursor variable (SELECT) to local collection. */
      FETCH dataset
      BULK COLLECT INTO l_dataset
      LIMIT 100;

      EXIT WHEN l_dataset.COUNT = 0;

      /* Iterate through each row.... */
      FOR l_row IN 1 .. l_dataset.COUNT
      LOOP
         /* START application specific logic.
            This will vary depending on your transformation. */

         /* Create price object type and add to collection. */
         l_one_row.ticker := l_dataset (l_row).ticker;

         IF l_dataset (l_row).pricetype = 'O'
         THEN
            l_one_row.openprice := l_dataset (l_row).price;
            l_one_row.closeprice := NULL;
         ELSE
            l_one_row.openprice := NULL;
            l_one_row.closeprice := l_dataset (l_row).price;
         END IF;

         retval.EXTEND;
         retval (retval.LAST) := l_one_row;
      END LOOP;
   END LOOP;


   CLOSE dataset;


   RETURN retval;
END;
/

/* Example of multiple transformations */


DECLARE
   CV   sys_refcursor;
BEGIN
   OPEN CV FOR
      SELECT *
        FROM TABLE (tickerpivot (CURSOR (SELECT *
                                           FROM TABLE(stockpivot(CURSOR (
                                                                    SELECT *
                                                                      FROM stocktable
                                                                 ))))));
END;
/

SELECT *
  FROM TABLE (tickerpivot (CURSOR (SELECT *
                                     FROM TABLE(stockpivot (
                                                   CURSOR (SELECT *
                                                             FROM stocktable)
                                                )))))
/