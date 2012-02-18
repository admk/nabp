env = Environment()

env.SConscript('sources.scons')
gen_source = env.SConscript(
        'generate_sources.scons',
        variant_dir='derived_src', src_dir='src',
        duplicate=0)
compile_source = env.SConscript(
        'compile.scons',
        variant_dir='build', src_dir='derived_src',
        duplicate=0)
compile_vpi = env.SConscript('vpi_pyeval/SConstruct')

# FIXME iverilog-vpi generates the output in incorrect folder
SideEffect(['vpi_pyeval.vpi', 'vpi_pyeval.o'], compile_vpi)

# vim:ft=python:
