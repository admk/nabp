import os

def add_extension(file_list, ext):
    """
    Change or add extension to a file
    """
    def _iterator():
        for f in file_list:
            f, _ = os.path.splitext(str(f))
            yield f + os.path.extsep + ext
    if type(file_list) is str:
        file_list = [file_list]
    return list(_iterator())

def flatten(files_dict):
    """
    Flatten a dictionary of lists into a list.
    """
    flat_files = set()
    for files in files_dict.itervalues():
        if type(files) is list:
            for f in files:
                flat_files.add(f)
        else:
            flat_files.add(f)
    return list(flat_files)

def device_path(
        device_name, device_specific_file_list, source_file_list, source_dir):
    """
    Return device specific file source list based on the device specified
    """
    def device_path_mapper(src):
        if src not in device_specific_file_list:
            return src
        device_src = os.path.join('device', device_name, src)
        if os.path.isfile(os.path.join(source_dir, device_src)):
            return device_src
        return os.path.join('device', 'generic', src)

    return map(device_path_mapper, source_file_list)
