import os
import math

from pynabp.conf.validate import PreValidatorCollate, PostValidatorCollate
from pynabp.conf.partition import partition
from pynabp.conf.utils import import_conf, recursive_update_dict, \
        center, filter_coefs, angle_defines
from pynabp.conf.luts import shift_lut_defines, map_lut_defines, \
        init_sinogram_defines, sinogram_defines


# setup path for configuration file
conf_path = 'build/current.naconfig'
if not os.path.exists(conf_path):
    conf_path = 'default.naconfig'

# import configuration
config = import_conf(os.path.abspath(conf_path))

# validation
PreValidatorCollate(config).perform_validations()


def derive(config):
    """Derive additional configuration defines from a validated configuration
    dictionary.
    """
    # image size
    if config['image_size'] is None:
        image_size = int(config['projection_line_size'] / math.sqrt(2))
    else:
        image_size = config['image_size']
    # projection line size
    if config['projection_line_size'] is None:
        projection_line_size = int(config['image_size'] * math.sqrt(2))
    else:
        projection_line_size = config['projection_line_size']

    derived = \
        {
            # device
            'device': config['device'] if config['device'] else 'simulator',
            # null filling
            'image_size': image_size,
            'projection_line_size': projection_line_size,
            # centers
            'projection_line_center': center(projection_line_size),
            'image_center': center(image_size),
            # filter
            'fir_coefs':
                    filter_coefs(config['fir_order'], config['fir_function']),
            # partitions
            'partition_scheme':
                    partition(image_size, config['no_of_processing_elements']),
            'kFilteredDataLength':
                    1 + config['kDataLength'] + \
                            config['kFilteredDataPrecision'],
        }

    config_n_derived = dict(config)
    config_n_derived.update(derived)

    derived.update(angle_defines(
                config['kAnglePrecision'], config['angle_step_size']))
    derived.update(shift_lut_defines(config['kShiftAccuPrecision']))
    derived.update(map_lut_defines(config_n_derived))

    init_sinogram_defines(
                    derived['image_size'], derived['projection_line_size'],
                    derived['angle_step_size'], derived['kNoOfAngles'],
                    config['kDataLength'], derived['fir_coefs'])
    derived.update(sinogram_defines())

    return derived


# update config with derived configigurations
config.update(derive(config))

PostValidatorCollate(config).perform_validations()

# update config with forced values of parameters
if config['force'] is not None:
    force = dict(config['force'])
    del config['force']
    config = recursive_update_dict(config, force)
