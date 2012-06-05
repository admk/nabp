// {# name() #}
integer __pr_verify_err;
initial
    @(__pr_verify_err)
        if (__pr_verify_err != 0)
            $finish_and_return(__pr_verify_err);

initial
begin
    __pr_verify_err = $pyeval("from math import cos, sin, radians");
    __pr_verify_err = $pyeval(
            "def project(a, x, y):\n",
            "    a = radians(a)\n",
            "    x = x - {# c['image_center'] #}\n",
            "    y = y - {# c['image_center'] #}\n",
            "    s = -x * sin(a) + y * cos(a)\n",
            "    return int(round(s + {# c['projection_line_center'] #}))\n");
end

function integer expected_s_val;
    input integer angle;
    input integer x;
    input integer y;
    begin
        // FIXME: iverilog vpi does not like real values
        expected_s_val = $pyeval("project(", angle, ",", x, ",", y, ")");
    end
endfunction
