CREATE OR REPLACE PROCEDURE pick_winners_randomly (
   total_count_in IN PLS_INTEGER
 , winner_count_in IN PLS_INTEGER
 , ineligible_in IN VARCHAR2 DEFAULT NULL
 , delimiter_in IN VARCHAR2 DEFAULT ','
)
IS
   more_winners_needed   BOOLEAN        DEFAULT TRUE;

   TYPE selections_aat IS TABLE OF PLS_INTEGER
      INDEX BY PLS_INTEGER;

   l_ineligibles         selections_aat;
   l_already_chosen      selections_aat;
   l_winners             selections_aat;
   l_max_winners         PLS_INTEGER;

   PROCEDURE load_ineligibles /* Parse the delimited string. */
   IS
      l_loc        PLS_INTEGER;
      l_row        PLS_INTEGER;
      l_startloc   PLS_INTEGER      := 1;
      l_item       VARCHAR2 (32767);
   BEGIN
      l_row := l_ineligibles.COUNT + 1;

      IF ineligible_in IS NOT NULL
      THEN
         LOOP
            -- Get the next item.
            l_loc := INSTR (ineligible_in, delimiter_in, l_startloc);

            IF l_loc = l_startloc
            THEN
               l_item := NULL;
            ELSIF l_loc = 0
            THEN
               l_item := SUBSTR (ineligible_in, l_startloc);
            ELSE
               l_item :=
                       SUBSTR (ineligible_in, l_startloc, l_loc - l_startloc);
            END IF;

            l_ineligibles (TO_NUMBER (l_item)) := 0;

            -- Was that the last one?
            IF l_loc = 0
            THEN
               EXIT;
            ELSE
               l_startloc := l_loc + 1;
               l_row := l_row + 1;
            END IF;
         END LOOP;
      END IF;

      l_max_winners :=
                 LEAST (winner_count_in, total_count_in - l_ineligibles.COUNT);
   END load_ineligibles;

   PROCEDURE add_another_winner (more_winners_needed_out OUT BOOLEAN)
   IS
      next_winner   PLS_INTEGER;
   BEGIN
      LOOP
         next_winner := ROUND (DBMS_RANDOM.VALUE (1, total_count_in));

         IF    l_ineligibles.EXISTS (next_winner)
            OR l_already_chosen.EXISTS (next_winner)
         THEN
            -- Try again.
            NULL;
         ELSE
            l_winners (l_winners.COUNT + 1) := next_winner;
            l_already_chosen (next_winner) := 0;
         END IF;

         EXIT WHEN l_winners.COUNT = l_max_winners;
      END LOOP;
   END add_another_winner;

   PROCEDURE display_results
   IS
      l_index   PLS_INTEGER;
   BEGIN
      DBMS_OUTPUT.put_line (RPAD ('=', 60, '='));
      DBMS_OUTPUT.put_line ('Winners Chosen Randomly!');
      DBMS_OUTPUT.put_line ('.  Total count = ' || total_count_in);
      DBMS_OUTPUT.put_line ('.  Winner count = ' || winner_count_in);
      DBMS_OUTPUT.put_line ('.  Ineligibles = ' || ineligible_in);
      DBMS_OUTPUT.put_line (RPAD ('=', 60, '='));
      DBMS_OUTPUT.put_line ('Winning numbers are: ');
      l_index := l_winners.FIRST;

      FOR l_index IN 1 .. l_winners.COUNT
      LOOP
         DBMS_OUTPUT.put_line (l_winners (l_index));
      END LOOP;
   END display_results;
BEGIN
   load_ineligibles;

   WHILE (more_winners_needed)
   LOOP
      add_another_winner (more_winners_needed);
   END LOOP;

   display_results;

END pick_winners_randomly;
/