"""Common code for all puzzle scripts."""

from __future__ import annotations

import argparse
import contextlib
import re
from abc import ABC, abstractmethod
from typing import (
    Any,
    Dict,
    Iterable,
    Iterator,
    Set,
    TextIO,
    Tuple,
    Type,
    Union,
)

# Either an integer (for the Int set) or an atom like Foo or Foo$0.
Atom = Union[int, str, Tuple[str, int]]

# An n-ary relation represented as a nested dictionary with sets as leaves.
# This is really a recursive type: Any should be Relation.
Relation = Union[Set[Atom], Dict[Atom, Any]]

# A group of named sets/relations.
Instance = Dict[str, Relation]


def parse_instance(stream: TextIO) -> Instance:
    """Parse output from the Txt tab in an Alloy instance."""
    instance = {}
    for line in stream:
        line = line.strip()
        m = re.fullmatch(r"([a-zA-Z0-9$/<:]+)={(.*)}", line)
        if not m:
            continue
        name = m.group(1)
        vals = (
            (parse_atom(a) for a in v.strip().split("->") if a)
            for v in m.group(2).split(",")
        )
        instance[name] = build_relation(vals)
    return instance


def parse_atom(string: str) -> Atom:
    """Parse an atom from a string representation."""
    if re.fullmatch(r"-?[0-9]+", string):
        return int(string)
    if "$" not in string:
        return string
    name, number = string.split("$", 1)
    return name, int(number)


def build_relation(vals: Iterable[Iterable[Atom]]) -> Relation:
    """Build a nested dict/set from a list of tuples in a relation."""
    root: Dict[Atom, Any] = {}
    for v in vals:
        parent = root
        for x in v:
            if x not in parent:
                parent[x] = {}
            parent = parent[x]

    def setify(node):
        if all(v == {} for v in node.values()):
            return set(node)
        return {k: setify(v) for k, v in node.items()}

    return setify(root)


def the(node: Relation) -> Atom:
    """Return the element of a singleton set"""
    assert len(node) == 1
    return next(iter(node))


@contextlib.contextmanager
def alternate_screen():
    """Context manager that switches to the alternate terminal screen."""
    print("\x1b[?1049h", end="")
    try:
        yield
    finally:
        print("\x1b[?1049l", end="")


def clear_screen():
    """Clear the terminal screen."""
    print("\x1b[2J\x1b[H", end="")


def default_main(puzzle_class: Type[Puzzle]):
    """A default main function for puzzle scripts."""
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--interactive", action="store_true")
    parser.add_argument("file", help="file containing Alloy instance txt")
    args = parser.parse_args()
    with open(args.file) as f:
        puzzle = puzzle_class(parse_instance(f))
    if args.interactive:
        puzzle.interactive()
    else:
        puzzle.dump()


# Domain representation of a puzzle state.
State = Any


class Puzzle(ABC):

    """Generic puzzle.

    It assumes there is a signature called State.

    This class is responsible for parsing an Alloy instance of the puzzle
    solution and for printing it in various formats.
    """

    def __init__(self, instance: Instance):
        self.instance = instance
        self.num_states = len(self.instance["this/State"])
        self.setup()

    def setup(self):
        """Puzzle subclasses can perform setup here."""

    def states(self) -> Iterator[Tuple[int, State]]:
        """Yield (index, state) tuples in order."""
        for s in sorted(self.instance["this/State"]):
            assert isinstance(s, tuple)
            yield s[1], self.build_state(s)

    @abstractmethod
    def build_state(self, s: Atom) -> State:
        """Convert a State atom to a domain state object."""

    def dump(self):
        """Dump all states to stdout."""
        for index, state in self.states():
            print(f"{'-' * 80}\n{self.state_title(index)}\n")
            self.print_state(state)
            print()

    def interactive(self):
        """Print states interactively on the alternate screen."""
        try:
            with alternate_screen():
                for index, state in self.states():
                    clear_screen()
                    print(self.state_title(index), end="\n\n")
                    self.print_state(state)
                    input()
        except KeyboardInterrupt:
            pass

    def state_title(self, index: int) -> str:
        """Generate a title for a state index."""
        # Display as one-based number.
        title = f"State {index + 1}"
        if index == 0:
            return f"{title} (initial)"
        if index == self.num_states - 1:
            return f"{title} (final)"
        return title

    @abstractmethod
    def print_state(self, state: State):
        """Print an individual state to stdout."""


class CoordPuzzle(Puzzle):

    """A puzzle based on coordinates.

    It assumes the following signatures/relations:

        sig Coord {
            x, y: Int
        }

        sig State {
            -- (1)
            NAME: lone OBJECT -> one Coord
            -- (2)
            NAME: Coord -> one OBJECT
        }

    The NAME is specified by object_to_cood for (1), or coord_to_object for (2).
    The OBJECT can be named anything.
    """

    # Inclusive ranges.
    x_range: Tuple[int, int]
    y_range: Tuple[int, int]

    # Only one of these should be set.
    object_to_coord: str = ""
    coord_to_object: str = ""

    # Optional.
    static_to_coord: str = ""

    def setup(self):
        coord = self.instance["this/Coord"]
        x = self.instance["this/Coord<:x"]
        y = self.instance["this/Coord<:y"]
        self.coords = {c: (the(x[c]), the(y[c])) for c in coord}
        self.all_xy = set(self.coords.values())
        self.static = {}
        if self.static_to_coord:
            obj_coord = self.instance[f"this/{self.static_to_coord}"]
            if obj_coord:
                self.static = {
                    self.coords[the(coord)]: obj for obj, coord in obj_coord.items()
                }

    def build_state(self, s: Atom) -> State:
        if self.object_to_coord:
            state_obj_coord = self.instance[f"this/State<:{self.object_to_coord}"]
            assert isinstance(state_obj_coord, dict)
            obj_coord = state_obj_coord[s]
            assert isinstance(obj_coord, dict)
            state = {self.coords[the(coord)]: obj for obj, coord in obj_coord.items()}
        elif self.coord_to_object:
            state_coord_obj = self.instance[f"this/State<:{self.coord_to_object}"]
            assert isinstance(state_coord_obj, dict)
            coord_obj = state_coord_obj[s]
            assert isinstance(coord_obj, dict)
            state = {self.coords[coord]: the(obj) for coord, obj in coord_obj.items()}
        else:
            assert False
        return {**self.static, **state}

    def print_state(self, state: State):
        p = lambda s: print(s, end="")
        ys = self.y_range[0], self.y_range[1] + 1
        xs = self.x_range[0], self.x_range[1] + 1
        for y in range(*ys):
            for x in range(*xs):
                if (x, y) in state:
                    obj = state[(x, y)]
                    p(self.object_char(obj))
                elif (x, y) in self.all_xy:
                    p(".")
                else:
                    p(" ")
                if x != 2:
                    p(" ")
            print()

    @abstractmethod
    def object_char(self, obj: Any) -> str:
        """Return the character to use for obj."""
