open util/ordering[State]

-- Puzzle layout:
--
--     -2 -1  0 +1 +2
--    +--------------    Legend
-- -3 | .  .  .  .  .    ========
-- -2 | .  .  .  .  .    . = ice
-- -1 | .  .  .  .  .
--  0 | .  .  .  .  .
-- +1 | .  .  .  .
-- +2 |       .

-- Each puzzle has a set of blocks.
sig Block {}

-- Some puzzles have obstacles.
-- We model these explicitly instead of having gaps in the
-- coordinates, because it makes the rules easier to express.
sig Obstacle {
    pos: Coord
}

-- A coordinate is an (x,y) pair on the grid.
-- The x-axis is horizontal and the y-axis is vertical.
sig Coord {
    x, y: Int
}{
    -- Restrict to valid coordinates.
    x >= -2 and x <= 2
    y >= -3 and y <= 2
    not (x = 2 and y = 1)
    not (x != 0 and y = 2)
}

-- There are no duplicate coordinates.
fact {
    no c, c': Coord | c != c' and c.x = c'.x and c.y = c'.y
}

-- Each state maps the blocks to coordinates.
sig State {
    -- `Object lone ->` means no two blocks are at the same coordinate.
    -- `-> one Coord` means each block occupies exactly one coordinate.
    pos: Block lone -> one Coord
}

-- Configure the first puzzle.
--
--     -2 -1  0 +1 +2
--    +--------------    Legend
-- -3 | o  .  .  .  B    ========
-- -2 | .  .  .  .  .    . = ice
-- -1 | .  .  o  .  .    x = goal
--  0 | .  .  .  .  .    B = block
-- +1 | B  .  .  .       o = obstacle
-- +2 |       x
--
pred puzzle1 {
    -- Obstacle positions.
    some o: Obstacle | o.pos.x = -2 and o.pos.y = -3
    some o: Obstacle | o.pos.x = 0 and o.pos.y = -1
    -- Initial block positions.
    some b: Block | first.pos[b].x = 2 and first.pos[b].y = -3
    some b: Block | first.pos[b].x = -2 and first.pos[b].y = 1
    -- Solution: the switch is pressed.
    some b: Block | last.pos[b].x = 0 and last.pos[b].y = 2
}

-- Configure the second puzzle.
--
--     -2 -1  0 +1 +2
--    +--------------    Legend
-- -3 | B  .  .  .  .    ========
-- -2 | .  .  .  .  .    . = ice
-- -1 | .  .  x  .  .    x = goal
--  0 | .  .  .  .  .    B = block
-- +1 | .  .  .  B
-- +2 |      B/x
--
pred puzzle2 {
    -- Initial block positions.
    some b: Block | first.pos[b].x = -2 and first.pos[b].y = -3
    some b: Block | first.pos[b].x = 1 and first.pos[b].y = 1
    some b: Block | first.pos[b].x = 0 and first.pos[b].y = 2
    -- Solution: both switches are pressed.
    some b: Block | last.pos[b].x = 0 and last.pos[b].y = -1
    some b: Block | last.pos[b].x = 0 and last.pos[b].y = 2
}

-- Helper predicate to say x is between a (exclusive) and b (inclusive).
pred between[x, a, b: Int] {
    x != a
    x >= min[a + b]
    x <= max[a + b]
}

-- Helper function for combining block and obstacle positions.
fun impediments[s: State]: set Coord {
    Obstacle.pos + s.pos[Block]
}

-- Specify the rules of the puzzle.
fact {
    all s: State, s': s.next {
        -- Link pushes a block.
        some b: Block {
            -- No other block moves.
            all b': Block - b | s'.pos[b'] = s.pos[b']
            let
                -- Before position.
                sx = s.pos[b].x,
                sy = s.pos[b].y,
                -- After position.
                sx' = s'.pos[b].x,
                sy' = s'.pos[b].y,
                -- Normalized displacement.
                nx = signum[sx'.minus[sx]],
                ny = signum[sy'.minus[sy]],
                -- Impediments (things a block can be stopped by).
                imps = impediments[s]
            {
                -- The block cannot stay still.
                nx + ny != 0
                -- The block cannot move diagonally.
                0 in nx + ny
                -- If moving along the x-axis:
                nx != 0 implies all c: Coord | c.y = sy => {
                    -- Nothing was in the block's way.
                    between[c.x, sx, sx'] => c not in imps
                    -- The block cannot go any further.
                    c.x = sx'.plus[nx] => c in imps
                }
                -- If moving along the y-axis:
                ny != 0 implies all c: Coord | c.x = sx => {
                    -- Nothing was in the block's way.
                    between[c.y, sy, sy'] => c not in imps
                    -- The block cannot go any further.
                    c.y = sy'.plus[ny] => c in imps
                }
            }
        }
    }
}

-- Solve the puzzles.
-- Note: Although [-3,2] fits in 3 bits, we need 4 bits for the
-- "normalized displacement" subtractions (can reach 2 - (-3) = 5).
run { puzzle1 } for 4 Int, exactly 25 Coord, exactly 2 Block, exactly 2 Obstacle, exactly 6 State
run { puzzle2 } for 4 Int, exactly 25 Coord, exactly 3 Block, exactly 0 Obstacle, exactly 11 State
