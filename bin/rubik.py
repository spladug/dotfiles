#!/usr/bin/python
"""
I'm trying to solve the top level of a rubik cube.
A lot of this code is scientist code, and won't make sense.
"""

import numpy
from numpy import zeros, bmat, identity

# Don't really know how to describe the transforms in words.
# In this representation, + means correctly orientated, - means flipped.
# If I start in +y -w +g -r, this will transform it to +y +r -w -g.
# (edge pieces going clockwise around the top).
# Note that rot3 rot3 rot3 = identity.

rot3_edges = numpy.array([
    [1,0,0,0],
    [0,0,0,-1],
    [0,1,0,0],
    [0,0,-1,0]])

# Expect lots of floating point errors here.
# Computationally, it would be easier if I could redefine matrix multiplication
# to be additive modulo 3. Maybe I should be using sympy for this, if it does matrices.
r = numpy.exp(2j * numpy.pi / 3)
l = - numpy.exp(2j * numpy.pi / 3)

def round(m):
    for value in [0, 1, r, l]:
        absdiff = numpy.abs(m - value)
        m[absdiff < 0.5] = value
    return m

# I think I wrote it down wrong (inverted == transposed)
rot3_corners_as_written = numpy.array([
    [0,1,0,0],
    [r,0,0,0],
    [0,0,0,l],
    [0,0,1,0]])

rot3_corners = numpy.array([
    [0,r,0,0],
    [1,0,0,0],
    [0,0,0,1],
    [0,0,l,0]])

rot3 = numpy.bmat([
    [rot3_edges, zeros((4,4))],
    [zeros((4,4)), rot3_corners]])

# Simply twist the top.
turn = numpy.roll(numpy.identity(4), 1, 1)
turn = numpy.bmat([
    [turn, zeros((4,4))],
    [zeros((4,4)), turn]])

# Target transform

target_corners = numpy.array([
    [1,0,0,0],
    [0,0,0,r],
    [0,1,0,0],
    [0,0,l,0]]).T

target = bmat([
    [identity(4), zeros((4,4))],
    [zeros((4,4)), target_corners]])

# Actually, screw it: let's get the bits in the right place first.
rot3 = abs(rot3)
target = abs(target)

def search(found, chain, depth, cb):
    start = chain[-1]
    if depth <= 0:
        return found
    if found.get(str(start), [0,[]])[0] >= depth:
        return found
    found[str(start)] = [depth, chain]
    search(found, [chain[0]+'r'] + chain[1:] + [round(numpy.dot(start, rot3))], depth - 6, cb)
    search(found, [chain[0]+'t'] + chain[1:] + [round(numpy.dot(start, turn))], depth - 1, cb)
    return found

chains = search({}, ['', numpy.identity(8)], 40, str)

for depth, chain in chains.values():
    if (chain[-1][:4, :4] == identity(4)).all():
        print depth, chain[0]

    if chain[0] == 'rrtttrrttt':
        print chain[-1]






