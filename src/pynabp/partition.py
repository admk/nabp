import math

def partition(image_size, no_of_partitions):
    """
    >>> partition(512, 3)
    {'wasted_pixels': 1, 'partitions': [0, 171, 342], 'no_of_partitions': 3, 'size': 171}
    >>> partition(512, 4)
    {'wasted_pixels': 0, 'partitions': [0, 128, 256, 384], 'no_of_partitions': 4, 'size': 128}
    >>> partition(512, 5)
    {'wasted_pixels': 3, 'partitions': [0, 103, 206, 309, 412], 'no_of_partitions': 5, 'size': 103}
    """
    partition_scheme = {}
    partition_scheme['no_of_partitions'] = int(no_of_partitions)
    partition_scheme['size'] = int(math.ceil(
            image_size / float(no_of_partitions)))
    partition_scheme['partitions'] = []
    for idx in xrange(no_of_partitions):
        offset = int(idx * partition_scheme['size'])
        partition_scheme['partitions'].append(offset)
    # check for consistencies
    last_tap = (no_of_partitions - 1) * partition_scheme['size']
    if last_tap != partition_scheme['partitions'][-1]:
        raise Exception('Last tap and partitions disagree')
    partition_scheme['wasted_pixels'] = int(last_tap +
            partition_scheme['size'] - image_size)
    if partition_scheme['wasted_pixels'] < 0:
        raise Exception('Partitions does not cover the entire image size')
    return partition_scheme

if __name__ == '__main__':
    import doctest
    doctest.testmod()
