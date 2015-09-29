BEGIN
   /* Compile betwnstr.sf files. */
   gen_trace_call ('BETWNSTR');
   /* Compile dyn_placeholder.pks/pkb files. */
   gen_trace_call ('DYN_PLACEHOLDER', 'ALL_IN_STRING');
   gen_trace_call (pkg_or_prog_in               => 'DYN_PLACEHOLDER'
                 , pkg_subprog_in               => 'ALL_IN_STRING'
                 , tracing_enabled_func_in      => 'mypkg.tracing_on ()'
                 , trace_func_in                => 'mupkg.show_action'
                  );
END;
/