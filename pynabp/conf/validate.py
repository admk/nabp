from validator.base import Validator, ValidateError
from validator.constraints import ConstraintsValidator, func, \
        natural, positive, odd, even, time_unit, function_arg_count
import partition


class RelationValidateError(ValidateError):
    """A base validate error for RelationValidator"""


class PreRelationValidator(Validator):
    """Validate config relations"""

    SUPPORTED_DEVICES = ['stratix_iv', ]

    def validate_image_size_projection_line_size(self, config):
        if config['image_size'] is None and \
                config['projection_line_size'] is None:
            raise RelationValidateError(
                    'image_size and projection_line_size cannot be both '
                    'unspecified.')

    def validate_device(self, config):
        if config['debug']:
            return
        if not config['device'] or config['device'] == 'simulator':
            raise RelationValidateError(
                    'Release build device is not specified.')
        if config['device'] not in self.SUPPORTED_DEVICES:
            raise RelationValidateError(
                    'Unrecognised device %s.' % config['device'])


class PreConstraintsValidator(ConstraintsValidator):
    """Validate config constraints"""

    def __init__(self, config):
        super(PreConstraintsValidator, self).__init__(config)
        constraints = {
                    # key,               type,  None,   constraint functions
                    'debug':            (bool,  False,  None),
                    'target':           (list,  True,   None),
                    'clock_period':     ((float, int),
                                                False,  positive),
                    'time_precision':   (str,   False,  time_unit),
                    'device':           (str,   True,   None),
                    'projection_line_size':
                                        (int,   True,   positive),
                    'image_size':       (int,   True,   positive),
                    'fir_order':        (int,   False,  [even, positive]),
                    'fir_function':     (func,  True,   function_arg_count(1)),
                    'no_of_processing_elements':
                                        (int,   False,  positive),
                    'angle_step_size':  ((float, int),
                                                True,   positive),
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
                    'force':            (dict,  True,   None),
                }
        self.add_constraints(constraints)


class PostRelationValidator(Validator):
    """Validate config relations"""

    def validate_partition_scheme(self, config):
        """Validate partition scheme by trying to partition

        It performs checks for partitioning efficiency.
        """
        try:
            partition.validate(
                    config['image_size'],
                    config['partition_scheme'])
        except ValueError as e:
            raise RelationValidateError(str(e))


class PreValidatorCollate(PreRelationValidator, PreConstraintsValidator):
    """Collate all pre-deriviation validation classes into a unified one"""


class PostValidatorCollate(PostRelationValidator):
    """Collate all post-deriviation validation classes"""
