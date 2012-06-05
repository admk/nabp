{# from pynabp.conf_gen import config #}

integer __image_dump_err;

task image_dump_init;
    begin
        python_path_update();
        __image_dump_err = $pyeval("from pynabp import image_dump");
        __image_dump_err = $pyeval(
                "image_dump.init('{# image_name #}', ",
                {# config['image_size'] #}, ")");
    end
endtask

task image_dump_finish;
    begin
        __image_dump_err = $pyeval("image_dump.dump('{# image_name #}')");
    end
endtask

task image_dump_pixel;
    input integer x;
    input integer y;
    input integer val;
    begin
        if (x < {# config['image_size'] #} &&
            y < {# config['image_size'] #})
            __image_dump_err = $pyeval(
                    "image_dump.update('{# image_name #}', ",
                    x, ",", y, ",", val, ")");
    end
endtask
