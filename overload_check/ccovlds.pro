CREATE OR REPLACE PROCEDURE ccovlds (
   program_in   IN   VARCHAR2,
   verbose_in   IN   BOOLEAN := FALSE
)
IS
-- What can I say? I am very lazy...
BEGIN
   codecheck.overloadings (
      program_in,
      verbose_in      => verbose_in
   );
END;
/