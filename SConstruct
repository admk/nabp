import os
import shutil

from pynabp.conf.utils import import_conf, export_conf, recursive_update_dict

AddOption(
        '--naconfig',
        dest='naconfig',
        type='string',
        action='store',
        default='default.naconfig',
        help='configuration file location')

config_file = GetOption('naconfig')
if not config_file.endswith('.naconfig'):
    config_file += '.naconfig'

# update config with parameters
config = import_conf(config_file)
if config['force'] is None:
    config['force'] = {}
force_dict = {k: eval(v) for k, v in ARGUMENTS.iteritems()}
config['force'] = recursive_update_dict(config['force'], force_dict)
export_conf('build/current.naconfig', config)


env = Environment()

SOURCE_DIR = 'src'
Export('SOURCE_DIR')

env.SConscript('sources.scons')
env.SConscript(
        'generate_sources.scons',
        variant_dir='derived_src', src_dir=SOURCE_DIR,
        duplicate=0)
env.SConscript(
        'compile.scons',
        variant_dir='build', src_dir='derived_src',
        duplicate=0)
compile_vpi = env.SConscript('vpi_pyeval/SConstruct')

Import('compiled_tests')
Depends(compiled_tests, compile_vpi)

# vim:ft=python:
