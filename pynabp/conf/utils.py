from pynabp.utils import bin_width_of_dec, dec_repr
from pynabp.fixed_point_arith import FixedPoint
from pynabp.conf.ramp_filter import ramp_filter

from skimage.transform import radon
from pynabp.phantom import phantom

import numpy


def import_conf(path):
    """Import a configuration file from path

    By default the imported file would be 'default.naconfig'.
    """
    globs = {}
    execfile(path, globs)
    return globs['config']


def center(val):
    return int((val - 1) / 2)


def filter_coefs(order, function):
    if callable(function):
        return function(order)
    else:
        return ramp_filter(order)


def angle_defines(precision, angle_step_size):
    if precision != 0:
        raise NotImplementedError(
                'Current verilog implementation does not support angle '
                'precisions')

    fixed = FixedPoint(bin_width_of_dec(180), precision)

    if angle_step_size is None:
        angle_step_size = fixed.precision()
    angle_step = fixed.verilog_repr(angle_step_size)

    defines = {
            'tAngle': fixed,
            'kAngleStep': angle_step,
            'kNoOfAngles': int(180.0 / angle_step_size),
            # backwards compatibility
            'kAngleLength': fixed.width(),
            }

    # mode switch angles
    defines.update({
            'kAngle' + str(angle):
            str(fixed.width()) + "'b" + fixed.bin_repr_of_value(angle)
            for angle in range(45, 136, 45)
            })

    return defines


def sinogram(
        image_size, projection_line_size, angle_step_size, no_of_angles):
    # phantom to be projection size / sqrt(2)
    ph = phantom(int(projection_line_size / numpy.sqrt(2)))

    # produce projections by radon transform (skimage.transform.radon
    # resize radon transformed sinogram to projection line size, i.e. multiply
    # by sqrt(2))
    # FIXME: this is bad, because the sinogram RAM could be offsetted
    sg = radon(ph, numpy.arange(0, 180, angle_step_size))

    # prepare sg as contents of the RAM
    addr_len = bin_width_of_dec(no_of_angles) + \
            bin_width_of_dec(projection_line_size)
    sg_ram = {
            dec_repr(a * projection_line_size + s, addr_len):
            dec_repr(sg[s, a])
            for a in xrange(sg.shape(1))
            for s in xrange(sg.shape(0))}

    return sg_ram
