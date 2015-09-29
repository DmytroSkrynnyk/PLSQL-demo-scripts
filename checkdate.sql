/* Date must no later than 15th in the month and no earlier than 2001 */

CREATE OR REPLACE FUNCTION plch_is_valid_date (
   datestring_in   IN VARCHAR2)
   RETURN BOOLEAN
IS
   l_date   DATE;
BEGIN
   SELECT dt
     INTO l_date
     FROM (SELECT TO_DATE (datestring_in, 'DDMONYYYY') dt
             FROM DUAL)
    WHERE     dt >= DATE '2001-01-01'
          AND TO_NUMBER (TO_CHAR (dt, 'DD')) <= 15;

   RETURN TRUE;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN FALSE;
END;
/

DECLARE
   PROCEDURE plch_show_boolean (val IN BOOLEAN)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (
         CASE val
            WHEN TRUE THEN 'TRUE'
            WHEN FALSE THEN 'FALSE'
            ELSE 'NULL'
         END);
   END plch_show_boolean;
BEGIN
   plch_show_boolean (plch_is_valid_date ('12DEC2012'));
   plch_show_boolean (plch_is_valid_date ('12DEC2000'));
   plch_show_boolean (plch_is_valid_date ('12ABC2012'));
   plch_show_boolean (plch_is_valid_date ('25DEC1900'));
END;
/

DECLARE
   b   BOOLEAN;
BEGIN
   plch_timer.start_timer;

   FOR indx IN 1 .. 100000
   LOOP
      b := plch_is_valid_date ('12DEC12');
   END LOOP;

   plch_timer.show_elapsed_time ('OK date');

   FOR indx IN 1 .. 100000
   LOOP
      b := plch_is_valid_date ('12DED12');
   END LOOP;

   plch_timer.show_elapsed_time ('Bad date');
END;
/

CREATE OR REPLACE FUNCTION plch_is_valid_date (
   datestring_in   IN VARCHAR2)
   RETURN BOOLEAN
IS
BEGIN
   RETURN     TO_DATE (datestring_in, 'DDMONYYYY') >=
                 DATE '2001-01-01'
          AND TO_NUMBER (SUBSTR (datestring_in, 1, 2)) <= 15;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN FALSE;
END;
/


DECLARE
   PROCEDURE plch_show_boolean (val IN BOOLEAN)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (
         CASE val
            WHEN TRUE THEN 'TRUE'
            WHEN FALSE THEN 'FALSE'
            ELSE 'NULL'
         END);
   END plch_show_boolean;
BEGIN
   plch_show_boolean (plch_is_valid_date ('12DEC2012'));
   plch_show_boolean (plch_is_valid_date ('12DEC2000'));
   plch_show_boolean (plch_is_valid_date ('12ABC2012'));
   plch_show_boolean (plch_is_valid_date ('25DEC1900'));
END;
/

DECLARE
   b   BOOLEAN;
BEGIN
   plch_timer.start_timer;

   FOR indx IN 1 .. 100000
   LOOP
      b := plch_is_valid_date ('12DEC12');
   END LOOP;

   plch_timer.show_elapsed_time ('OK date');

   FOR indx IN 1 .. 100000
   LOOP
      b := plch_is_valid_date ('12DED12');
   END LOOP;

   plch_timer.show_elapsed_time ('Bad date');
END;
/


CREATE OR REPLACE FUNCTION plch_is_valid_date (
   datestring_in   IN VARCHAR2)
   RETURN BOOLEAN
IS
BEGIN
   RETURN     TO_NUMBER (SUBSTR (datestring_in, 1, 2)) BETWEEN 1
                                                           AND 15
          AND SUBSTR (datestring_in, 3, 3) IN ('JAN',
                                               'FEB',
                                               'MAR',
                                               'APR',
                                               'MAY',
                                               'JUN',
                                               'JUL',
                                               'AUG',
                                               'SEP',
                                               'OCT',
                                               'NOV',
                                               'DEC')
          AND TO_NUMBER (SUBSTR (datestring_in, 6, 4)) >= 2001;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN FALSE;
END;
/

DECLARE
   PROCEDURE plch_show_boolean (val IN BOOLEAN)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (
         CASE val
            WHEN TRUE THEN 'TRUE'
            WHEN FALSE THEN 'FALSE'
            ELSE 'NULL'
         END);
   END plch_show_boolean;
BEGIN
   plch_show_boolean (plch_is_valid_date ('12DEC2012'));
   plch_show_boolean (plch_is_valid_date ('12DEC2000'));
   plch_show_boolean (plch_is_valid_date ('12ABC2012'));
   plch_show_boolean (plch_is_valid_date ('25DEC1900'));
END;
/

DECLARE
   b   BOOLEAN;
BEGIN
   plch_timer.start_timer;

   FOR indx IN 1 .. 100000
   LOOP
      b := plch_is_valid_date ('12DEC12');
   END LOOP;

   plch_timer.show_elapsed_time ('OK date');

   FOR indx IN 1 .. 100000
   LOOP
      b := plch_is_valid_date ('12DED12');
   END LOOP;

   plch_timer.show_elapsed_time ('Bad date');
END;
/

CREATE OR REPLACE FUNCTION plch_is_valid_date (
   datestring_in   IN VARCHAR2)
   RETURN BOOLEAN
IS
   l_number   NUMBER;
BEGIN
   l_number :=
        1000000
      + TO_NUMBER (
              SUBSTR (datestring_in, 1, 2)
           || SUBSTR (datestring_in, 6));
   RETURN l_number >= 1012001;
EXCEPTION
   WHEN OTHERS
   THEN
      RETURN FALSE;
END;
/

DECLARE
   PROCEDURE plch_show_boolean (val IN BOOLEAN)
   IS
   BEGIN
      DBMS_OUTPUT.put_line (
         CASE val
            WHEN TRUE THEN 'TRUE'
            WHEN FALSE THEN 'FALSE'
            ELSE 'NULL'
         END);
   END plch_show_boolean;
BEGIN
   plch_show_boolean (plch_is_valid_date ('12DEC2012'));
   plch_show_boolean (plch_is_valid_date ('12DEC2000'));
   plch_show_boolean (plch_is_valid_date ('12ABC2012'));
   plch_show_boolean (plch_is_valid_date ('25DEC1900'));
END;
/