open util/ordering[State]

-- Initial configuration:
--
--      -5 -4 -3 -2 -1  0 +1 +2 +3 +4    Legend
--    +-------------------------------   ===========
-- -2 |        B  .  .  .  .  .  .  .    . = floor
-- -1 |  B  .  .  .  .  .  .  Y  .  .    R = red statue
--  0 |  .  .  R  B  .  x  .  .  .  Y    B = blue statue
-- +1 |  .  .  .  .  .  .  .  Y  .  .    Y = yellow statue
-- +2 |  .  .  .  .  .  .  R  .  .  .    x = owl

-- Each statue has a color.
sig Statue {
    color: Color
}

-- There are three colors: red, blue, and yellow.
abstract sig Color {}
one sig Red, Blue, Yellow extends Color {}

-- There are 2 red, 3 blue, and 3 yellow statues.
fact {
    #color.Red = 2
    #color.Blue = 3
    #color.Yellow = 3
}

-- A coordinate is an (x,y) pair on the grid.
-- The x-axis is horizontal and the y-axis is vertical.
sig Coord {
    x, y: Int
}{
    -- Restrict to valid coordinates.
    x >= -5 and x <= 4
    y >= -3 and y <= 3
    not (x <= -4 and y <= -2)
}

-- There are no duplicate coordinates.
fact {
    no c, c': Coord | c != c' and c.x = c'.x and c.y = c'.y
}

-- Each state maps the statues to coordinates.
sig State {
    -- `Statue lone ->` means no two statues are at the same coordinate.
    -- `-> one Coord` means each statue occupies exactly one coordinate.
    pos: Statue lone -> one Coord,
    -- The player can create a block using the Cane of Somaria.
    block: lone Coord
}

-- Set up the initial state.
fact {
    some o: color.Red | first.pos[o].x = -3 and first.pos[o].y = 0
    some o: color.Red | first.pos[o].x = 1 and first.pos[o].y = 2
    some o: color.Blue | first.pos[o].x = -3 and first.pos[o].y = -2
    some o: color.Blue | first.pos[o].x = -5 and first.pos[o].y = -1
    some o: color.Blue | first.pos[o].x = -2 and first.pos[o].y = 0
    some o: color.Yellow | first.pos[o].x = 2 and first.pos[o].y = -1
    some o: color.Yellow | first.pos[o].x = 4 and first.pos[o].y = 0
    some o: color.Yellow | first.pos[o].x = 2 and first.pos[o].y = 1
}

-- Define the solution criteria.
pred solved[s: State] {
    -- The owl is surrounded by statues.
    all cx, cy: -1 + 0 + 1 | not (cx + cy = 0) implies some c: Coord {
        c.x = cx and c.y = cy and some s.pos.c
    }
// // This one is more elegant for exactly 55 Coord.
//    all c: Coord | c.x + c.y in -1 + 0 + 1 and c.x + c.y not in 0 => {
//        some s.pos.c
//    }
}

-- Specify the rules of the puzzle.
fact {
    all s: State, s': s.next {
        -- Link pushes a statue.
        some o: Statue {
            let
                -- Displacement of statue.
                dx = s'.pos[o].x.minus[s.pos[o].x],
                dy = s'.pos[o].y.minus[s.pos[o].y],
                -- Impediments (things a block can be stopped by).
                imps = { c: Coord | c.x + c.y = 0 } + s.block + s.pos[Statue]
            {
                -- It can move up, down, left, or right.
                dx + dy in 0 + 1 or dx + dy in 0 + -1
                -- There needs to be room for Link to push from the other side.
                some c: Coord {
                    c.x = s.pos[o].x.minus[dx]
                    c.y = s.pos[o].y.minus[dy]
                    no c & imps
                }
                -- All same-color statues move with it, if possible.
                all o': color.(o.color) {
                    -- There is a place to move (it doesn't fall off the edge).
                    some c: Coord {
                        -- It tries to go in the same direction.
                        c.x = s.pos[o'].x.plus[dx]
                        c.y = s.pos[o'].y.plus[dy]
                        -- And it succeeds as long as it is not blocked.
                        no c & imps implies s'.pos[o'] = c else s'.pos[o'] = s.pos[o']
                    }
                }
                -- No other statues move.
                all o': Statue - color.(o.color) {
                    s'.pos[o'] = s.pos[o']
                }
            }
        }
    }
}

-- Solve the puzzle.
run { solved[last] } for 5 Int, exactly 35 Coord, exactly 8 Statue, exactly 17 State
