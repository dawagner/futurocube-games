#include <futurocube>

/*
const state: {
    bearing = 0,
    alive,
    dying,
    dead
}
*/
const bearing = 0
const alive = 1
const dying = 2
const dead = 3

new const state_colors[] = [cMAGENTA, cGREEN, cPURPLE, 0]

/*new cells[6][9] = {dead, ...}*/
new cells[6][9] = [
    [alive, alive, alive, dead, dead, dead, dead, dead, dead],
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

get_cell(wi)
{
    return cells[_side(wi)][_square(wi)]
}


get_color(wi)
{
    return state_colors[get_cell(wi)]
}

is_alive_now(wi)
{
    new cell = get_cell(wi)
    return (cell == alive || cell == dying)
}

update_state(wi, alive_neighbours)
{
    new next_state = get_cell(wi)
    if (next_state == alive) {
        if (alive_neighbours > 3 || alive_neighbours < 2) {
            next_state = dying
            printf("dying\n")
        } else {
            next_state = alive
            printf("still alive\n")
        }
    } else {
        if (alive_neighbours == 3) {
            next_state = bearing
            printf("bearing\n")
        }
    }

    cells[_side(wi)][_square(wi)] = next_state
}

update_pass_1() {
    for (new side=0; side < 6; side++) {
        for (new square=0; square < 9; square++) {
            new walker = _w(side, square)
            new alive_neighbours = 0
            for (new step=0; step < sizeof(walker_steps); step++) {
                WalkerMove(walker, walker_steps[step])
                printf("walker now at %d/%d\n",
                        _side(walker), _square(walker))
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
    for (new side=0; side < 6; side++) {
        for (new square=0; square < 9; square++) {
            if (cells[side][square] == dying) {
                cells[side][square] = dead
            } else if (cells[side][square] == bearing) {
                cells[side][square] = alive
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

main()
{
    for (;;) {
        update_canvas()
        PrintCanvas()
        Sleep(1000)
        update_pass_1()
        update_canvas()
        PrintCanvas()
        Sleep(1000)
        update_pass_2()
    }
}
