%% Clear the workspace and close all figures, set which modules to run.
clear;
close all;
% set to false to disable visualization
visualization = true; 

%% Init the physical properties of the model.

% The unit of length is m, the unit of mass is kg, the unit of time is s, the 
% unit of angle is rad.

% the length of big rod
br = 2 ;
% the length of little rod
lr = 3;
% the length of extended big rod  
ebr = 4;
% the length of extended little rod
elr = 5;
% the interval between the two motors
ivl = 0;

% syms br lr ebr elr ivl;
% the maximum and minimum angle of mechanical limit
max_mechanical_angle = -120 * pi / 180;
min_mechanical_angle = -192 * pi / 180;
% the maxium and minimun angle of the bias between the two rods
[max_bias, min_bias] = ...
        bias_angle_calc(br, lr, max_mechanical_angle, min_mechanical_angle);


%% Variables definition

% The position of joints, the middle point between j1 and j2 is the origin.
% 
%       j2-ivl-j1      j6     --------> derction of forward
%       /       \     /  \
%      br        \  elr   \
%     /           \ /      \
%     j3          j5       j7   j5-j6-j7-j8 are a parallelogram
%      \         /  \      /
%       lr      /   ebr   /
%        \     /      \  / 
%         \   /        j8 
%          \ /         /
%          j4         /
%                    /          origin, j4 and j9 are in the same line
%                   /
%                  /
%                 /
%                /
%               j9
syms j1x j1y j2x j2y j3x j3y j4x j4y j5x j5y 
syms j6x j6y j7x j7y j8x j8y j9x j9y 

% The angle of joints, reclockwise is positive, 
% d_ is the first derivative respect to time,
% d2_ is the second derivative respect to time.

% the angle between the direction of forward and j1 to j5, 
syms theta1 d_theta1 d2_theta1;
% the angle between the direction of forward and j2 to j3, 
syms theta2 d_theta2 d2_theta2;
% the angle between the direction of forward and j5 to j4
syms phi1 d_phi1 d2_phi1;
% the angle between the direction of forward and j3 to j4
syms phi2 d_phi2 d2_phi2;

% The velocity, acceleration, force and torque of end effector. 
% In parallel structure, the joint is j4. In serial structure, the joint is j9. 
% Prefix 'e'(extended) means that it is the data of j9.

% the velocity acceleration and force in rectangular coordinates
syms dx dy d2x d2y;
syms e_dx e_dy e_d2x e_d2y;
syms Fx Fy e_Fx e_Fy;
% the velocity and acceleration in polar coordinates
syms alpha d_alpha d2_alpha;
syms Fc Ft T;
syms e_Fc e_Ft e_T;

% The angle between ground and the end effector.
syms beta d_beta d2_beta;

%% Kinematic solver 

j2x = j1x - ivl;
j2y = j1y;
j5x = j1x + br * cos(theta1);
j5y = j1y + br * sin(theta1);
j3x = j2x + br * cos(theta2);
j3y = j2y + br * sin(theta2);

syms t1 t2;

j4eq1 = j5x + lr * cos(phi1) == j3x + lr * cos(phi2);
j4eq2 = j5y + lr * sin(phi1) == j3y + lr * sin(phi2);

% solve phi1
phi1eq1 = isolate(j4eq1, cos(phi2));        
phi1eq2 = isolate(j4eq2, sin(phi2));

phi1eq3 = expand(simplify(phi1eq1^2 + phi1eq2^2));
phi1eq4 = subs(phi1eq3, [cos(phi1), sin(phi1)], ...
                [(1 - t1^2)/(1 + t1^2), (2*t1)/(1 + t1^2)]);
t1sol = simplify(solve(phi1eq4, t1));

% solve phi2
phi2eq1 = isolate(j4eq1, cos(phi1));
phi2eq2 = isolate(j4eq2, sin(phi1));

phi2eq3 = expand(simplify(phi2eq1^2 + phi2eq2^2));
phi2eq4 = subs(phi2eq3, [cos(phi2), sin(phi2)], ...
                [(1 - t2^2)/(1 + t2^2), (2*t2)/(1 + t2^2)]);
t2sol = simplify(solve(phi2eq4, t2));

phi1 = acos((1 - t1sol(2)^2)/(1 + t1sol(2)^2));
phi2 = acos((1 - t2sol(1)^2)/(1 + t2sol(1)^2));

% when the ebr and elr are not zero, the structure is serial, then calculate 
% the position of j6 to j9
if ebr ~= 0 && elr ~= 0
    % theta0 is the angle between j4-j3 and j4-j5
    theta0 = acos(1-(br^2/lr^2)*(1-cos(theta2-theta1)));
    % phi0 is the angle between j5-j1 and j5-j4
    phi0 = (2*pi - theta0 - (theta2 - theta1))/2;
    % lambda1 is the angle between j5-j6 and the direction of forward
    lambda1 = pi - phi1;
    % lambda2 is the angle between j5-j8 and the direction of forward
    lambda2 = phi0 - lambda1;

    j6x = j5x + elr * cos(lambda1);
    j6y = j5y + elr * sin(lambda1);
    j7x = j6x + ebr * cos(lambda2);
    j7y = j6y + ebr * sin(lambda2);
    j8x = j5x + ebr * cos(lambda2);
    j8y = j5y + ebr * sin(lambda2);
    j9x = j4x * (ebr + br) / br;
    j9y = j4y * (ebr + br) / br;
end



if visualization
    % initialize figure
    figure;
    set(gcf, 'Position', [100, 100, 800, 600]);
    hold on;
    grid on;
    axis equal;
    xlabel('X');
    ylabel('Y');
    set(gca, 'YDir', 'reverse');   
    title('kinematic solver visualization');

    % initialize plot handles
    h1 = plot([0, 0], [0, 0], 'k-o', 'LineWidth', 2, 'MarkerSize', 8,...
                                                        'MarkerFaceColor', 'k');
    h2 = plot([0, 0], [0, 0], 'b-o', 'LineWidth', 2, 'MarkerSize', 8,...
                                                        'MarkerFaceColor', 'b');
    h3 = plot([0, 0], [0, 0], 'r-o', 'LineWidth', 2, 'MarkerSize', 8,...
                                                        'MarkerFaceColor', 'r');
    h4 = plot([0, 0], [0, 0], 'g-o', 'LineWidth', 2, 'MarkerSize', 8,...
                                                        'MarkerFaceColor', 'g');
    h5 = plot([0, 0], [0, 0], 'm-o', 'LineWidth', 2, 'MarkerSize', 8,...
                                                        'MarkerFaceColor', 'm');

    if ebr ~=0 && elr ~=0
        h6 = plot([0, 0], [0, 0], 'c-o', 'LineWidth', 2, 'MarkerSize', 8,...
                                                        'MarkerFaceColor', 'c');
        h7 = plot([0, 0], [0, 0], 'y-o', 'LineWidth', 2, 'MarkerSize', 8,...
                                                        'MarkerFaceColor', 'y');
        h8 = plot([0, 0], [0, 0], 'k-o', 'LineWidth', 2, 'MarkerSize', 8,...
                                                        'MarkerFaceColor', 'k');
        h9 = plot([0, 0], [0, 0], 'k-o', 'LineWidth', 2, 'MarkerSize', 8,...
                                                        'MarkerFaceColor', 'k');    
        h10 = plot([0, 0], [0, 0], 'k-o', 'LineWidth', 2, 'MarkerSize', 8,...
                                                        'MarkerFaceColor', 'k');                                                                                                                
    end                                                        
    t1 = text(0, 0, '  j3', 'VerticalAlignment', 'bottom', ...
        'HorizontalAlignment', 'left', 'FontSize', 12, 'FontWeight', ...
        'bold', 'Color', 'k');
    t2 = text(0, 0, '  j5', 'VerticalAlignment', 'bottom', ...
        'HorizontalAlignment', 'left', 'FontSize', 12, 'FontWeight', ...
        'bold', 'Color', 'k');

    % animation parameters
    frames = 100;     %the number of frames
    ivl_time = 0.02;  %the time interval between two frames

    for i = 1:frames

        % calculate angles
        a1 = deg2rad(30 + (150 - 70) * (i - 1) / (frames - 1));
        a2 = deg2rad(150 - (150 - 120) * (i - 1) / (frames - 1));

        % calculate joint positions
        pj1x = ivl/2;
        pj1y = 0;
        pj2x = -ivl/2;
        pj2y = 0;
        pj5x = subs(j5x, [j1x, j1y, theta1], [pj1x, pj1y, a1]);
        pj5y = subs(j5y, [j1x, j1y, theta1], [pj1x, pj1y, a1]);
        pj3x = subs(j3x, [j1x, j1y, j2x, j2y, theta2], [pj1x, pj1y, pj2x, pj2y, a2]);
        pj3y = subs(j3y, [j1x, j1y, j2x, j2y, theta2], [pj1x, pj1y, pj2x, pj2y, a2]);
        pj4x1 = pj5x + lr * cos(double(subs(phi1, [theta1, theta2], [a1, a2])));
        pj4y1 = pj5y + lr * sin(double(subs(phi1, [theta1, theta2], [a1, a2])));
        pj4x2 = pj3x + lr * cos(double(subs(phi2, [theta1, theta2], [a1, a2])));
        pj4y2 = pj3y + lr * sin(double(subs(phi2, [theta1, theta2], [a1, a2])));

        if ebr ~=0 && elr ~=0
            pj6x = pj5x + elr * cos(-double(subs(lambda1, [theta1, theta2], [a1, a2])));
            pj6y = pj5y + elr * sin(-double(subs(lambda1, [theta1, theta2], [a1, a2])));
            pj7x = pj6x + ebr * cos(double(subs(lambda2, [theta1, theta2], [a1, a2])));
            pj7y = pj6y + ebr * sin(double(subs(lambda2, [theta1, theta2], [a1, a2])));
            pj8x = pj5x + ebr * cos(double(subs(lambda2, [theta1, theta2], [a1, a2])));
            pj8y = pj5y + ebr * sin(double(subs(lambda2, [theta1, theta2], [a1, a2])));
            pj9x = pj4x1 * (ebr + br) / br;
            pj9y = pj4y1 * (ebr + br) / br;        
        end
        % update plots
        set(h1, 'XData', [pj1x, pj2x], 'YData', [pj1y, pj2y]);
        set(h2, 'XData', [pj2x, pj3x], 'YData', [pj2y, pj3y]);
        set(h3, 'XData', [pj3x, pj4x1], 'YData', [pj3y, pj4y1]);
        set(h4, 'XData', [pj5x, pj4x1], 'YData', [pj5y, pj4y1]);        
        set(h5, 'XData', [pj1x, pj5x], 'YData', [pj1y, pj5y]);
        
        if ebr ~=0 && elr ~=0
            set(h6, 'XData', [pj5x, pj6x], 'YData', [pj5y, pj6y]);
            set(h7, 'XData', [pj6x, pj7x], 'YData', [pj6y, pj7y]);
            set(h8, 'XData', [pj5x, pj8x], 'YData', [pj5y, pj8y]);
            set(h9, 'XData', [pj7x, pj8x], 'YData', [pj7y, pj8y]);
            set(h10, 'XData', [pj8x, pj9x], 'YData', [pj8y, pj9y]);        
        end
        % add labels
        set(t1, 'Position', [double(pj3x), double(pj3y)], 'String', '  j3');
        set(t2, 'Position', [double(pj5x), double(pj5y)], 'String', '  j5');

        drawnow
        pause(ivl_time);
    end

         
end

% %%
% %init the physical properties of the model
% initial_height = 600;
% 
% % main_body.length = 487;
% % main_body.width = 429;
% % main_body.hight = 300;
% % main_body.mass = 13;
% 
% main_body.length = 387;
% main_body.width = 429;
% main_body.hight = 150;
% main_body.mass =2;
% 
% load.length = 200;
% load.width = 200;
% load.hight = 210;
% load.mass = 3.8;
% load.position_y = 0;
% 
% motor.radius = 44.5;
% motor.length = 55;
% %motor is assembled in the main body and its mass was included.
% motor.mass = 0.5;
% motor.postion_x = 66;
% motor.postion_y = 187;
% motor.max_angle = -192;
% motor.min_angle = -120;
% 
% big_rod.length = 156;
% big_rod.width = 50;
% big_rod.height = 35;
% big_rod.mass = 1;
% 
% little_rod.length = 201;
% little_rod.width = 35;
% little_rod.height = 21;
% little_rod.mass = 1;
% 
% wheel.radius = 72;
% wheel.length = 28;
% wheel.mass = 1;
% 
% body2jonit_length = 60;
% %%
% %LQR calculate
% 
% %the variable of state
% syms theta d_theta d2_theta;
% syms x     d_x     d2_x;
% syms phi   d_phi   d2_phi;
% syms T_w   d_T_w   d2_T_w;
% syms T_p   d_T_p   d2_T_p;
% 
% %the variable of constrain force
% syms N_wp P_wp N_pb P_pb f;
% 
% %the constant which is determined by the mechanical structrue
% syms R_w L_wp L_pb L_c;
% syms m_w m_p  m_b; 
% syms I_w I_p  I_b;
% syms g;
% 
% N_pb = m_b * (d2_x+ (L_wp + L_pb) * d_theta^2 * sin(theta) - ...
%               (L_wp + L_pb) * d2_theta * cos(theta)... 
%               + L_c * d_phi^2 *sin(phi)...
%               - L_c * d2_phi *cos(phi));
% 
% P_pb = m_b * (g - (L_wp + L_pb) * d_theta^2 * cos(theta)...
%               - (L_wp + L_pb) * d2_theta * sin(theta)...
%               -L_c * d_phi^2 * cos(phi)...
%               -L_c * d2_phi * sin(phi));
% 
% N_wp = m_p * (d2_x + L_wp * d_theta^2 * sin(theta)...
%               - L_wp * d2_theta * cos(theta)) + N_pb;
% 
% P_wp = m_p * (g - L_wp * d_theta^2 * cos(theta)...
%                 - L_wp * d2_theta * sin(theta)) + P_pb;
% 
% eq1 = d2_x == (-T_w - N_wp * R_w) / (I_w / R_w + m_w * R_w);
% eq2 = I_p * d2_theta == (P_wp * L_wp + P_pb * L_pb) * sin(theta)...
%                         + (N_wp * L_wp + N_pb * L_pb) * cos(theta)...
%                         - T_w + T_p;
% eq3 = I_b * d2_phi ==   P_pb * L_c * sin(phi)...
%                      + N_pb * L_c * cos(phi)...
%                      - T_p;                        
% 
% model_solve = solve([eq1 eq2 eq3], [d2_theta, d2_x, d2_phi]);
% X = [x, d_x, phi, d_phi, theta, d_theta].';
% % dX = [d_x,     simplify(model_solve.d2_x),   ...
% %       d_phi,   simplify(model_solve.d2_phi), ...
% %       d_theta, simplify(model_solve.d2_theta)].';
% dX = [d_x,     simplify(model_solve.d2_x),   ...
%       d_phi,   simplify(model_solve.d2_phi), ...
%       d_theta, simplify(model_solve.d2_theta)].';
% 
% 
% U = [T_w T_p].';
% 
% A_sym = jacobian(dX,X);
% B_sym = jacobian(dX,U);
% 
% Ls = 0.1:0.01:0.38;
% Ks = zeros(2, 6, length(Ls));
% 
% for step = 1:length(Ls)
% %变量
%     R_w = wheel.radius/1000; %车轮的半径
%     m_w = wheel.mass; %驱动轮转子质量
%     I_w = m_w*R_w^2/2;%m_w*R^2/2; %驱动轮转动惯量 0.00104 0.0004656
%     L_c = body2jonit_length/1000; %车体质心到关节中点（用于计算）
%     m_p = (big_rod.mass + little_rod.mass)*2; %摆杆质量
%     L_pb = Ls(step)/2; %摆杆中心到驱动关节
%     L_wp = Ls(step)/2; %摆杆中心到驱动轮
%     I_p = m_p*Ls(step)^2/12; %摆杆转动惯量 
% 
%     m_b = (main_body.mass); %车身质量 
%     I_b = m_b*((main_body.length/1000)^2+(main_body.hight/1000)^2)/12; %车体转动惯量
% 
% 
% 
% %    wh_Leg = 0.09; %摆杆宽度
% %     % Ls(step) = 0.4;%摆杆长度
% %     m_body = 6.0; %车身质量
% %     wh_body = 0.2;%上车体高度
% %     L_body = 0.37; %上车体长度
% 
% %     %变量
% %     R_w = 0.075; %车轮的半径
% %     m_w = 1.15; %驱动轮转子质量
% %     I_w = 0.0015056;%m_w*R^2/2; %驱动轮转动惯量 0.00104 0.0004656
% %     L_c = -0.01; %车体质心到关节中点（用于计算）
% %     m_p = 1.2; %摆杆质量
% %     L_pb = Ls(step)*(Ls(step)/0.38)*0.4; %摆杆中心到驱动关节
% %     L_wp = Ls(step) - L_pb; %摆杆中心到驱动轮
% %     I_p = m_p*(wh_Leg^2+Ls(step)^2)/12 + 0.00007+0.07*L_wp*L_wp; %摆杆转动惯量 
% 
% %     m_b = m_body/2; %车身质量 
% %     I_b = m_b*(wh_body^2+L_body^2)/12; %车体转动惯量
% 
% 
%     theta = 0.0;
%     d_theta = 0;
%     phi = 0;
%     d_phi = 0;
%     g = 9.71;
%     d_x=0;
% 
%     A = double(subs(A_sym));
%     B = double(subs(B_sym));
% 
%     [Ad ,Bd] = c2d(A, B, 0.001);
% 
%     %[x, dx, phi, dphi, theta, dtheta]                 
%     Q = diag([0.002, 0.015, 5000, 1, 5, 5]);
%     % Q = diag([0.1, 0.01, 5000, 1, 1, 1]);
% 
%     %[T_w, T_p]
%     R = diag([0.25, 0.25]);
% 
%     T_count = 0.001;
% 
%     % Ks(:, :,step) = lqr(A,B,Q,R);      
%     Ks(:, :,step) = dlqr(Ad,Bd,Q,R);  
%     % if step == 5
%     %     K_test = lqrd(A,B,Q,R,T_count)  
%     % end
% end
% 
% K=sym('K',[2 6]);
% syms L0;
% count =  1;
% for x=1:2
%     for y=1:6
%         p=vpa(polyfit(Ls,reshape(Ks(x,y,:),1,length(Ls)),3),8);
%         K(x,y)=p(1)*L0^3+p(2)*L0^2+p(3)*L0+p(4);
% 
%         % subplot(2,6,count);
%         % fplot(K(x,y));
%         % hold on;
%         count = count+1;        
%     end
% end
%         % K(1,1)=-K(1,1);
%         % K(1,2)=-K(1,2);
% 
% %%
%     %VMC 
% 
% my_VMC = VMC(2 * motor.postion_x,big_rod.length, big_rod.length, ...
%             little_rod.length, little_rod.length);
% 
% syms theta1 theta2 d_theta1 d_theta2 F
% % VMC_calc = my_VMC.transform(theta1, theta2, d_theta1, d_theta2, F);
% % vmc_t = @(theta1, theta2, d_theta1, d_theta2, F)my_VMC.transform(theta1, theta2, d_theta1, d_theta2, F);
% % syms theta1 theta2 d_theta1 d_theta2 F;
% % matlabFunction(vmc_t, 'Vars', [theta1, theta2, d_theta1, d_theta2, F]);
% 
% 
% % subs(K,L0,ret.L) * [100,0,0.1,0,0,0].'
% ret1 = my_VMC.transform(pi/2, pi/2, 0, 0, [100,0].');
% my_VMC_calc = @(theta1, theta2, d_theta1, d_theta2, F)VMC_calc((2 * motor.postion_x /1000), (little_rod.length/1000),theta1, theta2, d_theta1, d_theta2, F);
% % [L, d_L , alpha, d_alpha, T] = VMC_calc((2 * motor.postion_x /1000), (little_rod.length/1000), pi/2, pi/2, 0, 0, [100,0].')
% [L, d_L , alpha, d_alpha, T] = my_VMC_calc(pi/2, pi/2, 0, 0, [100,0].');
% matlabFunction(K, 'File', 'LQR_calc','Vars', L0);
% aerial_posture_K = sym('aerial_posture_K',[2 6]);
% 
% aerial_posture_K(1,1) = 0;
% aerial_posture_K(1,2) = 0;
% aerial_posture_K(1,3) = 0;
% aerial_posture_K(1,4) = 0;
% aerial_posture_K(1,5) = 0;
% aerial_posture_K(1,6) = 0;
% aerial_posture_K(2,1) = 0;
% aerial_posture_K(2,2) = 0;
% aerial_posture_K(2,3) = 0;
% aerial_posture_K(2,4) = 0;
% aerial_posture_K(2,5) = K(2,5)*100;
% % aerial_posture_K(2,6) = K(2,6);
% aerial_posture_K(2,6) = 0;
% 
% matlabFunction(aerial_posture_K, 'File', 'aerial_posture_control','Vars', L0);
% -LQR_calc(0.25)
% %%
% LQR_Tw_limit = 10;
% LQR_Tp_limit = 30;
% PID_F_limit = 400;
% 
% Leg_pid.Kp = 10000;
% Leg_pid.Ki = 0;
% Leg_pid.Kd = 400;
% 
% 
% time1 = 1;
% length1 = 0.25;
% time2 = 2;
% length2 = 0.25;
% time3 = 2.05;
% length3 = 0.25;
% initial_length = 0.25;
% final_length = 0.25;
% 
% length_change_time = [0;   time1;   time1; time2; time2; time3; time3; 10];
% left_leg_length =    [initial_length;length1; length1; length2; length2;length3;length3;final_length];
% right_leg_length =   [initial_length;length1; length1; length2; length2;length3;length3;final_length];
% left_leg_length_set = [length_change_time, left_leg_length];
% right_leg_length_set = [length_change_time, right_leg_length];
% 
% rod_limit = 130;
% enable_time = 0.3;
% v_d_time = [0;   time2;   time2; 14];
% v_d_set =    [5; 5; 5; 5];
% v_d= [v_d_time, v_d_set];
% % v_d= [0, 0];
% x_disturbing = 0;
% revolute_disturbing = 0;
% support_force = 50;
% x_d = 0;
% disp("变量已更新")