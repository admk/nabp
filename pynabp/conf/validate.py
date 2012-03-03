from validator.base import Validator, ValidateError
from validator.constraints import ConstraintsValidator, func, \
        natural, positive, odd, even, time_unit, function_arg_count


class RelationshipValidator(Validator):
    """Validate config relationships
    """
    def validate_map_accu_relationship(self, config):
        if config['kMapAccuPrecision'] < config['kMapAccuPartPrecision']:
            raise ValidateError(
                    'kMapAccuPrecision must be greater or equal to '
                    'kMapAccuPartPrecision')


class ValidatorCollate(Validator, ConstraintsValidator):
    """Collate all validation classes into a unified one"""

    def __init__(self, config):
        super(ValidatorCollate, self).__init__(config)
        constraints = {
                    # key,               type,  None,   constraint functions
                    'debug':            (bool,  False,  None),
                    'clock_period':     (int,   False,  positive),
                    'time_precision':   (str,   False,  time_unit),
                    'device':           (str,   True,   None),
                    'projection_line_size':
                                        (int,   False,  [odd, positive]),
                    'image_size':       (int,   True,   [odd, positive]),
                    'fir_order':        (int,   False,  [even, positive]),
                    'fir_function':     (func,  True,   function_arg_count(1)),
                    'no_of_processing_elements':
                                        (int,   False,  positive),
                    'kDataLength':      (int,   False,  positive),
                    'kFilteredDataPrecision':
                                        (int,   False,  natural),
                    'kAnglePrecision':  (int,   False,  natural),
                    'kShiftAccuPrecision':
                                        (int,   False,  positive),
                    'kMapAccuPrecision':
                                        (int,   False,  positive),
                    'kMapAccuPartPrecision':
                                        (int,   False,  positive),
                }
        self.add_constraints(constraints)
