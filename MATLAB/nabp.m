function image = nabp(projection, projection_angles)
    % The new architecture simulation in MATLAB

    nabp_cfg = nabp_configure(projection, projection_angles);
    image = zeros(nabp_cfg.i_size, nabp_cfg.i_size);

    colormap('Gray');
    imagesc(image);
    truesize(imgcf, size(image));

    for p_angle_idx = 1:nabp_cfg.p_angle_size

        % mode control
        p_angle = projection_angles(p_angle_idx);
        mode = NABPModeControl(p_angle);

        fprintf('Angle: %3.1f\n', p_angle);

        for line_itr = 1:nabp_cfg.pe_set.partition_size

            % new filter mapper for this iteration
            p_line = projection(:, p_angle_idx);

            % line buffer fill stage
            % line buffer double buffer swapping not implemented in MATLAB
            buffer_control = NABPBufferShifterControl(...
                nabp_cfg, mode, p_line, p_angle, ...
                line_itr);
            buffer = buffer_control.fill();

            % for each scan iteration
            for scan_itr = 1:nabp_cfg.i_size
                if nabp_cfg.p_domain_pe_interpolate
                    int_w = buffer_control.interpolate_weight();
                end

                % for each pe, read from buffer taps
                for pe_itr = 1:nabp_cfg.pe_set.no_of_partitions
                    pe_tap = nabp_cfg.pe_set.partitions(pe_itr).lower;
                    pe_line = pe_tap + line_itr - 1;
                    if mode.scan_direction == 'f'
                        scan_pos = scan_itr;
                    else
                        scan_pos = nabp_cfg.i_size - scan_itr + 1;
                    end
                    % interpolation
                    if (nabp_cfg.p_domain_pe_interpolate && ...
                            pe_tap < numel(buffer))
                        upd_val = buffer(pe_tap) * (1 - int_w) + ...
                                buffer(pe_tap + 1) * int_w;
                    else
                        upd_val = buffer(pe_tap);
                    end
                    if mode.scan_mode == 'x'
                        if pe_line < nabp_cfg.i_size
                            image(scan_pos, end - pe_line) = ...
                                    image(scan_pos, end - pe_line) ...
                                    + upd_val;
                        end
                    elseif mode.scan_mode == 'y'
                        if pe_line < nabp_cfg.i_size
                            image(pe_line, end - scan_pos + 1) = ...
                                    image(pe_line, end - scan_pos + 1) ...
                                    + upd_val;
                        end
                    end
                end
                % shift line buffer
                buffer = buffer_control.next();
            end
        end
        imagesc(image);
        getframe;
    end
    image = image .* (pi / nabp_cfg.p_angle_size);
    imagesc(image);
end
