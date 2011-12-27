import math

def nabp_partition(image_size, no_of_partitions):
    """
    >>> nabp_partition(512, 3)
    {'wasted_pixels': 1.0, 'partitions': [0, 171, 342], 'no_of_partitions': 3, 'size': 171.0}
    >>> nabp_partition(512, 4)
    {'wasted_pixels': 0.0, 'partitions': [0, 128, 256, 384], 'no_of_partitions': 4, 'size': 128.0}
    >>> nabp_partition(512, 5)
    {'wasted_pixels': 3.0, 'partitions': [0, 103, 206, 309, 412], 'no_of_partitions': 5, 'size': 103.0}
    """
    partition_scheme = {}
    partition_scheme['size'] = math.ceil(image_size / float(no_of_partitions))
    partition_scheme['partitions'] = []
    for idx in xrange(no_of_partitions):
        offset = int(idx * partition_scheme['size'])
        partition_scheme['partitions'].append(offset)
        idx += 1
    new_no_of_partitions = len(partition_scheme['partitions'])
    if new_no_of_partitions != no_of_partitions:
        return nabp_partition(image_size, new_no_of_partitions)
    last_tap = (no_of_partitions - 1) * partition_scheme['size']
    # check for consistencies
    if last_tap != partition_scheme['partitions'][-1]:
        raise Exception('Last tap and partitions disagree')
    partition_scheme['wasted_pixels'] = last_tap + partition_scheme['size'] - \
            image_size
    if partition_scheme['wasted_pixels'] < 0:
        raise Exception('Partitions does not cover the entire image size')
    partition_scheme['no_of_partitions'] = no_of_partitions
    return partition_scheme

if __name__ == '__main__':
    import doctest
    doctest.testmod()
