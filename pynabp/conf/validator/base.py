import inspect


class ValidateError(Exception):
    """A validation error"""


class Validator(object):
    """A simple validator class

    Should be subclassed to implement validators.
    """

    def __init__(self, config):
        super(Validator, self).__init__()
        self.config = config

    def perform_validations(self):
        """Validate cofig by calling each validation method in turn with the
        config

        If failed validation method should raise an exception.
        """
        for name, method in self._validation_methods():
            try:
                print 'Validating with method ' + name
                method(self.config)
            except:
                print 'Validation failed in method ' + name
                raise

    def _validation_methods(self):
        """Find all validation methods within the class

        Returns - a list of tuples containing method names and corresponding
            methods that can be called with the config file as the parameter
            for each method.
        """
        methods = [member[0] for member in inspect.getmembers(
                self.__class__, predicate=inspect.ismethod)]
        return [(method, getattr(self, method))
                for method in methods if method.startswith('validate')]
