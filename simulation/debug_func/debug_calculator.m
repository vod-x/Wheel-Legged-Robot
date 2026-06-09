classdef debug_calculator<handle
    properties
        theta1_val, theta2_val
    end

    methods
        function obj = debug_calculator()
        end

        function upd(obj, theta1, theta2)
            obj.theta1_val = theta1;
            obj.theta2_val = theta2;
        end
        function phi1(obj)
            fprintf('phi1 = %.6f\n', calc_phi1(obj.theta1_val, obj.theta2_val));
        end
        function phi2(obj)
            fprintf('phi2 = %.6f\n', calc_phi2(obj.theta1_val, obj.theta2_val));
        end 
        function alpha(obj)
            fprintf('alpha = %.6f\n', calc_alpha(obj.theta1_val, obj.theta2_val));
        end 
        function L(obj)
            fprintf('L = %.6f\n', calc_L(obj.theta1_val, obj.theta2_val));
        end  
        function Tm(obj)
            T_matrix = calc_T_matrix(obj.theta1_val, obj.theta2_val);
            fprintf('±ä»»¾ØÕó Tm:\n');
            disp(T_matrix);
        end
        function T(obj, F, T)
            clac_T(obj.theta1_val, obj.theta2_val, F, T)
        end
    end
end