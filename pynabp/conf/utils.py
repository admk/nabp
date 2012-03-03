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

def center(val):
    return int((val - 1) / 2)

def filter_coefs(order, function):
    if callable(function):
        return function(order)
    else:
        return ramp_filter(order)

def angle_defines(precision):
    if precision != 0:
        raise NotImplementedError(
                'Current verilog implementation does not support angle '
                'precisions')

    fixed = FixedPoint(bin_width_of_dec(180), precision)
    defines = {
            'tAngle': fixed,
            # backwards compatibility
            'kAngleLength': fixed.width
            }
    defines.update(**{
            'kAngle' + str(angle): fixed.bin_repr_of_value(angle)
            for angle in range(45, 136, 45)
            })
    return defines

