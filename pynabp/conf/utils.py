import os

def _import(path=None):
    """Import a configuration file from path

    By default the imported file would be 'default.naconfig'.
    """
    if not path:
        path = os.path.abspath('../default.naconfig')
    globs = {}
    execfile(path, globs)
    return globs['config']
