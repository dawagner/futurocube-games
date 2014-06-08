/*
 * Copyright (c) 2014, David Wagner All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 
 * 2. Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * 
 * 3. Neither the name of the copyright holder nor the names of its
 * contributors may be used to endorse or promote products derived from this
 * software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include <futurocube>

new sequenceLength
new sequence[6] = [0]

// return true if 'elem' is in 'list' (which is of size 'size')
is_in(elem, list[], size) {
    for (new i = 0; i < size; i++) {
        if (elem == list[i]) {
            return true
        }
    }
    return false
}

// randomly fills the reference list
init_list(length) {
    SetRandomizeFlag(1)

    for (new sequenceIndex = 0; sequenceIndex < length; ) {
        new candidate = GetRnd(6) + 1
        // Don't add duplicates to the list
        if (!is_in(candidate, sequence, sequenceIndex)) {
            sequence[sequenceIndex] = candidate
            sequenceIndex++
        }
    }
}

// fill each side with its corresponding color
draw_cube()
{
    for (new i=0; i < 6; i++) {
        SetColor(i+1)
        DrawSide(i)
    }
    PrintCanvas()
}

// draw exact guesses in green; color-only matches in red
draw_score(positionOk, colorOk)
{
    ClearCanvas()
    SetColor(cGREEN)
    DrawDigit(_w(0, 0), positionOk)
    SetColor(cRED)
    DrawDigit(_w(3, 0), colorOk)
    PrintCanvas()
}

// just wait a click ... any click and return
wait_click()
{
    for (;;) {
        if (Motion()) {
            AckMotion()
            return
        }
        Sleep()
    }
}

// highlight the selected side; wait for another click;
// return true if the same side is click, else false.
confirm(side)
{
    new confirmed = false

    // highlight the side
    SetIntensity(256)
    SetColor(side + 1)
    DrawSide(side)
    PrintCanvas()

    // wait for a click
    for (;;) {
        if (Motion()) {
            new tapSide = eTapSide()
            AckMotion()
            if (tapSide == side) {
                confirmed = true
            }
            break
        }
        Sleep()
    }

    // reset the side
    SetIntensity(128)
    DrawSide(side)
    PrintCanvas()

    return confirmed
}

// listen the player's sequence and determinate if his guesses are correct
listen_player(&positionOk, &colorOk)
{
    new playerSequence[6] = [0]
    new playerIndex = 0
    positionOk = 0
    colorOk = 0

    while(playerIndex < sequenceLength) {
        if (Motion()) {
            new tapSide = eTapSide()
            AckMotion()
            // Have the player confirm his choice
            if (!confirm(tapSide)) {
                continue
            }
            new elem = tapSide + 1

            if (is_in(elem, playerSequence, playerIndex)) {
                // The player has already tapped this side before,
                // refuse it
                Play("drip")
                continue
            }
            playerSequence[playerIndex] = elem

            Play("kap")
            if (sequence[playerIndex] == elem) {
                // The player got the right color at the right place
                printf("Yay, position ok!\n")
                positionOk++
            } else if (is_in(elem, sequence, sequenceLength)) {
                // The player found a color that is at some other place
                // in the sequence
                printf("Cool, color ok!\n")
                colorOk++
            }
            playerIndex++
        }
    }
}

game_loop()
{
    draw_cube()

    new positionOk, colorOk
    listen_player(positionOk, colorOk)
    printf("position: %d; color: %d\n", positionOk, colorOk)

    if (positionOk == sequenceLength) {
        // Victory
        Play("fanfare_short")
        return true
    }
    // black-outs the cube and wait for a click, so that the player
    // can secretly know his score before he hands the cube to the
    // next player
    ClearCanvas()
    PrintCanvas()
    wait_click()
    draw_score(positionOk, colorOk)
    // The player hides his score by clicking again
    wait_click()

    return false
}

main()
{
    new palette[] = [cGREEN, cBLUE,cRED,cORANGE,WHITE,cPURPLE]
    PaletteFromArray(palette)

    RegAllSideTaps()

    // At level N, you must guess N elements
    sequenceLength = ModeSelect(6)
    init_list(sequenceLength)

    // cheat loop :)  gives out the secret sequence
    for (new i=0; i < sequenceLength; i++) {
        SetColor(sequence[i])
        DrawCube()
        PrintCanvas()
        Delay(1000)
    }

    for (;;) {
        new gameEnd = game_loop()
        // Someone won
        if (gameEnd == true) {
            Restart()
        }
        Sleep()
    }
}
