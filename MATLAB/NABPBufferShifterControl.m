classdef NABPBufferShifterControl < handle
    properties
        nabp_cfg

        p_angle
        mode

        buff
    end
    properties(Access=private)
        m_filter_mapper
        m_accu
        m_factor
    end
    methods
        function obj = NABPBufferShifterControl(...
                nabp_cfg, mode, p_line, p_angle, ...
                line_itr)

            obj.nabp_cfg = nabp_cfg;
            obj.p_angle = p_angle;
            obj.mode = mode;

            obj.m_accu = 0;
            if strcmp(mode.buff_shift_mode, 'tan')
            	obj.m_factor = tand(p_angle);
            elseif strcmp(mode.buff_shift_mode, 'cot')
                obj.m_factor = cotd(p_angle);
            end

            obj.m_filter_mapper = NABPFilterMapper(...
                    nabp_cfg, mode, p_line, p_angle, line_itr);
        end
        function buff = fill(obj)
            last_tap = obj.nabp_cfg.pe_set.partitions(end).lower;
            obj.buff = zeros(last_tap);
            for idx = 1:last_tap
                obj.buff(end - idx + 1) = obj.m_filter_mapper.next();
            end
            buff = obj.buff;
        end
        function buff = next(obj)
            if obj.should_shift()
            	next = obj.m_filter_mapper.next();
            	obj.buff = [next obj.buff(2:end)];
            end
            buff = obj.buff;
        end
    end
    methods(Access=protected)
        function b = should_shift(obj)
            m_accu_next = obj.m_accu + obj.m_factor;
            b = floor(m_accu_next) ~= floor(obj.m_accu);
            obj.m_accu = m_accu_next;
        end
    end
end
