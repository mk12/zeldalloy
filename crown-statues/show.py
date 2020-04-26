#!/usr/bin/env python3

import os, pathlib, sys

sys.path.append(os.path.relpath(pathlib.Path(__file__).resolve().parent.parent))


from common import CoordPuzzle, default_main, the


class CrownStatues(CoordPuzzle):

    x_range = -5, 4
    y_range = -3, 2

    fake = {(0, 0): "OWL"}

    state_to_coord = "block"
    state_to_coord_atom = "BLOCK"
    object_to_coord = "pos"

    def setup(self):
        super().setup()
        self.colors = self.instance["this/Statue<:color"]

    def object_char(self, obj):
        if obj == "OWL":
            return "x"
        if obj == "BLOCK":
            return "o"
        if obj[0] == "Statue":
            # First [0] to get name from atom.
            # Second [0] to get the first letter of the color.
            return the(self.colors[obj])[0][0]


if __name__ == "__main__":
    default_main(CrownStatues)
