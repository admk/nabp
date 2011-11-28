classdef NABPModeControl < handle
    properties(SetAccess=private)
        % inputs
        projection_angle
        % outputs
        sector
        scan_mode
        scan_direction
        buff_step_direction
        buff_shift_mode
    end
    methods
        function obj = NABPModeControl(angle)
            obj.projection_angle = angle;

            if 0 <= angle && angle < 45
                obj.sector = 0;
            elseif 45 <= angle && angle < 90
                obj.sector = 1;
            elseif 90 <= angle && angle < 135
                obj.sector = 2;
            elseif 135 <= angle && angle < 180
                obj.sector = 3;
            else
                error('Angle value %f out of range', angle);
                obj.sector = -1;
            end

            if obj.sector == 0
                obj.scan_mode = 'x';
                obj.scan_direction = 'f';
                obj.buff_step_direction = 'a';
                obj.buff_shift_mode = 'tan';
            elseif obj.sector == 1
                obj.scan_mode = 'y';
                obj.scan_direction = 'f';
                obj.buff_step_direction = 'd';
                obj.buff_shift_mode = 'cot';
            elseif obj.sector == 2
                obj.scan_mode = 'y';
                obj.scan_direction = 'r';
                obj.buff_step_direction = 'd';
                obj.buff_shift_mode = 'cot';
            elseif obj.sector == 3
                obj.scan_mode = 'x';
                obj.scan_direction = 'r';
                obj.buff_step_direction = 'd';
                obj.buff_shift_mode = 'tan';
            end
        end
    end
end
