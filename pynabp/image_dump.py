import numpy
import pickle
from PIL import Image

_images = {}


def init(name, size):
    global _images
    _images[name] = numpy.zeros((size, size))


def update(name, x, y, val):
    global _images
    _images[name][x, y] += val


def dump(name):
    image = _images[name]
    # normalise values to range 0~255
    image -= image.min()
    image *= 255.0 / image.max()
    # show image
    i = Image.new('L', image.shape)
    for (x, y), val in numpy.ndenumerate(image):
        i.putpixel((x, y), val)
    i.save('build/%s.png' % name)
    i.show()
    # dump pickle file
    with open('build/%s.pcl' % name, 'w') as f:
        pickle.dump(image, f)
