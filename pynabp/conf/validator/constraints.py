from base import Validator, ValidateError


# use a dummy lambda to get the function type
func = type(lambda _: 0)

# constraint functions
natural = lambda val: val >= 0
positive = lambda val: val > 0
negative = lambda val: val < 0
odd = lambda val: val % 2 == 1
even = lambda val: val % 2 == 0

def boundaries(
        min_val=None, min_inclusive=False,
        max_val=None, max_inclusive=False):
    """Return a constraint function that bounds the value within the range
    specified by min_val and max_val.
    """
    return lambda val: \
        (val >= min_val if min_val is not None else True) and \
        (val <= max_val if max_val is not None else True) and \
        (val != min_val if not min_inclusive else True) and \
        (val != max_val if not max_inclusive else True)

def time_unit(val):
    """Time unit constraint finds values of the form: 10ns
    """
    import re
    return re.search(r'^\d+(s|ms|us|ns|ps|fs)$', val) is not None

def function_arg_count(count):
    import inspect
    return lambda function: len(inspect.getargspec(function).args) == count


class TypeValidateError(ValidateError):
    """Type mismatch found"""

class NullableValidateError(ValidateError):
    """Cannot be None valued"""

class ConstraintFunctionValidateError(ValidateError):
    """Failed to validate with function"""


class ConstraintsValidator(Validator):
    """A validator that accepts a dictionary of constraints for configuration
    validation.
    """
    def __init__(self, config):
        super(ConstraintsValidator, self).__init__(config)
        self._constraints = {}

    def add_constraints(self, dictionary=None, **kwargs):
        """Add constraints to check

        Data structure must be:
            key=(type, nullable, constraint functions)

        type - a Python or a custom type
        nullable - True/False, indicate if the value can be None valued
        constraint functions - a list of functions or a function for other
            constraint checking, the function returns True on satisfied
            constraint, returns False otherwise
        """
        if dictionary:
            self._constraints.update(dictionary)
        self._constraints.update(**kwargs)


    def validate_constraints(self, conf):
        """A validator method that perform preliminary checks to parameters.

        It uses the constraints added to perform checks
        """
        for key, val in conf.iteritems():
            self._null_check(key, val)
            self._type_check(key, val)
            self._function_check(key, val)

    def _type_check(self, key, val):
        """Perform type check for key/value pair

        It raises an exception when the value has a type mismatch.
        """
        if not val:
            return

        val_types = self._type_constraint(key)

        if not isinstance(val, val_types):
            raise TypeValidateError(
                    'Type mismatch, expected %s, found %s' %
                    (val_types, str(type(val))))

    def _null_check(self, key, val):
        """Perform null check for key/value pair

        It raises an exception when the value cannot be nullable but with a
        None value.
        """
        val_none = self._nullable_constraint(key)

        if val is None and not val_none:
            raise NullableValidateError(
                    'Not nullable key has a null value: (%s, %s)' %
                    (key, str(val)))

    def _function_check(self, key, val):
        """Perform check on the value with constraint functions
        """
        if not val:
            return

        val_constr_func = self._function_constraint(key)

        if not val_constr_func:
            return

        for val_func in val_constr_func:
            if not val_func(val):
                raise ConstraintFunctionValidateError(
                        'Constraint %s unsatisfied for (%s, %s)' %
                        (str(val_func), key, str(val)))

    def _type_constraint(self, key):
        """Return the type cosntraint on the value for a corresponding key"""
        val_types = self._constraints[key][0]

        if not isinstance(val_types, (tuple, list)):
            val_types = (val_types)

        return val_types

    def _nullable_constraint(self, key):
        """Return the nullable cosntraint on the value for a corresponding key
        """
        return self._constraints[key][1]

    def _function_constraint(self, key):
        """Return the cosntraint functions on the value for a corresponding key
        """

        constr = self._constraints[key][2]

        if type(constr) is func:
            constr = [constr]

        return constr
