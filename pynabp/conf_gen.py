import os
import math

from pynabp.conf.partition import partition

from pynabp.conf.utils import import_conf, center, filter_coefs, angle_defines
from pynabp.conf.validate import PreValidatorCollate, PostValidatorCollate
from pynabp.conf.luts import shift_lut_defines, map_lut_defines


# setup path for configuration file
conf_env_var = 'NABP_CONFIG_PATH'
conf_default_path = 'default.naconfig'

if conf_env_var in os.environ:
    path = os.environ[conf_env_var]
else:
    path = os.path.abspath(conf_default_path)

# import configuration
config = import_conf(path)

# validation
PreValidatorCollate(config).perform_validations()

# derived configiguration
def derive(config):
    """Derive additional configiguration defines from a validated configiguration
    dictionary.
    """
    # image size
    if config['image_size'] is not None:
        image_size = config['image_size']
    else:
        image_size = int(config['projection_line_size'] / math.sqrt(2))

    derived = \
        {
            # device
            'device': config['device'] if config['device'] else 'simulator',
            # null filling
            'image_size': image_size,
            # centers
            'projection_line_center': center(config['projection_line_size']),
            'image_center': center(image_size),
            # filter
            'fir_coefs': filter_coefs(config['fir_order'], config['fir_function']),
            # partitions
            'partition_scheme': \
                    partition(image_size, config['no_of_processing_elements']),
            'kFilteredDataLength': \
                    config['kDataLength'] + config['kFilteredDataPrecision'],
        }

    config_n_derived = dict(config)
    config_n_derived.update(derived)

    derived.update(angle_defines(
                config['kAnglePrecision'], config['angle_step_size']))
    derived.update(shift_lut_defines(config['kShiftAccuPrecision']))
    derived.update(map_lut_defines(config_n_derived))
    return derived

# update config with derived configigurations
config.update(derive(config))

PostValidatorCollate(config).perform_validations()
