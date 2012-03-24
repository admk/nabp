import numpy
from PIL import Image

_test_results = None


def image(results):
    i = Image.new('L', _test_results.shape)
    for (x, y), val in numpy.ndenumerate(results):
        i.putpixel((x, y), val)
    return i


def init(image_size):
    global _test_results
    _test_results = numpy.zeros((image_size, image_size))


def update(x, y, val):
    global _test_results
    try:
        _test_results[x, y] = val
    except:
        pass


def finish():
    global _test_results
    # normalise values to range 0~255
    _test_results += _test_results.min()
    _test_results *= 255.0 / _test_results.max()
    # show image
    result_image = image(_test_results)
    result_image.save('build/result.png')
    result_image.show()
