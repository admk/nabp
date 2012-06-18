import os
import math
import pickle
import numpy
from itertools import chain

from pynabp.utils import bin_width_of_dec_vals, bin_width_of_dec
from pynabp.fixed_point_arith import FixedPoint

from cat_py.phantom import phantom
from cat_py.parallel_beam import radon


def shift_lut_defines(shift_accu_precision):
    fp = FixedPoint(1, shift_accu_precision, value=0)

    @fp.verilog_repr_decorator
    def lookup(angle):
        if angle < 0 or angle >= 180:
            raise ValueError('Angle must be within range 0-180')
        if (0 <= angle and angle < 45) or (135 <= angle and angle < 180):
            return abs(math.tan(math.radians(angle)))
        else:
            return abs(1 / math.tan(math.radians(angle)))
    defines = {
            'tShiftAccuBase': fp,
            'lutShiftAccuBaseFunc': lookup,
            }
    return defines


def map_lut_defines(conf):
    defines = _map_accu_part_defines(conf)
    defines.update(_map_accu_base_defines(conf))
    defines.update(_map_accu_init_defines(conf))
    return defines


def _map_accu_part_lookup(conf):
    pe_last = conf['partition_scheme']['partitions'][-1]
    pe_size = conf['partition_scheme']['size']
    i_size = conf['image_size']
    i_center = conf['image_center']
    p_center = conf['projection_line_center']

    def lookup(angle):
        sin_val = math.sin(math.radians(angle))
        cos_val = math.cos(math.radians(angle))
        if (0 <= angle and angle < 45):
            val = pe_last * cos_val
        elif (45 <= angle and angle < 90):
            val = - pe_last * sin_val
        elif (90 <= angle and angle < 135):
            val = - (pe_last + pe_size - 1) * sin_val + (i_size - 1) * cos_val
        elif (135 <= angle and angle < 180):
            val = (pe_last + pe_size - 1) * cos_val - (i_size - 1) * sin_val
        else:
            raise RuntimeError('Invalid angle encountered')
        return val + i_center * sin_val - i_center * cos_val + p_center

    return lookup


def _map_accu_base_lookup(angle):
    if ((0 <= angle and angle < 45) or
        (135 <= angle and angle < 180)):
        return -math.cos(math.radians(angle))
    elif (45 <= angle and angle < 135):
        return math.sin(math.radians(angle))
    else:
        raise RuntimeError('Invalid angle encountered')


def _map_accu_part_defines(conf):
    """Define *MapAccuPart constants
    """
    # generate lookup table
    lut_map_accu_part = map(_map_accu_part_lookup(conf), xrange(0, 180))

    # evaluate bit lengths for the lookup table values
    accu_part_int_len, accu_part_signed = bin_width_of_dec_vals(
            lut_map_accu_part)

    defines = {
            'lutMapAccuPart': lut_map_accu_part,
            'tLUTMapAccuPart': FixedPoint(
                accu_part_int_len, conf['kMapAccuPartPrecision'],
                accu_part_signed),
            'tMapAccuPart': FixedPoint(
                accu_part_int_len, conf['kMapAccuPrecision'],
                accu_part_signed)
            }
    return defines


def _map_accu_base_defines(conf):
    """Define *MapAccuBase constants
    """
    defines = {
            'tMapAccuBase': FixedPoint(1, conf['kMapAccuPrecision'], True),
            'lutMapAccuBase': map(_map_accu_base_lookup, xrange(0, 180))
            }
    return defines


def _map_accu_init_defines(conf):
    """Define *MapAccuInit constants
    """
    # range required for accu_init
    def accu_init_vals(angle):
        part_val = _map_accu_part_lookup(conf)(angle)
        line_val = -conf['partition_scheme']['size'] * \
                _map_accu_base_lookup(angle)
        if angle >= 90:
            line_val = -line_val
        return (part_val, part_val + line_val)

    def accu_init_range():
        accu_init_range_list = map(accu_init_vals, xrange(0, 180))
        accu_init_range_list = list(chain.from_iterable(accu_init_range_list))
        return bin_width_of_dec_vals(accu_init_range_list)

    # range for accumulated value
    def accu_vals(angle):
        scan_val = conf['image_size'] * _map_accu_base_lookup(angle)
        val_0, val_1 = accu_init_vals(angle)
        return (val_0, val_1, val_0 + scan_val, val_1 + scan_val)

    def accu_range():
        accu_range_list = map(accu_vals, xrange(0, 180))
        accu_range_list = list(chain.from_iterable(accu_range_list))
        return bin_width_of_dec_vals(accu_range_list)

    init_len, init_signed = accu_init_range()
    accu_len, accu_signed = accu_range()
    accu_prec = conf['kMapAccuPrecision']
    defines = {
            'tMapAccuInit': FixedPoint(init_len, accu_prec, init_signed),
            'tMapAccu': FixedPoint(accu_len, accu_prec, init_signed)
            }
    return defines


def fir(b, x):
    y = [0.0] * len(x)
    for j in range(len(x)):
        for i in range(len(b))[::-1]:
            if j - i < 0:
                continue
            y[j] += b[i] * x[j - i]
    return y

_projection_line_size = None
_lutSinogram = None
_tSinogram = None
_tSinogramBase = None


def init_sinogram_defines(
        image_size=None,
        projection_line_size=None,
        angle_step_size=None,
        no_of_angles=None,
        data_length=None,
        fir_coefs=None):
    """Initialise sinogram LUT and definitions"""

    global _projection_line_size, _lutSinogram, _tSinogram, _tSinogramBase

    file_name = 'build/cached_sinogram_defines.pcl'

    # try to load from cache
    if os.path.exists(file_name):
        with open(file_name) as f:
            _image_size, _projection_line_size, _angle_step_size, \
            _no_of_angles, _data_length, _fir_coefs, \
            _lutSinogram, _tSinogram, _tSinogramBase = \
                    pickle.load(f)
        if image_size == None:
            # loading from cache
            return
        if image_size == _image_size and \
           projection_line_size == _projection_line_size and \
           angle_step_size == _angle_step_size and \
           no_of_angles == _no_of_angles and \
           data_length == _data_length and \
           fir_coefs == _fir_coefs:
               return

    # not cached, create a phantom image
    ph = phantom(image_size)

    # produce projections by radon transform (skimage.transform.radon
    # resize radon transformed sinogram to projection line size, i.e. multiply
    # by sqrt(2))
    sg_ram = radon(ph, numpy.arange(0, 180, angle_step_size))
    # filtering
    # FIXME validate the strange choice of the group delay
    group_delay = int(len(fir_coefs) / 2) + 2
    filtered_sg_ram = numpy.zeros(sg_ram.shape)
    for angle in xrange(sg_ram.shape[1]):
        projection_line = list(sg_ram[:, angle])
        projection_line.extend([0.0] * group_delay)
        filtered_projection_line = fir(fir_coefs, projection_line)
        filtered_projection_line = filtered_projection_line[group_delay:]
        filtered_sg_ram[:, angle] = filtered_projection_line

    # auto determine the data value representation
    int_width = bin_width_of_dec(numpy.max(filtered_sg_ram)) + 1
    frac_width = data_length - int_width
    sg_fixed_point = FixedPoint(int_width, frac_width, False)

    _projection_line_size = projection_line_size
    _lutSinogram = filtered_sg_ram
    _tSinogram = sg_fixed_point
    _tSinogramBase = 2 ** _tSinogram.fractional_width

    # dump defines to cache
    with open(file_name, 'w') as f:
        pickle.dump(
                (image_size, projection_line_size, angle_step_size, \
                    no_of_angles, data_length, fir_coefs, \
                    _lutSinogram, _tSinogram, _tSinogramBase), f)


def sinogram_defines():
    return {'tSinogram': _tSinogram, }


def sinogram_lookup(address=None, pr_verify=False, angle=None, point=None):
    # addressing
    if angle is None:
        angle = address / _projection_line_size
    if point is None:
        point = address % _projection_line_size
    if pr_verify:
        return point

    # linear interpolation
    point *= _lutSinogram.shape[0] / _projection_line_size
    interpolate_factor = point - math.floor(point)
    floor_val = _lutSinogram[math.floor(point), angle]
    ceil_val = _lutSinogram[math.ceil(point), angle]
    val = floor_val * (1 - interpolate_factor) + ceil_val * interpolate_factor

    return int(round(val * _tSinogramBase))
