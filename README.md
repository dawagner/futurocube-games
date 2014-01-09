David's futurocube games and miscs
==================================

These are game and other apps for Princip's "Futurocube", which you
can learn all about at http://www.futurocube.com/

For compiling the games, you'll need the futurocube.inc headers, which can be
found here:
<http://isle.princip.cz/download/futurocube/sdk_examples/futurocube.inc>

And of course, the SDK: http://www.futurocube.com/sdk/

Documentation of the games
==========================

Simon
-----
This is a clone of the famous "Simon game" or "Simon says".

Tap any side when you are ready to begin.  The cube flashes a side, then the
entire cube flashes green to indicate that it is your turn to tap the side
that was just flashed.

After you've tapped the correct side, the cube flashes green to congratulate
you, then proceed to flash the same side as before AND another one after that.
Again, you'll have to tap the right sides in the right order.  Each time you
replay the sequence correctly, the cube adds one step to the sequence.

If you fail, the cube flashes red and displays your score.  Tap twice to close
the score, then once to start over.

Conway (Work in progress)
-------------------------
Implementation of Conway's cellular automata, "[Game of
Life](http://en.wikipedia.org/wiki/Conway%27s_game_of_life)".  This automata
is usually ran on an infinite flat surface.  On a flat surface, each cell has
8 neighbours.  On a cube, cells located near vertices only have 7 neighbours !

First, choose what cells are to be alive at the beginning of the simulation
with the blinking cursor - validate by tapping the cube.  Start the simulation
by tapping the bottom side.

You may stop and reset the cube by tapping it twice.
