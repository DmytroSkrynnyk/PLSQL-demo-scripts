ALTER SESSION SET plsql_warnings = 'ENABLE:ALL'
/

CREATE OR REPLACE PACKAGE nocopy_test AUTHID DEFINER
IS
   TYPE number_nt IS TABLE OF NUMBER;

   PROCEDURE with_in (
      just_in IN  number_nt);

   PROCEDURE with_out (
      just_out OUT number_nt);

   PROCEDURE with_in_out (
      in_and_out IN OUT number_nt);

   PROCEDURE with_nocopy (
      with_nocopy IN OUT NOCOPY number_nt);
END;
/

/* Can also be very selective */

ALTER SESSION SET plsql_warnings = 'ENABLE:7203'
/

CREATE OR REPLACE PACKAGE nocopy_test
IS
   TYPE number_nt IS TABLE OF NUMBER;

   PROCEDURE with_in (
      just_in IN  number_nt);

   PROCEDURE with_out (
      just_out OUT number_nt);

   PROCEDURE with_in_out (
      in_and_out IN OUT number_nt);

   PROCEDURE with_nocopy (
      with_nocopy IN OUT NOCOPY number_nt);
END;
/

/* Can INSIST that NOCOPY be used! */

ALTER SESSION SET plsql_warnings = 'ERROR:7203'
/

CREATE OR REPLACE PACKAGE nocopy_test
IS
   TYPE number_nt IS TABLE OF NUMBER;

   PROCEDURE with_in (
      just_in IN  number_nt);

   PROCEDURE with_out (
      just_out OUT NOCOPY number_nt);

   PROCEDURE with_in_out (
      in_and_out IN OUT NOCOPY number_nt);

   PROCEDURE with_nocopy (
      with_nocopy IN OUT NOCOPY number_nt);
END;
/