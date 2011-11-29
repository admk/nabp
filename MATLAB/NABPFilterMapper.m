classdef NABPFilterMapper < handle
    properties
        % system configuration
        nabp_cfg
        % inputs
        p_line
        p_angle
        line_itr
        mode
    end
    properties(Access=protected)
        % internal states
        m_queue
        m_accu
        m_factor
        m_val
    end
    methods
        function obj = NABPFilterMapper(...
                nabp_cfg, mode, p_line, ...
                p_angle, line_itr)
            obj.nabp_cfg = nabp_cfg;
            obj.mode = mode;
            obj.p_line = p_line;
            obj.p_angle = p_angle;
            obj.line_itr = line_itr;
            obj.reset();
        end
        function val = next(obj)
            % value update
            m_accu_curr = obj.m_accu;
            m_accu_next = m_accu_curr + obj.m_factor;
            obj.m_accu = m_accu_next;

            % out of range checks
            p_size = obj.nabp_cfg.p_line_size;
            if obj.mode.buff_step_direction == 'a'
                assert(obj.m_factor <= 0, ...
                    ['m_factor cannot be positive for ' ...
                     'ascending step direction']);
                if m_accu_curr + 1 > p_size
                    val = 0;
                    return
                end
            else
                assert(obj.m_factor >= 0, ...
                    ['m_factor cannot be negative for ' ...
                     'descending step direction']);
                if m_accu_curr + 1 < 0
                    val = 0;
                    return
                end
            end

            % in range
            if ~numel(obj.m_queue)
                val = 0;
                return
            end
            m_val_0 = obj.m_val;
            if floor(m_accu_curr) ~= floor(m_accu_next)
                m_val_1 = obj.m_queue(end);
                obj.m_val = m_val_1;
                obj.m_queue = obj.m_queue(1:end-1);
            else
                m_val_1 = obj.m_queue(end);
            end
            if obj.nabp_cfg.p_domain_stream_interpolate
                w = obj.interpolate_weight();
                val = m_val_1 * (1 - w) + m_val_0 * w;
            else
                val = m_val_1;
            end
        end
        function w = interpolate_weight(obj)
            w = ceil(obj.m_accu) - obj.m_accu;
            if obj.mode.buff_step_direction == 'a'
                w = 1 - w;
            end
        end
        function reset(obj)
            no_of_pes = obj.nabp_cfg.pe_set.no_of_partitions;
            pe_size = obj.nabp_cfg.pe_set.partition_size;
            last_pe_pos = pe_size * (no_of_pes - 1);
            start_pos = last_pe_pos + obj.line_itr;

            if obj.mode.sector == 0
            	obj.m_accu = obj.s_eval(0, start_pos);
                obj.m_factor = -cosd(obj.p_angle);
            elseif obj.mode.sector == 1
                obj.m_accu = obj.s_eval(start_pos, 0);
                obj.m_factor = sind(obj.p_angle);
            elseif obj.mode.sector == 2
                obj.m_accu = obj.s_eval(start_pos, obj.nabp_cfg.i_size);
                obj.m_factor = sind(obj.p_angle);
            elseif obj.mode.sector == 3
                obj.m_accu = obj.s_eval(obj.nabp_cfg.i_size, start_pos);
                obj.m_factor = -cosd(obj.p_angle);
            end

            filtered_p_line = nabp_filter(obj.nabp_cfg, obj.p_line);
            last_tap_idx = floor(obj.m_accu) + 1;
            if obj.mode.buff_step_direction == 'a'
                if last_tap_idx < obj.nabp_cfg.p_line_size
                    % in hardware this is achieved by discarding
                    % (p_line_size - last_tap_idx) no of values in
                    % the same no of cycles
                    obj.m_queue = filtered_p_line(1:last_tap_idx);
                else
                    obj.m_queue = filtered_p_line;
                end
            else
                if last_tap_idx > 0
                    % same idea as above
                    obj.m_queue = filtered_p_line(end:-1:last_tap_idx);
                else
                    obj.m_queue = filtered_p_line(end:-1:1);
                end
            end

            obj.m_val = 0;
        end
    end
    methods(Access=private)
        function s = s_eval(obj, x, y)
            angle = obj.p_angle;
            x = x - obj.nabp_cfg.i_center;
            y = y - obj.nabp_cfg.i_center;
            s = - x * sind(angle) + y * cosd(angle);
            s = s + obj.nabp_cfg.p_line_center;
        end
    end
end

function filtered_projection = nabp_filter(nabp_cfg, projection)
    % FIR filtering
    % Does not filter in stream but in blocks
    % In efficient hardware implementation it will be replaced by a stream
    % filter.

    function filter = ramp_filter_coef(order)
        filter = linspace(0, 1, order/2+1);
        filter = [filter filter(end-1:-1:2)];
        filter = ifftshift(ifft(filter));
        filter = filter ./ max(filter);
    end

    order = nabp_cfg.fir_order;
    half_order = order / 2;
    assert(floor(half_order) == half_order, ...
            'Filter must be even-ordered.');
    fir_b = ramp_filter_coef(order);
    % filter each angle
    filtered_projection = zeros(size(projection));
    for idx = 1:size(projection, 2)
        % pass all data through filter
        % but also append half_order number of zeros
        % to compensate FIR group delay
        projection_slice = [projection(:,idx); ...
                zeros(half_order + nabp_cfg.pipeline_offset,1)];
        filtered_projection_slice = filter(fir_b, 1, projection_slice);
        filtered_projection(:,idx) = filtered_projection_slice(...
                (half_order + nabp_cfg.pipeline_offset + 1):end, 1);
    end
end
