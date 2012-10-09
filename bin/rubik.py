#!/usr/bin/python
"""
I'm trying to solve the top level of a rubik cube.
A lot of this code is scientist code, and won't make sense.
"""

import numpy

# Don't really know how to describe the transforms in words.
# In this representation, + means correctly orientated, - means flipped.
# If I start in +y -w +g -r, this will transform it to +y +r -w -g.
# (edge pieces going clockwise around the top).
# Note that rot3 rot3 rot3 = identity.

rot3 = numpy.array([
    [1,0,0,0],
    [0,0,0,-1],
    [0,1,0,0],
    [0,0,-1,0]])

# Simply twist the top.
turn = numpy.roll(numpy.identity(4), 1, 1)


def search(found, chain, depth, cb):
    start = chain[-1]
    if depth <= 0:
        return
    if found.get(str(start), [0,[]]) >= depth:
        return
    found[str(start)] = [depth, chain]
    cb(chain)
    search(found, chain + [numpy.dot(start, rot3)], depth - 6, cb)
    search(found, chain + [numpy.dot(start, turn)], depth - 1, cb)
    return found

chains = search({}, [numpy.identity(4)], 50, str)






