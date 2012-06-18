import sys
import pickle
import itertools
import numpy
from PIL import Image

from cat_py.phantom import phantom

with open(sys.argv[1]) as f:
    result = pickle.load(f)
    result -= result.min()
    result /= result.max()

size = result.shape[0]
actual = phantom(size)
actual -= actual.min()
actual /= actual.max()
Image.fromarray(255.0 * actual).show()

mse = 0
for (x, y) in itertools.product(xrange(size), xrange(size)):
    mse += (result[x, y] - actual[x, y]) ** 2

mse /= size ** 2

print mse
