import os

from pynabp.utils import bin_width_of_dec
from pynabp.fixed_point_arith import FixedPoint
from pynabp.conf.ramp_filter import ramp_filter


def import_conf(path):
    """Import a configuration file from path

    By default the imported file would be 'default.naconfig'.
    """
    globs = {}
    execfile(path, globs)
    return globs['config']


def export_conf(path, conf):
    """Export a configuration dictionary to path"""
    directory = os.path.split(path)[0]
    if not os.path.exists(directory):
        os.mkdir(directory)
    with open(path, 'w') as f:
        f.write('config = \\\n' + repr(conf))


def recursive_update_dict(original_dict, update_dict):
    """Update a dictionary recursively"""
    new_dict = dict(original_dict)
    for k, v in update_dict.iteritems():
        if type(v) is dict:
            new_dict[k] = recursive_update_dict(original_dict[k], v)
        else:
            new_dict[k] = v
    return new_dict


def center(val):
    return (val - 1) / 2.0


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
            'angle_step_size': angle_step_size,
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
