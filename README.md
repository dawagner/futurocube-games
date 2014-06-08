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


Beetle
------
In this game, you must squash the red cockroaches crawling on the surface of
the cube.  But you mustn't hit the cute blue ladybugs !

Tap on a side to kill all cockroaches on it.  The more you kill with one tap,
the more points you get.  However, if there was a ladybug on that same side,
you loose points (but the ladybug doesn't die, phew !).

Before starting the game, you will be offered a choice between 6 difficulty
levels.  Level 1 is a stroll in the park - after playing level 6, you won't
need a coffee anymore.


Multiplayer mastermind
----------------------
    
2-6 players on a single cube

Players take turns trying to guess a sequence of colors secretly decided by the
cube (colors do not repeat within the sequence).

At the beginning of the game, the players must choose a level (1-6): this will
be the length of the sequence to be guessed (of course, 1 or 2 are pointless...)

The active player taps a sequence (tap twice, so as to avoid "misclicks") in
front of all the other players. Once he's done, the cube blacks-out. The player
then hides the cube and click once again to reveal the score to himself only.
Exact guesses are drawn in green, color-only (correct color, wrong position) are
drawn in red.

Now, the active player may (or may not) announce his score. If he chooses to, he
is not obliged to announce his real score: he may lie about it. The next player
has to choose whether he believes him or not.

If he does not believe him, the active player reveals his score on the cube to
the next player. Two cases:
    A) the player lied -> It is now the next players' turn.
    B) the player did not lie -> he plays again (but cannot chose to announce
his score again that time).

If the active player does not chose to announce his score, he hides his score by
clicking once more and hands the cube to the next player.

The first player to play the correct sequence wins and is greeted by a fanfare.

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
