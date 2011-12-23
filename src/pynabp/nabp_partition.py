import math

def nabp_partition(image_size, no_of_partitions):
    partition_scheme = {}
    partition_scheme['size'] = math.ceil(image_size / no_of_partitions)
    partition_scheme['partitions'] = []
    for idx in xrange(no_of_partitions):
        offset = idx * partition_scheme['size']
        if offset >= image_size:
            # pe is out of range
            # discard current pe
            no_of_partitions = idx
            break
        partition_scheme['partitions'].append(offset)
    last_tap = (no_of_partitions - 1) * partition_scheme['size']
    if last_tap != partition_scheme['partitions'][-1]:
        raise Exception('Last tap and partitions disagree')
    partition_scheme['no_of_partitions'] = no_of_partitions
    return partition_scheme
