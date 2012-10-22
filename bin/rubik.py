#!/usr/bin/python
"""
I'm trying to solve the top level of a rubik cube.
A lot of this code is scientist code, and won't make sense.
"""

import threading
import numpy
from numpy import zeros, bmat, identity, matrix

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

inv_rot3 = matrix(rot3) ** -1

# Simply twist the top.
turn = numpy.roll(numpy.identity(4), 1, 1)
turn = numpy.bmat([
    [turn, zeros((4,4))],
    [zeros((4,4)), turn]])
inv_turn = turn.T

# Target transform

target_corners = numpy.array([
    [1,0,0,0],
    [0,0,0,r],
    [0,1,0,0],
    [0,0,l,0]]).T

target = bmat([
    [identity(4), zeros((4,4))],
    [zeros((4,4)), target_corners]])



import Queue

# (cost, (path, transform))
def add_cost(path, transform, found):
    cost = 0
    cost += path.count('r') * 6
    cost += path.count('t') * 1

    if (abs(transform)[:4, :4] == identity(4)).all():
        cost -= 25
        path = path + 'I'

    if found.get(str(transform), (numpy.Inf, ('',[])))[0] <= cost:
        return None
    found[str(transform)] = (cost, path, transform)

    return (cost, path, transform)

def clean_queue(queue):
    queue.mutex.acquire()
    queue.queue = queue.queue[:len(queue.queue)//2]
    queue.mutex.release()


def best_first_search(queue, cost_function, iterations, found):
    for i in xrange(iterations):
        try:
            cost, path, transform = queue.get_nowait()
        except Queue.Empty:
            break

        try:
            for item in generate_children(path, transform, found):
                if item is not None:
                    queue.put_nowait(item)
        except Queue.Full:
            clean_queue(queue)
            # dump it back into the queue so that it gets re-processed
            queue.put_nowait((cost, path, transform))


def search(iterations, queue=None, found=None):
    if found is None:
        found = {}
    if queue is None:
        queue = Queue.PriorityQueue(maxsize=100)
        queue.put_nowait(add_cost("", identity(8), found))

    threads = [threading.Thread(target=best_first_search, args=(queue, add_cost, iterations//4, found))
            for i in xrange(4)]

    for t in threads:
        t.start()

    for t in threads:
        t.join()

    return queue, found

def generate_children(path, transform, found):
    yield add_cost(path + "r", round(numpy.dot(transform, rot3)), found)
    yield add_cost(path + "r'", round(numpy.dot(transform, inv_rot3)), found)
    yield add_cost(path + "t", round(numpy.dot(transform, turn)), found)
    yield add_cost(path + "t'", round(numpy.dot(transform, inv_turn)), found)


queue, chains = search(500)
identities = {}

for cost, path, transform in sorted(chains.values()):
    if (abs(transform[4:, 4:]) == numpy.array(
      [[1,0,0,0],
       [0,0,0,1],
       [0,1,0,0],
       [0,0,1,0]])).all(): # and \
     #(abs(chain[-1][4:, 4:]) == numpy.roll(numpy.identity(4), 2, 1)).all():
        print cost, path
        print abs(transform[4:, 4:])
        identities[path] = cost, path, transform





