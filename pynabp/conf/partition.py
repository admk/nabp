import math


def validate(image_size, scheme):
    """A general validator for partitioning algorithms"""

    # check for partition scheme consistency
    if scheme['no_of_partitions'] != len(scheme['partitions']):
        raise ValueError(
                'Length of partitions and number of partitions given mismatch')

    # check for partitioning efficiency
    if scheme['no_of_partitions'] > image_size:
        raise ValueError(
                'no_of_partitions should not be greater than image size')

    # check size uniformity
    for i in xrange(scheme['no_of_partitions'] - 1):
        size = abs(scheme['partitions'][i + 1] - scheme['partitions'][i])
        if size != scheme['size']:
            raise ValueError(
                    'Partitions do not have the same sizes, This is needed '
                    'for the implementation to work.')

    # check last tap for consistencies
    last_tap = (scheme['no_of_partitions'] - 1) * scheme['size']
    if last_tap != scheme['partitions'][-1]:
        raise ValueError('Last tap and partitions disagree')

    # check coverage for consistencies
    wasted_pixels = int(last_tap + scheme['size'] - image_size)
    if wasted_pixels < 0:
        raise ValueError('Partitions do not cover the entire image size')

    # check coverage efficiency
    if wasted_pixels >= scheme['size']:
        raise ValueError('Some partitions are not necessary.')


def algorithm(width, no):
    """
    Partitioning algorithm
    """
    # find optimal partition size
    partition_size = int(math.ceil(width / float(no)))
    partition_scheme = {
            'no_of_partitions': int(no),
            'size': partition_size,
            'partitions':
                    [int(idx * partition_size)
                        for idx in xrange(no)],
            }
    # partition pruning or appending
    while partition_size * (partition_scheme['no_of_partitions'] - 1) \
            > width - 1:
        # has one more unnecessary partition
        partition_scheme['no_of_partitions'] -= 1
        partition_scheme['partitions'] = partition_scheme['partitions'][:-1]
    return partition_scheme


def partition(image_size, no_of_partitions, subdivisions):
    """
    Partition generator
    """
    partitions = algorithm(image_size, no_of_partitions)
    if subdivisions > 1:
        partitions['subdivisions'] = algorithm(image_size, subdivisions)
    else:
        partitions['subdivisions'] = None
    return partitions
