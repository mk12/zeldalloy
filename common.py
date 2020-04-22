import contextlib
import re
import sys


def parse_instance(stream):
    """Parse output from the Txt tab in an Alloy instance."""
    instance = {}
    for line in stream:
        line = line.strip()
        m = re.fullmatch(r'([a-zA-Z0-9$/<:]+)={(.*)}', line)
        if not m:
            continue
        name = m.group(1)
        vals = (
            (parse_atom(a) for a in v.strip().split("->") if a)
            for v in m.group(2).split(",")
        )
        instance[name] = build_relation(vals)
    return instance


def parse_atom(string):
    """Parse an atom from a string representation."""
    if re.fullmatch(r'-?[0-9]+', string):
        return int(string)
    if "$" not in string:
        return string
    name, number = string.split("$", 1)
    return name, int(number)


def build_relation(vals):
    """Build a nested dict/set from a list of tuples in a relation."""
    root = {}
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


def the(node):
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
