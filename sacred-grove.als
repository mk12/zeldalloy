open util/ordering[State]

-- Initial configuration:
--
--      -2 -1  0 +1 +2    Legend
--    +---------------    ===========
-- -3 |  x  x  .  x  x    . = empty
-- -2 |  x  o  A  o  x    x = square
-- -1 |  x  x  x  x  x    o = goal
--  0 |  .  x  L  x  .    L = Link
-- +1 |  .  x  x  x  .    A = StatueA
-- +2 |  .  .  B  .  .    B = StatueB
--
-- We use negative integers so that we can have a smaller
-- bit-width scope (Alloy only supports signed integers).
-- It's also nice to have Link start at the origin.

-- There are 3 objects: Link and the two statues.
abstract sig Object {}
one sig Link, StatueA, StatueB extends Object {}

-- A coordinate is an (x,y) pair on the grid.
-- The x-axis is horizontal and the y-axis is vertical.
sig Coord {
	x, y: Int
}{
    -- Restrict to valid coordinates.
    x >= -2 and x <= 2
    y >= -3 and y <= 2
    not (x = 0 and y = -3)
    not (x in -2 + 2 and y >= 0)
    not (x in -1 + 1 and y = 2)
}

-- There are no duplicate coordinates.
fact {
	no c, c': Coord | c != c' and c.x = c'.x and c.y = c'.y
}

-- Each state maps the objects to coordinates.
sig State {
    -- `Object lone ->` means no two objects are at the same coordinate.
    -- `-> one Coord` means each object occupies exactly one coordinate.
	pos: Object lone -> one Coord
}

-- Set up the initial state.
fact {
    first.pos[Link].x = 0 and first.pos[Link].y = 0
	first.pos[StatueA].x = 0 and first.pos[StatueA].y = -2
	first.pos[StatueB].x = 0 and first.pos[StatueB].y = 2
}

-- Define the solution criteria.
pred solved[s: State] {
    s.pos[StatueA].x + s.pos[StatueB].x = -1 + 1
    s.pos[StatueA].y + s.pos[StatueB].y = -2
}

-- Specify the rules of the puzzle.
fact {
    all s: State, s': s.next {
        let
            -- Position of Link.
            Lx = s.pos[Link].x,
            Lx' = s'.pos[Link].x,
            Ly = s.pos[Link].y,
            Ly' = s'.pos[Link].y,
            -- Position of StatueA.
            Ax = s.pos[StatueA].x,
            Ax' = s'.pos[StatueA].x,
            Ay = s.pos[StatueA].y,
            Ay' = s'.pos[StatueA].y,
            -- Position of StatueB.
            Bx = s.pos[StatueB].x,
            Bx' = s'.pos[StatueB].x,
            By = s.pos[StatueB].y,
            By' = s'.pos[StatueB].y,
            -- Displacement of Link.
            Ldx = Lx'.minus[Lx],
            Ldy = Ly'.minus[Ly],
            -- Displacement of StatueA (negated).
            Adx = Ax.minus[Ax'],
            Ady = Ay.minus[Ay'],
            -- Displacement of StatueB (not negated).
            Bdx = Bx'.minus[Bx],
            Bdy = By'.minus[By]
        {
            -- Link can move left, right, up, or down.
            Ldx + Ldy = 0 + 1 or Ldx + Ldy = 0 + -1
            (
                -- StatueA goes in the opposite direction, if possible.
                ((Adx = Ldx and Ady = Ldy)
                 or (Adx + Ady = 0
                     and no c: Coord | c.x = Ax.minus[Ldx] and c.y = Ay.minus[Ldy]))
                and
                -- StatueB goes in the same direction, if possible.
                ((Bdx = Ldx and Bdy = Ldy)
                 or (Bdx + Bdy = 0
                     and no c: Coord | c.x = Bx.plus[Ldx] and c.y = By.plus[Ldy]))
            ) or (
                -- Or, the statues don't move because they bang into each other.
                Adx + Ady + Bdx + Bdy = 0
                and Ax.minus[Ldx] = Bx.plus[Ldx]
                and Ay.minus[Ldy] = By.plus[Ldy]
            )
        }
    }
}

-- Solve the puzzle.
run { solved[last] } for 3 Int, exactly 21 Coord, exactly 13 State
