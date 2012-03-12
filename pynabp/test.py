import numpy
import pickle

_test_results = None


def init(image_size):
    global _test_results
    _test_results = numpy.zeros((image_size, image_size))


def update(x, y, val):
    global _test_results
    _test_results[x, y] += val


def finish():
    global _test_results
    with open('build/results.pcl', 'w') as results_file:
        pickle.dump(_test_results, results_file)
