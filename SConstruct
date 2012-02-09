SConscript(
        'generate_sources.scons',
        variant_dir='derived_src', src_dir='src',
        duplicate=0)

SConscript('compile.scons',
        variant_dir='build', src_dir='derived_src',
        duplicate=0)

Depends('build', 'derived_src')

# vim:ft=python:
