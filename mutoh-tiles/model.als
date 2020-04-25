open util/ordering[State]

-- Initial configuration:
--
--     -1  0 +1
--    +--------    Legend
-- -1 | X  X  X    ========
--  0 | X  O  X    O = red
-- +1 | X  X  X    X = blue

-- There are 2 tile colors: Red and Blue.
abstract sig Color {}
one sig Red, Blue extends Color {}

-- A coordinate is an (x,y) pair on the grid.
-- The x-axis is horizontal and the y-axis is vertical.
sig Coord {
    x, y: Int
}{
    -- Restrict to valid coordinates.
    x >= -1 and x <= 1
    y >= -1 and y <= 1
}

-- There are no duplicate coordinates.
fact {
    no c, c': Coord | c != c' and c.x = c'.x and c.y = c'.y
}

-- Each state maps the coordinates to colors.
sig State {
    -- `-> one Color` means each coordinate has exactly one color.
    colors: Coord -> one Color
}

-- Set up the initial state.
fact {
    all c: Coord | first.colors[c] = Red iff c.x + c.y = 0
}

-- Define the solution criteria.
pred solved[s: State] {
    -- All tile colors are the same.
    one s.colors[Coord]
}

-- Predicate to tell if two coordinates are touching.
pred touching[c, c': Coord] {
    c.x.minus[c'.x] + c.y.minus[c'.y] in -1 + 0 + 1
}

-- Specify the rules of the puzzle.
fact {
    all s: State, s': s.next {
        -- The player clicks on one tile.
        some clicked: Coord | all c: Coord {
            -- That tile and all the ones it touches flip color.
            s.colors[c] = s'.colors[c] iff (not touching[c, clicked])
        }
    }
}

-- Solve the puzzle.
-- Note: Although {-1, 0, 1} fits in 2 bits, we need 3 bits for the
-- subtractions in the "touching" predicate (can reach 1 - (-1) = 2).
run { solved[last] } for 3 Int, exactly 9 Coord, exactly 9 State
