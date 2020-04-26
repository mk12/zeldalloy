#!/usr/bin/env python3

import os, pathlib, sys

sys.path.append(os.path.relpath(pathlib.Path(__file__).resolve().parent.parent))

from common import CoordPuzzle, default_main


class MutohTiles(CoordPuzzle):

    x_range = -1, 1
    y_range = -1, 1

    coord_to_object = "colors"

    def object_char(self, obj):
        if obj == ("Red", 0):
            return "O"
        if obj == ("Blue", 0):
            return "X"


if __name__ == "__main__":
    default_main(MutohTiles)
