DECLARE
   l_onearg   descproc.arglist_rt;
BEGIN
   descproc.getargs ('allargs_test.upd');

   FOR indx IN 1 .. descproc.numargs
   LOOP
      l_onearg := descproc.onearg (indx);

      -- Display the data type.
      DBMS_OUTPUT.put_line (
            'Argument ' 
       || indx 
       || ' type = ' 
       || l_onearg.datatype
      );
   END LOOP;
END;
/
