classdef kinematic_solver_GUI < handle
    properties
        fig
        ax
        h1, h2, h3, h4, h5
        h6, h7, h8, h9, h10
        t1, t2, t3, t4, t5
        panel;
        a1_slider, a2_slider;
        a1_text, a2_text;
        auto_button, reset_button, toggle_units_button;
        line_format = 'k';
        line_width = 2;
        point_format = 'o';
        point_size = 8;

        oj1x, oj1y
        oj2x, oj2y    
        oj3x, oj3y
        oj4x, oj4y
        oj5x, oj5y
        oj6x, oj6y
        oj7x, oj7y
        oj8x, oj8y
        oj9x, oj9y
        ophi0, ophi1, ophi2
        olambda1, olambda2

        is_radians = true;
        a1_default = 0;
        a2_default = deg2rad(100);
        max_bias, min_bias;
        br, lr, ebr, elr, ivl;
    end
    methods
        function obj = kinematic_solver_GUI(j1x, j1y, j2x, j2y, j3x, j3y, j4x, j4y, j5x, j5y, j6x, j6y, j7x, j7y, j8x, j8y, j9x, j9y, ...
                phi0, phi1, phi2, lambda1, lambda2, max_bias, min_bias, br, lr, ebr, elr, ivl)

            % store symbolic expressions
            obj.oj1x = j1x; obj.oj1y = j1y;
            obj.oj2x = j2x; obj.oj2y = j2y;
            obj.oj3x = j3x; obj.oj3y = j3y;
            obj.oj4x = j4x; obj.oj4y = j4y;
            obj.oj5x = j5x; obj.oj5y = j5y; 
            obj.oj6x = j6x; obj.oj6y = j6y;
            obj.oj7x = j7x; obj.oj7y = j7y;
            obj.oj8x = j8x; obj.oj8y = j8y;
            obj.oj9x = j9x; obj.oj9y = j9y; 
            obj.ophi0 = phi0; obj.ophi1 = phi1; obj.ophi2 = phi2;
            obj.olambda1 = lambda1; obj.olambda2 = lambda2;
            obj.max_bias = max_bias;
            obj.min_bias = min_bias;    
            obj.br = br;
            obj.lr = lr;
            obj.ebr = ebr;
            obj.elr = elr;
            obj.ivl = ivl;
            obj.init_UI();
        end

        function linehandle = create_line(obj)
            linehandle = plot(obj.ax, [0 0], [0 0], obj.line_format, ...
            'LineWidth', obj.line_width, 'Marker', obj.point_format,...
            'MarkerSize', obj.point_size); 
        end

        function init_UI(obj)
            % create figure
            obj.fig = figure('Name', 'kinematic_solver_GUI','Position', [100, 100, 1200, 800]);
            
            % create axes for drawing the mechanism
            obj.ax = axes('Parent', obj.fig, 'Position', [0.35 0.1 0.6 0.8]);
            axis(obj.ax, 'equal');
            grid(obj.ax, 'on');
            xlim(obj.ax, [-0.3 0.3]);
            ylim(obj.ax, [-0.3 0.3]);
            hold(obj.ax, 'on');
            set(obj.ax,'YDir','reverse');
            
            % create lines for the rods

            % j1-j2
            obj.h1 = obj.create_line();
            % j2-j3
            obj.h2 = obj.create_line();
            % j3-j4
            obj.h3 = obj.create_line();
            % j4-j5
            obj.h4 = obj.create_line();
            % j5-j1
            obj.h5 = obj.create_line();
            % j5-j6
            obj.h6 = obj.create_line(); 
            % j6-j7
            obj.h7 = obj.create_line();
            % j7-j8
            obj.h8 = obj.create_line();
            % j8-j5
            obj.h9 = obj.create_line();
            % j8-j9
            obj.h10 = obj.create_line();

            % create texts for the joints
            obj.t1 = text(0, 0, '  j3', 'VerticalAlignment', 'bottom', ...
            'HorizontalAlignment', 'left', 'FontSize', 12, 'FontWeight', ...
            'bold', 'Color', 'k');
            obj.t2 = text(0, 0, '  j5', 'VerticalAlignment', 'bottom', ...
            'HorizontalAlignment', 'left', 'FontSize', 12, 'FontWeight', ...
            'bold', 'Color', 'k');
            obj.t3 = text(0, 0, '  j4', 'VerticalAlignment', 'bottom', ...
            'HorizontalAlignment', 'left', 'FontSize', 12, 'FontWeight', ...
            'bold', 'Color', 'k');



            obj.panel = uipanel('Title', 'Kinematic Solver Control Panel', 'FontSize', 12, ...
                'BackgroundColor', 'white', ...
                'Position', [0.01 0.01 0.3 0.98]);
            
            % Slider for angle 1
            obj.a1_slider = uicontrol(obj.panel, 'Style', 'slider', ...
                'Min', 0, 'Max', 2*pi, 'Value', 0, ...
                'Position', [20 300 200 30], ...
                'Callback', @(src, event) obj.update());
            obj.a1_text = uicontrol(obj.panel, 'Style', 'text', ...
                'Position', [230 300 100 30], ...
                'String', sprintf('Angle 1: %.2f rad', obj.a1_slider.Value));
            
            % Slider for angle 2
            obj.a2_slider = uicontrol(obj.panel, 'Style', 'slider', ...
                'Min', obj.min_bias, 'Max', obj.max_bias, 'Value', 0, ...
                'Position', [20 250 200 30], ...
                'Callback', @(src, event) obj.update());
            obj.a2_text = uicontrol(obj.panel, 'Style', 'text', ...
                'Position', [230 250 100 30], ...
                'String', sprintf('Angle 2: %.2f rad', obj.a2_slider.Value));
            
            % Auto button
            obj.auto_button = uicontrol(obj.panel, 'Style', 'pushbutton', ...
                'String', 'Auto Solve', ...
                'Position', [50 150 100 30], ...
                'Callback', @(src, event) obj.auto_run());
            
            % Reset button
            obj.reset_button = uicontrol(obj.panel, 'Style', 'pushbutton', ...
                'String', 'Reset', ...
                'Position', [200 150 100 30], ...
                'Callback', @(src, event) obj.reset());

            % Toggle units button
            obj.toggle_units_button = uicontrol(obj.panel, 'Style', 'pushbutton', ...
                'String', 'Toggle Units', ...
                'Position', [125 100 100 30], ...
                'Callback', @(src, event) obj.toggle_units());                
            obj.reset();
        end
        function update(obj)
            a1_val = obj.a1_slider.Value;
            a2_val = obj.a2_slider.Value;

            if obj.is_radians
                set(obj.a1_text, 'String', sprintf('Standard Angle: %.2f rad', a1_val));
                set(obj.a2_text, 'String', sprintf('Bias Angle: %.2f rad', a2_val));
            else
                set(obj.a1_text, 'String', sprintf('Standard Angle: %.2f deg', rad2deg(a1_val)));
                set(obj.a2_text, 'String', sprintf('Bias Angle: %.2f deg', rad2deg(a2_val)));
            end
            % calculate joint positions
            pj1x = obj.ivl/2;
            pj1y = 0;
            pj2x = -obj.ivl/2;
            pj2y = 0;
        
            syms j1x j1y j2x j2y j3x j3y j5x j5y theta1 theta2

            pj5x = double(subs(obj.oj5x, [j1x, j1y, theta1], [pj1x, pj1y, a1_val]));
            pj5y = double(subs(obj.oj5y, [j1x, j1y, theta1], [pj1x, pj1y, a1_val]));
            pj3x = double(subs(obj.oj3x, [j1x, j1y, j2x, j2y, theta2], [pj1x, pj1y, pj2x, pj2y, a1_val + a2_val]));
            pj3y = double(subs(obj.oj3y, [j1x, j1y, j2x, j2y, theta2], [pj1x, pj1y, pj2x, pj2y, a1_val + a2_val]));
        
            phi1_val = double(subs(obj.ophi1, [theta1, theta2, j3x, j3y, j5x, j5y], [a1_val, a1_val + a2_val, pj3x, pj3y, pj5x, pj5y]));
            pj4x = pj5x + obj.lr * cos(phi1_val);
            pj4y = pj5y + obj.lr * sin(phi1_val);

            lambda1_val = double(subs(obj.olambda1, [theta1, theta2, j3x, j3y, j5x, j5y], [a1_val, a1_val + a2_val, pj3x, pj3y, pj5x, pj5y]));
            lambda2_val = double(subs(obj.olambda2, [theta1, theta2, j3x, j3y, j5x, j5y], [a1_val, a1_val + a2_val, pj3x, pj3y, pj5x, pj5y]));
            
            pj6x = pj5x + obj.elr * cos(-lambda1_val);
            pj6y = pj5y + obj.elr * sin(-lambda1_val);
            pj7x = pj6x + obj.ebr * cos(lambda2_val);
            pj7y = pj6y + obj.ebr * sin(lambda2_val);
            pj8x = pj5x + obj.ebr * cos(lambda2_val);
            pj8y = pj5y + obj.ebr * sin(lambda2_val);
            pj9x = pj4x * (obj.ebr + obj.br) / obj.br;
            pj9y = pj4y * (obj.ebr + obj.br) / obj.br;

            % update plots
            set(obj.h1, 'XData', [pj1x pj2x], 'YData', [pj1y pj2y]);
            set(obj.h2, 'XData', [pj2x pj3x], 'YData', [pj2y pj3y]);
            set(obj.h3, 'XData', [pj3x pj4x], 'YData', [pj3y pj4y]);
            set(obj.h4, 'XData', [pj4x pj5x], 'YData', [pj4y pj5y]);
            set(obj.h5, 'XData', [pj5x pj1x], 'YData', [pj5y pj1y]);
            set(obj.h6, 'XData', [pj5x pj6x], 'YData', [pj5y pj6y]);
            set(obj.h7, 'XData', [pj6x pj7x], 'YData', [pj6y pj7y]);
            set(obj.h8, 'XData', [pj7x pj8x], 'YData', [pj7y pj8y]);
            set(obj.h9, 'XData', [pj8x pj5x], 'YData', [pj8y pj5y]);
            set(obj.h10, 'XData', [pj8x pj9x], 'YData', [pj8y pj9y]);

            set(obj.t1, 'Position', [double(pj3x), double(pj3y)], 'String', '  j3');
            set(obj.t2, 'Position', [double(pj5x), double(pj5y)], 'String', '  j5');
            set(obj.t3, 'Position', [double(pj4x), double(pj4y)], 'String', '  j4');
            drawnow;            
        end

        function reset(obj)
            set(obj.a1_slider, 'Value', obj.a1_default);
            set(obj.a2_slider, 'Value', obj.a2_default);
            obj.update();
        end

        function auto_run(obj)
            frames = 100;
            ivl_time = 0.05;
            for i = 1:frames
                a1 = obj.a1_slider.Min + (obj.a1_slider.Max - obj.a1_slider.Min) * i / frames;
                set(obj.a1_slider, 'Value', a1);
                a2 = obj.a2_slider.Min + (obj.a2_slider.Max - obj.a2_slider.Min) * i / frames;
                set(obj.a2_slider, 'Value', a2);
                obj.update();
                pause(ivl_time);
            end
        end

        function toggle_units(obj)
            obj.is_radians = ~obj.is_radians;
            obj.update();
        end
    end
end