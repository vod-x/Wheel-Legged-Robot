classdef kinematic_solver < handle
    properties
        %the length of the first big rod which is toward the direction of
        %forward
        br1 
        br2 %the length of the second big rod
        lr1 %the length of the first little rod
        lr2 %the length of the second little rod
        l   %the interval of the two joint motor

        %the position of joint, and the joint between the interval and br1
        %is numbered as 1, other joints are numbered counterclockwise
        j1 
        j2
        j3
        j4
        j5

        fig
    end
    methods
        function obj = kinematic_solver(br1, br2, lr1, lr2, interval)
            obj.br1 = br1;
            obj.br2 = br2;
            obj.lr1 = lr1;
            obj.lr2 = lr2;
            obj.l = interval;

            obj.fig = figure('Name', 'kinematic_solver');
            close
        end
        % @brief: 
        %   kinematic forward solver, input the angle of two joint motor 
        %   and output the position of wheel.
        % @param:
        %   a1 - the angle between the direction of forward and br1.
        %   a2 - the angle between the direction of forward and br2.
        % @return
        %   obj - a struct which include the coordinate x and coordinate y
        %         of the wheel, and taking jnt1 as the origin, the 
        %         direction of forward is the positive direction of the 
        %         x-axis, the direction ponting towards the  ground is the
        %         positive direction of the y-axis.

        function ret = forward(obj,a1, a2)
            
            %calculate the position of j1 and j2
            obj.j1.x = 0;
            obj.j1.y = 0;
            obj.j2.x = obj.j1.x - obj.l;
            obj.j2.y = obj.j1.y;

            %calculate the position of j5 and j3
            obj.j5.x = obj.j1.x + obj.br1 * cos(a1);
            obj.j5.y = obj.j1.y + obj.br1 * sin(a1);

            obj.j3.x = obj.j2.x + obj.br2 * cos(a2);
            obj.j3.y = obj.j2.y + obj.br2 * sin(a2);
            
            %calculate the angle phi1
            p = obj.j5.y - obj.j3.y;
            q = obj.j5.x - obj.j3.x;
            a = (obj.lr2 * obj.lr2) - (obj.lr1 * obj.lr1) - (p * p)...
                                           - (q * q) + (2 * q * obj.lr1);
            b = -4 * p * obj.lr1;
            c = (obj.lr2 * obj.lr2) - (obj.lr1 * obj.lr1) - (p * p)...
                                           - (q * q) - (2 * q * obj.lr1);
            z1 = (-b + sqrt(b * b - 4 * a * c)) / (2  * a);
            z2 = (-b - sqrt(b * b - 4 * a * c)) / (2  * a);
            z1 = mod(z1, 2*pi);
            z2 = mod(z2, 2*pi);
            if 2 * atan(z1) > pi/2
                phi1 = 2 * atan(z1);
            else
                phi1 = 2 * atan(z2);
            end

            %calculate the position of j4
            obj.j4.x = obj.j5.x + obj.lr1 * cos(phi1);
            obj.j4.y = obj.j5.y + obj.lr1 * sin(phi1);

            ret = obj.j4;

        end

        function ret = backward(obj, j4)
            a = (j4.x * j4.x) + (j4.y * j4.y) + (obj.br1 * obj.br1)...
                 - (obj.lr1 * obj.lr1) + (2 * obj.br1 * j4.x);
            b = -4 * obj.br1 * j4.y;
            c = (j4.x * j4.x) + (j4.y * j4.y) + (obj.br1 * obj.br1)...
                 - (obj.lr1 * obj.lr1) - (2 * obj.br1 * j4.x);    
            z1 = (-b + sqrt(b * b - 4 * a * c)) / (2  * a);
            z2 = (-b - sqrt(b * b - 4 * a * c)) / (2  * a);
            if 2 * atan(z1) < pi/3
                ret.a1 = 2 * atan(z1);
            else
                ret.a1 = 2 * atan(z2);
            end
            a = ((j4.x + obj.l) * (j4.x + obj.l)) + (j4.y * j4.y)... 
                + (obj.br2 * obj.br2)- (obj.lr2 * obj.lr2)... 
                + (2 * obj.br2 * (j4.x + obj.l));
            b = -4 * obj.br2 * j4.y;
            c = ((j4.x + obj.l) * (j4.x + obj.l)) + (j4.y * j4.y)... 
                + (obj.br2 * obj.br2) - (obj.lr2 * obj.lr2)... 
                - (2 * obj.br2 * (j4.x + obj.l));    
            z1 = (-b + sqrt(b * b - 4 * a * c)) / (2  * a);
            z2 = (-b - sqrt(b * b - 4 * a * c)) / (2  * a);
            if 2 * atan(z1) > pi/3
                ret.a2 = 2 * atan(z1);
            else
                ret.a2 = 2 * atan(z2);
            end            

        end
        function draw(obj)
            figure(obj.fig);
            hold on;

            plot([obj.j1.x, obj.j2.x], [-obj.j1.y, -obj.j2.y], 'k-', ...
                                                'LineWidth', 2); % l
            plot([obj.j2.x, obj.j3.x], [-obj.j2.y, -obj.j3.y], 'k-', ...
                                                'LineWidth', 2); % br2
            plot([obj.j3.x, obj.j4.x], [-obj.j3.y, -obj.j4.y], 'k-', ...
                                                'LineWidth', 2); % lr2
            plot([obj.j4.x, obj.j5.x], [-obj.j4.y, -obj.j5.y], 'k-', ...
                                                'LineWidth', 2); % lr1
            plot([obj.j5.x, obj.j1.x], [-obj.j5.y, -obj.j1.y], 'k-', ...
                                                'LineWidth', 2); % br1           
        end
    end
end 