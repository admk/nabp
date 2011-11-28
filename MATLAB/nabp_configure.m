%% Configure (compile-time)
function nabp_cfg = nabp_configure(...
        projection, projection_angles, no_of_partitions)
    % projection size
    nabp_cfg.p_line_size = size(projection, 1);
    nabp_cfg.p_angle_size = length(projection_angles);
    nabp_cfg.p_line_center = (nabp_cfg.p_line_size + 1) / 2;
    assert(nabp_cfg.p_angle_size == size(projection, 2), ...
        'Number of angles mismatch');

    % filter order
    nabp_cfg.fir_order = 64;

    % image size & center
    nabp_cfg.i_size = nabp_cfg.p_line_size;
    nabp_cfg.i_center = (nabp_cfg.i_size + 1) / 2;

    % generate partition ranges
    nabp_cfg.pe_set = nabp_partition(...
        nabp_cfg.i_size, no_of_partitions);
end
