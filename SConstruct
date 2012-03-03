import os
os.environ['NABP_CONFIG_PATH'] = os.path.abspath('default.naconfig')
env = Environment()

env.SConscript('sources.scons')
env.SConscript(
        'generate_sources.scons',
        variant_dir='derived_src', src_dir='src',
        duplicate=0)
env.SConscript(
        'compile.scons',
        variant_dir='build', src_dir='derived_src',
        duplicate=0)
compile_vpi = env.SConscript('vpi_pyeval/SConstruct')

Import('compiled_tests')
Depends(compiled_tests, compile_vpi)

# vim:ft=python:
