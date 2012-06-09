import pbs

from pynabp.conf.utils import import_conf
from pynabp.conf.partition import partition


def run(no_of_partitions):
    print 'Measuring %d...' % no_of_partitions
    config = import_conf('quartus.naconfig')
    partition_scheme = partition(config['image_size'], no_of_partitions)
    partition_scheme['no_of_partitions'] = no_of_partitions
    partition_scheme_str = 'partition_scheme=' + repr(partition_scheme)
    # generate sources
    pbs.scons('nabp_gen',
            partition_scheme_str, naconfig='quartus.naconfig', _fg=True)
    # quartus workflow
    pbs.cd('quartus')
    pbs.quartus_map('NABP', '-c', 'NABP', _fg=True)
    pbs.cd('..')

def measure():
    for no_of_partitions in [2 ** i for i in xrange(10)]:
        run(no_of_partitions)


if __name__ == '__main__':
    measure()
