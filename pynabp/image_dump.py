import numpy
from PIL import Image

_image = None
_name = None


def image(results):
    i = Image.new('L', _image.shape)
    for (x, y), val in numpy.ndenumerate(results):
        i.putpixel((x, y), val)
    return i


def init(name, size):
    global _image, _name
    _image = numpy.zeros((size, size))
    _name = name


def update(x, y, val):
    global _image
    _image[x, y] += val


def finish():
    global _image, _name
    # normalise values to range 0~255
    _image += _image.min()
    _image *= 255.0 / _image.max()
    # show image
    result_image = image(_image)
    result_image.save('build/%s.png' % _name)
    result_image.show()
