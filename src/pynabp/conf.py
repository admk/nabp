import math
import numpy as np
import utils
from itertools import chain
from partition import partition
from ramp_filter import ramp_filter
from fixed_point_arith import FixedPoint

global _conf
_conf = None

def conf(
        projection_data=None, no_of_partitions=20, fir_order=64, **kwargs):
    global _conf
    if _conf:
        return _conf
    _conf = dict(kwargs)
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
    _conf = map_lut_conf(_conf)
    _conf = shift_lut_conf(_conf)
    # re-update optional arguments
    _conf.update(kwargs)
    return _conf

def shift_lut_conf(config):
    config['kShiftAccuPrecision'] = 8
    fp = FixedPoint(
            1, config['kShiftAccuPrecision'], value=0)
    @fp.verilog_repr_decorator
    def lookup(angle):
        if angle < 0 or angle >= 180:
            raise ValueError('Angle must be within range 0-180')
        if (0 <= angle and angle < 45) or (135 <= angle and angle < 180):
            return abs(math.tan(math.radians(angle)))
        else:
            return abs(1 / math.tan(math.radians(angle)))
    config['tShiftAccuBase'] = fp
    config['lutShiftAccuBaseFunc'] = lookup
    return config

def map_lut_conf(config):
    # accumulated line_cnt_fact from state control
    config['kSEvalPrecision'] = 4
    pe_width_len = utils.bin_width_of_dec(conf()['partition_scheme']['size'])
    config['tLineCntFact'] = FixedPoint(
            pe_width_len, conf()['kSEvalPrecision'], True)
    # setup mapper accu_part
    config['kMapAccuPrecision'] = 8
    last_pe = config['partition_scheme']['partitions'][-1]
    i_size = config['image_size']
    def accu_part_lookup(angle):
        sin_val = math.sin(math.radians(angle))
        cos_val = math.cos(math.radians(angle))
        if (0 <= angle and angle < 45):
            val = last_pe * cos_val
        elif (45 <= angle and angle < 90):
            val = - last_pe * sin_val
        elif (90 <= angle and angle < 135):
            val = - last_pe * sin_val + i_size * cos_val
        elif (135 <= angle and angle < 180):
            val = last_pe * cos_val - i_size * sin_val
        else:
            raise RuntimeError('Invalid angle encountered')
        val += config['image_center'] * sin_val
        val -= config['image_center'] * cos_val
        val += config['projection_line_center']
        return val
    config['lutMapAccuPart'] = map(accu_part_lookup,
            utils.xfrange(0, 180, conf()['projection_angle_step']))
    accu_part_int_len, accu_part_signed = utils.bin_width_of_dec_vals(
            config['lutMapAccuPart'])
    config['tMapAccuPart'] = FixedPoint(
            accu_part_int_len, conf()['kSEvalPrecision'], accu_part_signed)
    # setup mapper accu_base
    def accu_base_lookup(angle):
        if ((0 <= angle and angle < 45) or
            (135 <= angle and angle < 180)):
            return -math.cos(math.radians(angle))
        elif (45 <= angle and angle < 135):
            return math.sin(math.radians(angle))
        else:
            raise RuntimeError('Invalid angle encountered')
    config['tMapAccuBase'] = FixedPoint(
            1, config['kMapAccuPrecision'], True)
    config['lutMapAccuBase'] = map(accu_base_lookup,
            utils.xfrange(0, 180, config['projection_angle_step']))
    # range required for accu_init
    def accu_init_vals(angle):
        part_val = accu_part_lookup(angle)
        line_val = -config['partition_scheme']['size'] * \
                accu_base_lookup(angle)
        return (part_val, part_val + line_val)
    def accu_init_range():
        accu_init_range_list = map(accu_init_vals,
                utils.xfrange(0, 180, config['projection_angle_step']))
        accu_init_range_list = list(chain.from_iterable(accu_init_range_list))
        return utils.bin_width_of_dec_vals(accu_init_range_list)
    accu_init_len, accu_init_signed = accu_init_range()
    config['tMapAccuInit'] = FixedPoint(
            accu_init_len, config['kMapAccuPrecision'], accu_init_signed)
    # range for accumulated value
    def accu_vals(angle):
        scan_val = config['image_size'] * accu_base_lookup(angle)
        val_0, val_1 = accu_init_vals(angle)
        return (val_0, val_1, val_0 + scan_val, val_1 + scan_val)
    def accu_range():
        accu_range_list = map(accu_vals,
                utils.xfrange(0, 180, config['projection_angle_step']))
        accu_range_list = list(chain.from_iterable(accu_range_list))
        return utils.bin_width_of_dec_vals(accu_range_list)
    accu_len, accu_signed = accu_range()
    config['tMapAccu'] = FixedPoint(
            accu_len, config['kMapAccuPrecision'], accu_init_signed)
    return config
