import os

def add_extension(file_list, ext):
    def _iterator():
        for f in file_list:
            f, _ = os.path.splitext(f)
            yield f + os.path.extsep + ext
    if type(file_list) is str:
        file_list = [file_list]
    return list(_iterator())

def flatten(files_dict):
    flat_files = set()
    for files in files_dict.itervalues():
        if type(files) is list:
            for f in files:
                flat_files.add(f)
        else:
            flat_files.add(f)
    return list(flat_files)
