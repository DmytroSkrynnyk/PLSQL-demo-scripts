CREATE TABLE plch_employees
(
   employee_id   INTEGER,
   last_name     VARCHAR2 (100),
   salary        NUMBER
)
/

INSERT INTO plch_employees
        VALUES (
                  12345678901234567890123456789012345678901,
                  'Jobs',
                  1000000);

INSERT INTO plch_employees
        VALUES (
                  12345678901234567890123456789012345678902,
                  'Ellison',
                  1000000);

INSERT INTO plch_employees
        VALUES (
                  12345678901234567890123456789012345678903,
                  'Gates',
                  1000000);

SELECT COUNT (*) FROM plch_employees
/

BEGIN
   INSERT INTO plch_employees
           VALUES (
                     12345678901234567890123456789012345678901,
                     'Jobs',
                     1000000);

   INSERT INTO plch_employees
           VALUES (
                     12345678901234567890123456789012345678902,
                     'Ellison',
                     1000000);

   INSERT INTO plch_employees
           VALUES (
                     12345678901234567890123456789012345678903,
                     'Gates',
                     1000000);

   COMMIT;
END;
/