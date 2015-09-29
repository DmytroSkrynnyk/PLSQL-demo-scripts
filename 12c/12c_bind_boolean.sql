CREATE PACKAGE restaurant_pkg
AS
   TYPE item_list_t IS TABLE OF VARCHAR2(30);
   PROCEDURE eat_that(what IN item_list_t, with_sauce IN BOOLEAN);
END;
/

CREATE PACKAGE BODY restaurant_pkg
AS
   PROCEDURE eat_that(what IN item_list_t, with_sauce IN BOOLEAN)
   IS
   BEGIN
      NULL; -- chomp chomp
   END;
END;
/

DECLARE
   things restaurant_pkg.item_list_t := 
      restaurant_pkg.item_list_t('steak', 'quiche', 'eggplant');
BEGIN
   /* Requires Oracle Database 12c or later */
   EXECUTE IMMEDIATE 'BEGIN restaurant_pkg.eat_that(:l, :s); END;' 
      USING things, TRUE;
END;
/