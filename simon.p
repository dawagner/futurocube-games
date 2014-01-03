
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
    if (ok) {
        SetColor(cGREEN)
    } else {
        SetColor(cRED)
    }
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
        new motion=Motion()
        if (motion) {
            user_side = eTapSide()
            flash_side(user_side, 100)
            AckMotion()
            if (GetRnd(6) == user_side) {
                user_step++
            } else {
                return false
            }
            if (user_step == simon_step)
                return true
        }
        Sleep()
    }
}

waitFirstClick()
{
    for (;;) {
        if (Motion())
            return
        Sleep()
    }
}

main()
{
    new palette[]=[cBLUE,cRED,cORANGE,cMAGENTA,cPURPLE,cGREEN]
    PaletteFromArray(palette)
    init_list()

    RegAllSideTaps()

    waitFirstClick()

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
