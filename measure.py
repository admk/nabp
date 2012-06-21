from pbs import cd, rm, cp, mkdir, scons, quartus_sh, glob, touch

from pynabp.conf.utils import import_conf
from pynabp.conf.partition import partition


no_of_partitions_list = []
def run(no_of_partitions, force=False):
    print 'Measuring %d...' % no_of_partitions
    config = import_conf('quartus.naconfig')
    partition_scheme = partition(config['image_size'], no_of_partitions)
    if force:
        partition_scheme['no_of_partitions'] = no_of_partitions

    actual_no_of_partitions = partition_scheme['no_of_partitions']
    if actual_no_of_partitions in no_of_partitions_list:
        print 'Already tested'
        return

    no_of_partitions_list.append(actual_no_of_partitions)
    partition_scheme_str = 'partition_scheme=' + repr(partition_scheme)

    err = None

    # generate sources
    scons('nabp_gen',
            partition_scheme_str, naconfig='quartus.naconfig', _fg=True)
    # quartus workflow
    cd('quartus/')
    try:
        try:
            rm(glob('*.rpt'), _fg=True)
        except:
            pass
        try:
            rm(glob('*.summary'), _fg=True)
        except:
            pass
        quartus_sh('--flow', 'compile', 'NABP', '-c', 'NABP', _fg=True)
        # touch('1.rpt')
        results_dir = 'results/%d/' % actual_no_of_partitions
        try:
            mkdir('-p', results_dir)
        except:
            pass
        cp(glob('*.rpt'), results_dir)
        cp(glob('*.summary'), results_dir)
    except Exception as e:
        err = e
    cd('..')
    return err

def measure():
    status_file = open('measure.status', 'w')
    for no_of_partitions in xrange(33, 513):
        try:
            run(no_of_partitions)
        except Exception as e:
            err_str = '%d failed: %s' % (no_of_partitions, str(e))
            print err_str
            status_file.write(err_str)
            status_file.flush()
    status_file.close()


if __name__ == '__main__':
    import sys
    if len(sys.argv) == 1:
        measure()
    else:
        no_of_partitions = int(sys.argv[1])
        print 'Running %d' % no_of_partitions
        run(no_of_partitions, force=True)
