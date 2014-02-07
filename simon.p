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

new simon_step=1
new rnd_seed

init_list()
{
    rnd_seed = GetRnd(0xffff)
    SetRandomizeFlag(0)
}

play_list()
{
    SetRndSeed(rnd_seed)
    for (new play_step=0;
         play_step < simon_step;
         play_step++) {

        flash_side(GetRnd(6), 500)
        Delay(250)
    }
}

feedback(ok) {
    SetIntensity(40)
    SetColor(ok ? cGREEN : cRED)

    DrawCube()
    PrintCanvas()
    Delay(100)
    ClearCanvas()
    PrintCanvas()

    SetIntensity(128)
}

flash_side(side, duration) {
    SetColor(side+1)
    ClearCanvas()
    DrawSide(side)
    PrintCanvas()
    Delay(duration)
    ClearCanvas()
    PrintCanvas()
}

listen_user() {
    new user_step=0
    new user_side

    SetRndSeed(rnd_seed)

    for (;;) {
        if (Motion()) {
            user_side = eTapSide()
            flash_side(user_side, 100)
            AckMotion()
            if (GetRnd(6) == user_side) {
                user_step++
            } else {
                return false
            }
            if (user_step == simon_step) {
                return true
            }
        }
        Sleep()
    }
}

wait_first_click()
{
    for (;;) {
        if (Motion()) {
            AckMotion()
            return
        }
        Sleep()
    }
}

main()
{
    new palette[]=[cBLUE,cRED,cORANGE,cMAGENTA,cPURPLE,cGREEN]
    PaletteFromArray(palette)
    init_list()

    RegAllSideTaps()

    wait_first_click()

    for (;;) {
        play_list()

        AckMotion()
        feedback(true)
        new success = listen_user()
        Delay(500)
        if (success) {
            feedback(true)
            simon_step++
        } else {
            feedback(false)
            Score(simon_step - 1)
        }
        Delay(500)

        Sleep()
    }
}
