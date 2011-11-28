function image = nabp(projection, projection_angles)

    no_of_partitions = 24;
    nabp_cfg = nabp_configure(...
            projection, projection_angles, no_of_partitions);

    image = zeros(nabp_cfg.i_size, nabp_cfg.i_size);

    figure;
    colormap('Gray');
    mov = moviein(nabp_cfg.p_angle_size);

    for p_angle_idx = 1:nabp_cfg.p_angle_size

        % mode control
        p_angle = projection_angles(p_angle_idx);
        mode = NABPModeControl(p_angle);

        for line_itr = 1:nabp_cfg.pe_set.partition_size

            % new filter mapper for this iteration
            p_line = projection(:, p_angle_idx);
            
            % mode control for current angle
            mode = NABPModeControl(p_angle);
 
            % buffer pipeline fill stage
            buffer_control = NABPBufferShifterControl(...
                nabp_cfg, mode, p_line, p_angle, ...
                line_itr);
            buffer = buffer_control.fill();
        
            % for each scan iteration
            for scan_itr = 1:nabp_cfg.i_size
                % for each pe, read from buffer taps
                for pe_itr = 1:nabp_cfg.pe_set.no_of_partitions
                    pe_tap = nabp_cfg.pe_set.partitions(pe_itr).lower;
                    pe_line = pe_tap + line_itr;
                    if mode.scan_mode == 'x'
                        if pe_tap <= nabp_cfg.i_size
                            image(scan_itr, pe_line) = ...
                                image(scan_itr, pe_line) + buffer(pe_tap);
                        end
                    elseif mode.scan_mode == 'y'
                        if pe_tap <= nabp_cfg.i_size
                            image(pe_line, scan_itr) = ...
                                image(pe_line, scan_itr) + buffer(pe_tap);
                        end
                    end
                end
                % shift chain buffer
                buffer = buffer_control.next();
            end
        end
        mov(:, p_angle_idx) = getframe;
    end

    movie(mov);
end
