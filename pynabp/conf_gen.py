import os

from pynabp.conf.partition import partition

from pynabp.conf.utils import import_conf, center, filter_coefs, angle_defines
from pynabp.conf.validate import ValidatorCollate
from pynabp.conf.luts import shift_lut_defines, map_lut_defines


# setup path for configuration file
path = os.environ['NABP_CONF']
if not path:
    path = os.path.abspath('../default.naconfig')

# import configuration
conf = import_conf(path)

# validation
ValidatorCollate(conf).validate()

# derived configuration
derived = \
    {
        # centers
        'projection_line_center': center(conf['projection_line_size']),
        'image_center': center(conf['image_size']),
        # filter
        'fir_coefs': filter_coefs(conf['fir_order'], conf['fir_function']),
        # partitions
        'partition_scheme': \
                partition(conf['image_size'], conf['no_of_partitions']),
        'kFilteredDataLength': \
                conf['kDataLength'] + conf['kFilteredDataPrecision'],
    }
derived.update(angle_defines(conf['kAnglePrecision']))
derived.update(shift_lut_defines(conf['kShiftAccuPrecision']))
derived.update(map_lut_defines(conf))

# update conf with derived configurations
conf.update(derived)
