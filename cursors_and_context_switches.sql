CREATE TABLE em_memes
(
   meme_id       INTEGER,
   title         VARCHAR2 (100),
   description   VARCHAR2 (4000)
)
/

CREATE TABLE em_meme_activities
(
   meme_id         INTEGER,
   activity_date   DATE,
   description     VARCHAR2 (4000)
)
/

/* Really, it's a materialized view - but for the 
   article I will keep things simple, really simple. */

CREATE TABLE em_meme_stats_mv
(
   meme_id         INTEGER,
   stats_summary   VARCHAR2 (4000)
)
/

BEGIN
   INSERT INTO em_memes
           VALUES (
                     1,
                     'Cats doing somersaults',
                     'When that cat flips, the world flipswith it.');

   INSERT INTO em_meme_activities
           VALUES (
                     1,
                     DATE '2015-04-01',
                     '1,000,000 new cat videos uploaded');

   INSERT INTO em_meme_activities
           VALUES (
                     1,
                     DATE '2015-04-02',
                     '2,000,000 new cat videos uploaded');

   INSERT INTO em_meme_stats_mv
        VALUES (1, '1705 views; 2504460 likes');

   COMMIT;
END;
/

CREATE OR REPLACE FUNCTION em_meme_summary (
   meme_id_in   IN em_memes.meme_id%TYPE)
   RETURN VARCHAR2
IS
   l_return   VARCHAR2 (32767);
BEGIN
   SELECT stats_summary
     INTO l_return
     FROM em_meme_stats_mv
    WHERE meme_id = meme_id_in;

   RETURN l_return;
END;
/

CREATE OR REPLACE FUNCTION em_meme_history (
   meme_id_in   IN em_memes.meme_id%TYPE)
   RETURN VARCHAR2
IS
   l_return   VARCHAR2 (32767);
BEGIN
   SELECT LISTAGG (a.activity_date || ' - ' || a.description,
                   CHR (10))
          WITHIN GROUP (ORDER BY a.activity_date)
     INTO l_return
     FROM em_meme_activities a
    WHERE meme_id = meme_id_in;

   RETURN l_return;
END;
/

CREATE OR REPLACE PROCEDURE em_meme_reporter (
   meme_id_in   IN em_memes.meme_id%TYPE)
IS
BEGIN
   FOR one_meme
      IN (SELECT title,
                 em_meme_summary (meme_id) summary,
                 em_meme_history (meme_id) history
            FROM em_memes
           WHERE meme_id = meme_id_in)
   LOOP
      DBMS_OUTPUT.put_line (one_meme.title);
      DBMS_OUTPUT.put_line (one_meme.summary);
      DBMS_OUTPUT.put_line (one_meme.history);
   END LOOP;
END;
/

BEGIN
   em_meme_reporter (1);
END;
/

/* Should be.... */



CREATE OR REPLACE PROCEDURE em_meme_reporter (
   meme_id_in   IN em_memes.meme_id%TYPE)
IS
   l_title           em_memes.title%TYPE;
   l_stats_summary   em_meme_stats_mv.stats_summary%TYPE;
BEGIN
   SELECT m.title, s.stats_summary
     INTO l_title, l_stats_summary
     FROM em_memes m, em_meme_stats_mv s
    WHERE     m.meme_id = em_meme_reporter.meme_id_in
          AND m.meme_id = s.meme_id;

   DBMS_OUTPUT.put_line (l_title);
   DBMS_OUTPUT.put_line (l_stats_summary);

   FOR activity_rec
      IN (  SELECT a.activity_date || ' - ' || a.description
                      one_activity
              FROM em_meme_activities a
             WHERE a.meme_id = em_meme_reporter.meme_id_in
          ORDER BY a.activity_date)
   LOOP
      DBMS_OUTPUT.put_line (activity_rec.one_activity);
   END LOOP;
END;
/

BEGIN
   em_meme_reporter (1);
END;
/

DROP TABLE em_memes
/

DROP TABLE em_meme_stats_mv
/

DROP TABLE em_meme_activities
/