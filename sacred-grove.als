open util/ordering[State]

-- Initial configuration:
--
--     1 2 3 4 5
--   +----------    Legend
-- 1 | x x . x x    ======
-- 2 | x x A x x    . = empty
-- 3 | x x x x x    x = square
-- 4 | . x L x .    L = Link
-- 5 | . x x x .    A = StatueA
-- 6 | . . B . .    B = StatueB

-- There are 3 objects: Link and the two statues.
abstract sig Object {}
one sig Link, StatueA, StatueB extends Object {}

-- A coordinate is an (x,y) pair on the grid.
-- The x-axis is horizontal and the y-axis is vertical.
sig Coord {
	x, y: Int
}{
    -- Restrict to valid coordinates.
    x >= 1 and x <= 5
    y >= 1 and y <= 6
    not (x = 3 and y = 1)
    not ((x = 1 or x = 5) and y >= 4)
    not ((x = 2 or x = 4) and y = 6)
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
    first.pos[Link].x = 3 and first.pos[Link].y = 4
	first.pos[StatueA].x = 3 and first.pos[StatueA].y = 2
	first.pos[StatueB].x = 3 and first.pos[StatueB].y = 6
}

-- Define the solution criteria.
pred solved[s: State] {
    -- Both are on the second row.
    s.pos[StatueA].y = 2 and s.pos[StatueB].y = 2
    -- They are on the 2nd and 4th columns (we don't care which).
    -- Note: 2 + 4 means the set {2, 4}, not the number 6.
    (s.pos[StatueA].x + s.pos[StatueB].x) = 2 + 4
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
            (Ldx = -1 and Ldy = 0) or (Ldx = 1 and Ldy = 0) or (Ldx = 0 and Ldy = -1) or (Ldx = 0 and Ldy = 1)
            (
                -- StatueA goes in the opposite direction, if possible.
                ((Adx = Ldx and Ady = Ldy) or (Adx = 0 and Ady = 0 and no c: Coord | c.x = Ax.minus[Ldx] and c.y = Ay.minus[Ldy]))
                -- StatueB goes in the same direction, if possible.
                and ((Bdx = Ldx and Bdy = Ldy) or (Bdx = 0 and Bdy = 0 and no c: Coord | c.x = Bx.plus[Ldx] and c.y = By.plus[Ldy]))
            ) or (
                -- Or, the statues don't move because they bang into each other.
                Adx = 0 and Ady = 0 and Bdx = 0 and Bdy = 0
                and Ax.minus[Ldx] = Bx.plus[Ldx]
                and Ay.minus[Ldy] = By.plus[Ldy]
            )
        }
    }
}

run { solved[last] } for 4 Int, exactly 21 Coord, exactly 13 State
