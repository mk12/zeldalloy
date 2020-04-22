#!/usr/bin/env python3

import argparse

from common import alternate_screen, clear_screen, the, parse_instance


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--interactive", action="store_true")
    parser.add_argument("file", help="file containing Alloy instance txt")
    args = parser.parse_args()
    with open(args.file) as f:
        puzzle = Puzzle(parse_instance(f))
    if args.interactive:
        puzzle.interactive()
    else:
        puzzle.dump()


class Puzzle:

    def __init__(self, instance):
        self.instance = instance
        x_rel = instance["this/Coord<:x"]
        y_rel = instance["this/Coord<:y"]
        self.coords = {
            c: (the(x_rel[c]), the(y_rel[c]))
            for c in instance["this/Coord"]
        }
        self.all_coords = set(self.coords.values())

    def states(self):
        for s in sorted(self.instance["this/State"]):
            positions = self.instance["this/State<:pos"][s]
            index = s[1] + 1  # convert to 1-based
            state = {
                self.coords[the(pos)]: obj
                for obj, pos in positions.items()
            }
            yield index, state

    def dump(self):
        for index, state in self.states():
            print(f"{'-' * 80}\nState {index}\n")
            self.print_state(state)
            print()

    def interactive(self):
        with alternate_screen():
            for index, state in self.states():
                print(f"State {index}\n")
                self.print_state(state)
                input()
                clear_screen()

    def print_state(self, state):
        p = lambda s: print(s, end="")
        for y in range(-3, 3):
            for x in range(-2, 3):
                if (x, y) in state:
                    obj = state[(x, y)]
                    if obj == ("Link", 0):
                        p("L")
                    elif obj == ("StatueA", 0):
                        p("A")
                    elif obj == ("StatueB", 0):
                        p("B")
                elif (x, y) in self.all_coords:
                    p(".")
                else:
                    p(" ")
                if x != 2:
                    p(" ")
            print()


if __name__ == "__main__":
    main()
