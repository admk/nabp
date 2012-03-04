import math


def validate(image_size, scheme):
    """A general validator for partitioning algorithms"""

    # check for partitioning efficiency
    if scheme['no_of_partitions'] > image_size:
        raise ValueError(
                'no_of_partitions should not be greater than image size')

    # check last tap for consistencies
    last_tap = (scheme['no_of_partitions'] - 1) * scheme['size']
    if last_tap != scheme['partitions'][-1]:
        raise ValueError('Last tap and partitions disagree')

    # check coverage for consistencies
    wasted_pixels = int(last_tap + scheme['size'] - image_size)
    if wasted_pixels < 0:
        raise ValueError('Partitions does not cover the entire image size')

    # check coverage efficiency
    if wasted_pixels >= scheme['size']:
        raise ValueError('Some partitions are not necessary.')


def validate_decorate(partition_function):
    """Encapsulate a validator to use as a decorator"""

    def validate_wrapper(image_size, no_of_partitions):
        # generate scheme with the partition function
        scheme = partition_function(image_size, no_of_partitions)
        # validation
        validate(image_size, scheme)
        return scheme

    return validate_wrapper


def partition(image_size, no_of_partitions):
    """
    >>> partition(512, 3)
    {'partitions': [0, 171, 342], 'no_of_partitions': 3, 'size': 171}
    >>> partition(512, 4)
    {'partitions': [0, 128, 256, 384], 'no_of_partitions': 4, 'size': 128}
    >>> partition(512, 5)
    {'partitions': [0, 103, 206, 309, 412], 'no_of_partitions': 5, 'size': 103}
    """
    partition_size = int(math.ceil(image_size / float(no_of_partitions)))

    partition_scheme = {
            'no_of_partitions': int(no_of_partitions),
            'size': partition_size,
            'partitions':
                    [int(idx * partition_size)
                        for idx in xrange(no_of_partitions)],
            }

    return partition_scheme


if __name__ == '__main__':
    import doctest
    doctest.testmod()
