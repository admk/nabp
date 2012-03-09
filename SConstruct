# FIXME scons is crazy, it replaces pickle with cPickle and mangles the name.
# This breaks scipy.
# Workaround: in bash shell do
#     export SCONS_HORRIBLE_REGRESSION_TEST_HACK=0

import os
os.environ['NABP_CONFIG_PATH'] = os.path.abspath('default.naconfig')

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
