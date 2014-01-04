/* Copyright David Wagner 2014
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.

 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
