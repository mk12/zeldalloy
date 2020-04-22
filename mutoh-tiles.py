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
            colors = self.instance["this/State<:colors"][s]
            index = s[1] + 1  # convert to 1-based
            state = {
                self.coords[pos]: the(color)
                for pos, color in colors.items()
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
        for y in range(-1, 2):
            for x in range(-1, 2):
                color = state[(x, y)]
                if color == ("Red", 0):
                    p("O")
                elif color == ("Blue", 0):
                    p("X")
                if x != 1:
                    p(" ")
            print()


if __name__ == "__main__":
    main()
