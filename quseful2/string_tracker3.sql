DECLARE
   /* Create a constant with the list name to avoid multiple,
      hard-coded references. Notice the use of the subtype
      declared in the string_tracker package to declare the 
      list name. */
   c_list_name   CONSTANT string_tracker.list_name_t  := 'outcomes';
   
   /* QCGU: A collection based on a %ROWTYPE associative array type */
   l_outcomes             qu_outcome_tp.qu_outcome_tc;
BEGIN
   /* Create the list, wiping out anything that was there before. */
   string_tracker.create_list (list_name_in           => c_list_name
                             , case_sensitive_in      => FALSE
                             , overwite_in            => TRUE
                              );
   /* QCGU: get all the outcome rows for the specified test case. */
   l_outcomes := qu_outcome_qp.ar_fk_outcome_case (l_my_test_case);

   /* For each outcome... */
   FOR indx IN 1 .. l_outcomes.COUNT
   LOOP
      /* IF the string has not already been used... */
      IF NOT string_tracker.string_in_use (c_list_name
                                         , l_outcomes (indx).variable_name
                                          )
      THEN
         /* Add the declaration to the test package. */
         generate_declaration (l_outcomes (indx));
         
         /* Make sure I don't generate duplicate declarations. */
         string_tracker.mark_as_used (c_list_name
                                    , l_outcomes (indx).variable_name
                                     );
      END IF;
   END LOOP;
   
   /* Clean up! */
   string_tracker.clear_list (c_list_name);
END;