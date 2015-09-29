This is the Title of the Book,eMatter Edition
Copyright © 2002 O ’Reilly &Associates,Inc.All rights reserved.
Labels | 81
thinking about what that code is supposed to do,sometimes ferreting out errors in
the process.
Another reason to use a block label is to allow you to qualify references to elements
from an enclosing block that have duplicate names in the current,nested block.
Here ’s a schematic example:
<<outerblock>>
DECLARE
counter INTEGER :=0;
BEGIN
...
DECLARE
counter INTEGER :=1;
BEGIN
IF counter =outerblock.counter
THEN
...
END IF;
END;
END;
Without the block label,there would be no way to distinguish between the two
“counter ”variables.Again,though,a better solution would probably have been to
use distinct variable names.
A third function of labels is to serve as the target of a GOTO statement.However,
these days,GOTO statements are virtually nonexistent,thanks to Edsger Dijkstra ’s
now-legendary note on the subject.*In all the PL/SQL code I ’ve ever seen,I recall
only one GOTO.
Although few programs I ’ve seen or worked on require the use of labels,there is one
final use of this feature that is more significant than the previous three combined:a
label can serve as a target for the EXIT statement in nested loops.Here ’s the exam-
ple code:
BEGIN
<<outer_loop>>
LOOP
LOOP
EXIT outer_loop;
END LOOP;
some_statement ;
END LOOP;
END;
*“Go To Statement Considered Harmful,”which originally appeared in the March 1968 Communications of
the ACM ,was a paper influential enough to introduce the phrase considered harmful into the lexicon of
computerese.
,ch03.6282 Page 81 Thursday, August 8, 2002 10:40 AM