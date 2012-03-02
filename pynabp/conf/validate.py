class Validator(object):
    """A simple validator class

    Should be subclassed to implement validators.
    """

    def __init__(self, config):
        super(Validator, self).__init__()
        self._validate()

    def _validation_methods(self):
        """Find all validation methods within the class

        Returns - a list of methods that can be called with the config file as
        the parameter for each method.
        """
        import inspect
        methods = [member[0] for member in inspect.getmembers(
                self.__class__, predicate=inspect.ismethod)]
        return [getattr(self, method)
                for method in methods if method.startswith('validate')]

    def _validate(self, config):
        """Validate cofig by calling each validation method in turn with the
        config

        If failed validation method should raise an exception.
        """
        for validation_method in self._validation_methods():
            try:
                validation_method(config)
            except:
                print 'Validation failed in method ' + \
                        str(validation_method)
                raise
