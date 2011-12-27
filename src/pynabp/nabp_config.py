import math
import numpy as np
from nabp_partition import nabp_partition
from ramp_filter import ramp_filter

global config
config = None

def nabp_config(
        projection_data=None, no_of_partitions=20, fir_order=64, **kwargs):
    global config
    if config:
        return config
    config = {}
    config['projection_data'] = projection_data
    if projection_data:
        config['projection_line_size'] = np.shape(projection_data)[1]
        config['projection_angles_size'] = np.shape(projection_data)[0]
    else:
        # FIXME projection_line_size
        # odd size for integer-valued center,
        # or use (x).(1) fixed precision
        config['projection_line_size'] = 367
        config['projection_angles_size'] = 180
    config['projection_angle_step'] = 180 / config['projection_angles_size']
    config['projection_line_center'] = (config['projection_line_size'] - 1) / 2
    config['image_size'] = math.ceil(
            config['projection_line_size'] / math.sqrt(2))
    half_image_size = config['image_size'] / 2
    if half_image_size == math.floor(half_image_size):
        config['image_size'] += 1
    config['image_center'] = (config['image_size'] - 1) / 2
    config['projection_domain_pe_interpolate'] = False
    config['projection_domain_stream_interpolate'] = False
    config['projection_domain_stream_pipeline_offset'] = -1
    if config['projection_domain_stream_interpolate']:
        config['projection_domain_stream_pipeline_offset'] -= 1
    config['partition_scheme'] = nabp_partition(
            config['image_size'], no_of_partitions)
    config.update(kwargs)
    config['ramp_filter_coefs'] = ramp_filter(fir_order)
    return config
