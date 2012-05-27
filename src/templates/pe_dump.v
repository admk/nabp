{# from pynabp.conf_gen import config #}
{# include('python_path_update.v') #}

integer __pe_dump_err;

task pe_dump_init;
    begin
        python_path_update();
        __pe_dump_err = $pyeval("from pynabp import test");
        __pe_dump_err = $pyeval("test.init(", {# config['image_size'] #}, ")");
    end
endtask

task pe_dump_finish;
    begin
        __pe_dump_err = $pyeval("test.finish()");
    end
endtask

task pe_dump_pixel;
    input integer x;
    input integer y;
    input integer val;
    begin
        if (x < {# config['image_size'] #} &&
            y < {# config['image_size'] #})
            __pe_dump_err = $pyeval("test.update(", x, ",", y, ",", val, ")");
    end
endtask
