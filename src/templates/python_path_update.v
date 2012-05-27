integer __path_update_err;

task python_path_update;
    begin
        __path_update_err = $pyeval("import os");
        __path_update_err = $pyeval("path = os.getcwd()");
        __path_update_err = $pyeval("import sys");
        __path_update_err = $pyeval("sys.path.append(path)");
    end
endtask
