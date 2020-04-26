#!/usr/bin/env python3

import os, pathlib, sys

sys.path.append(os.path.relpath(pathlib.Path(__file__).resolve().parent.parent))

from common import CoordPuzzle, default_main


class SnowpeakBlocks(CoordPuzzle):

    x_range = -2, 2
    y_range = -3, 2

    object_to_coord = "pos"
    static_to_coord = "Obstacle<:pos"

    def object_char(self, obj):
        if obj[0] == "Block":
            return obj[1]
        if obj[0] == "Obstacle":
            return "o"


if __name__ == "__main__":
    default_main(SnowpeakBlocks)
