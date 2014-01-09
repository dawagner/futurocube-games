#include <futurocube>

const cell_state: {
    bearing = 0,
    alive,
    dying,
    dead
}

new const state_colors[] = [cMAGENTA, cGREEN, cPURPLE, 0]

/*new cells[6][9] = {dead, ...}*/
new cell_state:cells[6][9] = [
    [dead, ...],
    [dead, ...],
    [dead, ...],
    [dead, ...],
    [dead, ...],
    [dead, ...]]

new const walker_steps[] = [
    STEP_FORWARD,
    STEP_BACKWARDS,
    STEP_LEFT,
    STEP_RIGHT,
    STEP_UPLEFT,
    STEP_UPRIGHT,
    STEP_DOWNLEFT,
    STEP_DOWNRIGHT]

cell_state: get_cell(wi)
{
    return cells[_side(wi)][_square(wi)]
}

set_cell(wi, cell_state: new_state)
{
    cells[_side(wi)][_square(wi)] = new_state
}

get_color(wi)
{
    return state_colors[get_cell(wi)]
}

is_alive_now(wi)
{
    new cell_state:cell = get_cell(wi)
    return (cell == alive || cell == dying)
}

update_state(wi, alive_neighbours)
{
    new cell_state:next_state = get_cell(wi)
    if (next_state == alive) {
        if (alive_neighbours > 3 || alive_neighbours < 2) {
            next_state = dying
        } else {
            next_state = alive
        }
    } else {
        if (alive_neighbours == 3) {
            next_state = bearing
        }
    }

    set_cell(wi, next_state)
}

bool: skip_step(step, square)
{
    new walker_step = walker_steps[step]
    if (walker_step == STEP_UPLEFT && square == 0) {
        return true
    }
    if (walker_step == STEP_UPRIGHT && square == 2) {
        return true
    }
    if (walker_step == STEP_DOWNLEFT && square == 6) {
        return true
    }
    if (walker_step == STEP_DOWNRIGHT && square == 8) {
        return true
    }
    return false
}

update_pass_1() {
    for (new side=0; side < 6; side++) {
        for (new square=0; square < 9; square++) {
            new walker = _w(side, square)
            new alive_neighbours = 0
            for (new step=0; step < sizeof(walker_steps); step++) {
                if (skip_step(step, square) == true) {
                    continue
                }
                WalkerMove(walker, walker_steps[step])
                /*printf("walker now at %d/%d\n",
                        _side(walker), _square(walker))*/
                if (is_alive_now(walker)) {
                    alive_neighbours++
                }
                walker = _w(side, square)
            }
            update_state(walker, alive_neighbours)
        }
    }
}

update_pass_2()
{
    new walker
    for (new side=0; side < 6; side++) {
        for (new square=0; square < 9; square++) {
            walker = _w(side, square)
            if (get_cell(walker) == dying) {
                set_cell(walker, dead)
            } else if (get_cell(walker) == bearing) {
                set_cell(walker, alive)
            }
        }
    }
}

update_canvas()
{
    for (new side=0; side < 6; side++) {
        for (new square=0; square < 9; square++) {
            new walker = _w(side, square)
            DrawPC(walker, get_color(walker))
        }
    }
}

user_setup()
{
    new cursor

    SetColor(WHITE)

    for (;;) {
        update_canvas()
        cursor = GetCursor()

        if (is_alive_now(cursor)) {
            SetColor(cRED)
        } else {
            SetColor(cGREEN)
        }
        DrawFlicker(cursor)

        if (Motion()) {
            Play("drip")
            if (eTapToBot()) {
                AckMotion()
                return
            }
        
            if (get_cell(cursor) == alive) {
                set_cell(cursor, dead)
            } else {
                set_cell(cursor, alive)
            }
            DrawPC(cursor, cGREEN)
            AckMotion()
        }
        PrintCanvas()
        Sleep()
    }
}

main()
{
    new motion
    RegAllSideTaps()
    RegMotion(TAP_DOUBLE)

    user_setup()

    for (;;) {
        /* TODO: implement pause, speed adjustment */
        motion = Motion()
        if (motion && _is(motion, TAP_DOUBLE)) {
            AckMotion()
            Restart()
        }

        update_canvas()
        PrintCanvas()
        /* FIXME: sleep for a shorter time but use a timer instead, for
         * ensuring 1s delay.  Issue with Sleep(1000) is that motions are
         * checked every 2 seconds only... */
        Sleep(1000)
        update_pass_1()
        update_canvas()
        PrintCanvas()
        Sleep(1000)
        update_pass_2()
    }
}
