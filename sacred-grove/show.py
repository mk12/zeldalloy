#!/usr/bin/env python3

import pathlib, os, sys
sys.path.append(os.path.relpath(pathlib.Path(__file__).resolve().parent.parent))

from common import CoordPuzzle, default_main


class SacredGrove(CoordPuzzle):

    x_range = -2, 2
    y_range = -3, 2

    object_to_coord = "pos"

    def object_char(self, obj):
        if obj == ("Link", 0):
            return "L"
        if obj == ("StatueA", 0):
            return "A"
        if obj == ("StatueB", 0):
            return "B"


if __name__ == "__main__":
    default_main(SacredGrove)
