DECLARE
   n         PLS_INTEGER;
   --
   -- Default constructor
   f_tmr     tmr_t       := tmr_t.make ('Function', 1000000);
   --
   -- Replacement for constructor
   dtf_tmr   tmr_t       := tmr_t.make ('Deterministic function', 1000000);
BEGIN
   f_tmr.go;

   FOR indx IN 1 .. 1000000
   LOOP
      n := utl_file_constants.max_linesize;
   END LOOP;

   f_tmr.STOP;
   dtf_tmr.go;

   FOR indx IN 1 .. 1000000
   LOOP
      n := utl_file_constants.max_linesize_dt;
   END LOOP;

   dtf_tmr.STOP;
END;
/