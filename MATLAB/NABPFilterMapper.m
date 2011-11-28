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
            m_accu_next = obj.m_accu + obj.m_factor;
            if floor(obj.m_accu) ~= floor(m_accu_next)
                if obj.m_queue
                    val = obj.m_queue(end);
                    obj.m_queue = obj.m_queue(1:end-1);
                else
                    val = 0;
                end
            else
                val = obj.m_queue(end);
            end
            obj.m_accu = m_accu_next;
        end
        function reset(obj)
            no_of_pes = obj.nabp_cfg.pe_set.no_of_partitions;
            pe_size = obj.nabp_cfg.pe_set.partition_size;
            last_pe_pos = pe_size * (no_of_pes - 1);
            start_pos = last_pe_pos + obj.line_itr;

            if obj.mode.sector == 0
            	obj.m_accu = obj.s_eval(0, start_pos);
            elseif obj.mode.sector == 1
                obj.m_accu = obj.s_eval(start_pos, 0);
            elseif obj.mode.sector == 2
                obj.m_accu = obj.s_eval(start_pos, obj.nabp_cfg.i_size);
            elseif obj.mode.sector == 3
                obj.m_accu = obj.s_eval(obj.nabp_cfg.i_size, start_pos);
            end

            filtered_p_line = nabp_filter(obj.p_line);
            buffer_size = floor(obj.m_accu) + 1;
            queue = zeros(1, buffer_size);
            for idx = 1:buffer_size
                if 1 <= idx && idx <= length(queue)
                    queue(idx) = filtered_p_line(idx);
                else
                	queue(idx) = 0;
                end
            end
            if obj.mode.buff_step_direction == 'a'
                obj.m_queue = queue;
            else
                obj.m_queue = queue(end:-1:1);
            end

            if obj.mode.buff_step_direction == 'x'
            	obj.m_factor = -cosd(obj.p_angle);
            else
            	obj.m_factor = sind(obj.p_angle);
            end
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

function filtered_projection = nabp_filter(projection)
    % FIR filtering
    % Does not filter in stream but in blocks
    % In efficient hardware implementation it will be replaced by a stream
    % filter.
    order = 64;
    half_order = order / 2;
    fir_b = ramp_filter_coef(order);
    % filter each angle
    filtered_projection = zeros(size(projection));
    for idx = 1:size(projection, 2)
        % pass all data through filter
        % but also append half_order number of zeros
        % to compensate FIR group delay
        projection_slice = [projection(:,idx); zeros(half_order,1)];
        filtered_projection_slice = filter(fir_b, 1, projection_slice);
        filtered_projection(:,idx) = filtered_projection_slice(...
                end-half_order+1, 1);
    end
end

function filter = ramp_filter_coef(order)
    filter = linspace(0, 1, order/2+1);
    filter = [filter filter(end-1:-1:2)];
    filter = ifftshift(ifft(filter));
    filter = filter ./ max(filter);
end
