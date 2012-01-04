import math
import numpy as np
import utils
from partition import partition
from ramp_filter import ramp_filter

global _conf
_conf = None

def conf(
        projection_data=None, no_of_partitions=20, fir_order=64, **kwargs):
    global _conf
    if _conf:
        return _conf
    _conf = {}
    # algorithm specific confs
    _conf['projection_data'] = projection_data
    if projection_data:
        _conf['projection_line_size'] = np.shape(projection_data)[1]
        _conf['projection_angles_size'] = np.shape(projection_data)[0]
    else:
        # FIXME projection_line_size
        # odd size for integer-valued center,
        # or use (x).(1) fixed precision
        _conf['projection_line_size'] = 367
        _conf['projection_angles_size'] = 180
    _conf['projection_angle_step'] = 180 / _conf['projection_angles_size']
    _conf['projection_line_center'] = (_conf['projection_line_size'] - 1) / 2
    _conf['image_size'] = math.ceil(
            _conf['projection_line_size'] / math.sqrt(2))
    half_image_size = _conf['image_size'] / 2
    if half_image_size == math.floor(half_image_size):
        _conf['image_size'] += 1
    _conf['image_center'] = (_conf['image_size'] - 1) / 2
    _conf['projection_domain_pe_interpolate'] = False
    _conf['projection_domain_stream_interpolate'] = False
    _conf['projection_domain_stream_pipeline_offset'] = -1
    if _conf['projection_domain_stream_interpolate']:
        _conf['projection_domain_stream_pipeline_offset'] -= 1
    _conf['partition_scheme'] = partition(
            _conf['image_size'], no_of_partitions)
    _conf['ramp_filter_coefs'] = ramp_filter(fir_order)
    # architecture specific confs
    _conf['kAngleLength'] = utils.bin_width_of_dec(180)
    for angle in range(45, 136, 45):
        key = 'kAngle' + str(angle)
        _conf[key] = str(_conf['kAngleLength']) + '\'b'
        _conf[key] += utils.dec2bin(angle, _conf['kAngleLength'])
    _conf['kShiftAccuPrecision'] = 8
    _conf['kMapAccuPrecision'] = 8
    _conf['kSEvalPrecision'] = 4
    # optional arguments
    _conf.update(kwargs)
    return _conf
