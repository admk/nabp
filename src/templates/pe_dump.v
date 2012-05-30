{# from pynabp.conf_gen import config #}

integer __pe_dump_err;

task pe_dump_init;
    begin
        python_path_update();
        __pe_dump_err = $pyeval("from pynabp import image_dump");
        __pe_dump_err = $pyeval(
                "image_dump.init('{# image_name #}', ",
                {# config['image_size'] #}, ")");
    end
endtask

task pe_dump_finish;
    begin
        __pe_dump_err = $pyeval("image_dump.finish('{# image_name #}')");
    end
endtask

task pe_dump_pixel;
    input integer x;
    input integer y;
    input integer val;
    begin
        if (x < {# config['image_size'] #} &&
            y < {# config['image_size'] #})
            __pe_dump_err = $pyeval(
                    "image_dump.update('{# image_name #}', ",
                    x, ",", y, ",", val, ")");
    end
endtask
