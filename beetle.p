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

new refresh_time
new bool:accelerate
new bool:asynchronous
new nof_roaches
new nof_beetles

new game_time = 20000
new bool:end_announced = false

new roaches[12] = [0]
new roach_alive[12] = [true, ...]
new roach_dead_countdown[12] = [0, ...]
new beetles[4] = [0]

new level
new level_settings[6][.nof_roaches, .nof_beetles, .refresh_time, .accelerate, .asynchronous] = [
    [5, 1, 1000, false, false],
    [6, 2, 1000, false, false],
    [8, 2, 1000, true, false],
    [9, 3, 900, true, false],
    [10, 3, 800, false, true],
    [12, 4, 800, true, true]
]

new score = 0

update_roaches()
{
    new i
    for (i = 0; i < nof_roaches; i++) {
        update_one_roach(i)
    }
}

update_one_roach(i)
{
    WalkerMove(roaches[i], STEP_FORWARD)
    new turn = GetRnd(5)
    if (turn < 2) {
        WalkerTurn(roaches[i], turn)
    }

    if (!roach_alive[i]) {
        roach_dead_countdown[i] -= refresh_time
        if (roach_dead_countdown[i] < 0) {
            roach_alive[i] = true
        }
    }
}

update_beetles()
{
    new i
    for (i = 0; i < nof_beetles; i++) {
        WalkerMove(beetles[i], STEP_FORWARD)
        new turn = GetRnd(5)
        if (turn < 2) {
            WalkerTurn(beetles[i], turn)
        }
    }
}

squash(side)
{
    new i
    new side_score = 0

    for (i = 0; i < nof_roaches; i++) {
        if (!roach_alive[i]) {
            continue
        }
        if (_side(roaches[i]) == side) {
            roach_alive[i] = false
            roach_dead_countdown[i] = 2 * refresh_time
            side_score++
        }
    }
    for (i = 0; i < nof_beetles; i++) {
        if (_side(beetles[i]) == side) {
            side_score = -5
            break
        }
    }

    printf("side_score: %d\n", side_score)
    if (side_score > 0) {
        Play("kap")
        score += side_score * (side_score - 1) + 1 
    } else if (side_score == 0) {
        Play("drip")
        score -= 1
    } else {
        Vibrate(75)
        score += side_score
    }

    printf("score: %d\n", score)
    redraw()
}

redraw()
{
    new i

    //FlashCanvas()
    ClearCanvas()
    for (i = 0; i < nof_roaches; i++) {
        //new color = 0x30000000
        //color += (0x000b0000) * (i+1)
        //color += (0x0c000000) * (i+1)
        new color = cRED
        if (roach_alive[i]) {
            DrawPC(roaches[i], color)
        }
    }
    for (i = 0; i < nof_beetles; i++) {
        DrawPC(beetles[i], cBLUE)
    }
    PrintCanvas()
    //FlashCanvas(1, 3, 1)
}

init()
{
    level = ModeSelect(6)

    nof_roaches = level_settings[level - 1][.nof_roaches]
    nof_beetles = level_settings[level - 1][.nof_beetles]
    refresh_time = level_settings[level - 1][.refresh_time]
    accelerate = level_settings[level - 1][.accelerate]
    asynchronous = level_settings[level - 1][.asynchronous]

    RegAllSideTaps()

    new i
    for (i = 0; i < nof_roaches; i++) {
        new starting_point = GetRnd(54)
        roaches[i] = _w(starting_point)
    }
    for (i = 0; i < nof_beetles; i++) {
        new starting_point = GetRnd(54)
        beetles[i] = _w(starting_point)
    }

}

main()
{
    new async_id = 0

    init()

    SetTimer(0, game_time)
    if (asynchronous) {
        SetTimer(1, refresh_time / nof_roaches)
    }
    SetTimer(2, refresh_time)

    redraw()

    for (;;) {
        if ((GetTimer(0) < 5000) && !end_announced) {
            end_announced = true
            Play("clocktickfast")
        } else if (GetTimer(0) == 0) {
            if (score < 0) {
                Score(-score, SCORE_LOSER)
            } else if (score > (level * 16)) {
                printf("score: %d, level*16: %d",
                        score, level * 16)
                Score(score, SCORE_WINNER)
            } else {
                Score(score, SCORE_NORMAL)
            }
        }

        /* The player taps on a side */
        if (Motion()) {
            new side
            GetTapSide(side)
            AckMotion()
            squash(side)
        }

        /* Intermediary refresh timer went off */
        if (asynchronous && GetTimer(1) == 0) {
            update_one_roach(async_id)
            async_id++
            if (async_id == nof_roaches) {
                async_id = 0
            }
            redraw()
            SetTimer(1, refresh_time / nof_roaches)
            printf("refresh: %d", refresh_time / nof_roaches)
        }
        /* refresh timer went off */
        if (GetTimer(2) == 0) {
            if (accelerate) {
                refresh_time -= 15
            }
            printf("refresh time: %d; time left: %d\n",
                    refresh_time, GetTimer(1))
            SetTimer(2, refresh_time)
            if (!asynchronous) {
                update_roaches()
            } /* else, roaches have already been updated */
            update_beetles()
            redraw()
        }
        Sleep()
    }
}
