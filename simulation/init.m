%% Clear the workspace and close all figures.
clear;
close all;

%% Set which modules to run.

% set to 1 to use syms variables, use numeric values otherwise
use_syms = 0;
% set to false to disable visualization
visualization = 0; 



%% Add paths

addpath('simulation/debug_func');
calc = debug_calculator ;
%% Init the physical properties of the model.

% The unit of length is m, the unit of mass is kg, the unit of time is s, the 
% unit of angle is rad.

if use_syms
    syms br lr ebr elr ivl zoom_factor
else
    br = 0.09461 ; % the length of big rod
    lr = 0.11253; % the length of little rod
    ebr = 0.11598; % the length of extended big rod  
    % ebr = 0;
    elr = 0.06506; % the length of extended little rod
    % elr = 0;
    ivl = 0; % the interval between the two motors
    % ivl = 0.03253;
    % when use seriel structure, the zoom factor of the end effector 
    zoom_factor = (br+ebr)/(br); 
end

% length of virtual leg
syms L

% the maximum and minimum angle of mechanical limit
max_mechanical_angle = 140 * pi / 180;
min_mechanical_angle = 90 * pi / 180;
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
syms j1x(t) j1y(t) j2x(t) j2y(t) j3x(t) j3y(t) j4x(t) j4y(t) j5x(t) j5y(t)
syms j6x(t) j6y(t) j7x(t) j7y(t) j8x(t) j8y(t) j9x(t) j9y(t)

% The angle of joints, reclockwise is positive, 
% d_ is the first derivative respect to time,
% d2_ is the second derivative respect to time.

% the angle between the direction of forward and j1 to j5, 
syms theta1(t) d_theta1 d2_theta1;
% the angle between the direction of forward and j2 to j3, 
syms theta2(t) d_theta2 d2_theta2;
% the angle between the direction of forward and j5 to j4
syms phi1(t) d_phi1 d2_phi1;
% the angle between the direction of forward and j3 to j4
syms phi2(t) d_phi2 d2_phi2;

% The velocity, acceleration, force and torque of end effector. 
% In parallel structure, the joint is j4. In serial structure, the joint is j9. 
% Prefix 'e'(extended) means that it is the data of j9.

% the velocity acceleration and force in rectangular coordinates
syms dx dy d2x d2y;
syms e_dx e_dy e_d2x e_d2y;
syms Fx Fy e_Fx e_Fy;
% the velocity and acceleration in polar coordinates
syms alpha(t) d_alpha d2_alpha;
syms Fc Ft T;
syms e_Fc e_Ft e_T;

% The angle between ground and the end effector.
syms beta_sym(t) beta d_beta d2_beta;




j2x = j1x - ivl;
j2y = j1y;
j5x = j1x + br * cos(theta1);
j5y = j1y + br * sin(theta1);
j3x = j2x + br * cos(theta2);
j3y = j2y + br * sin(theta2);

syms t1 t2;

j4eq1 = j5x + lr * cos(phi1) == j3x + lr * cos(phi2);
j4eq2 = j5y + lr * sin(phi1) == j3y + lr * sin(phi2);

j4x = j5x + lr * cos(phi1);
j4y = j5y + lr * sin(phi1);

%% VMC
pj4eq1 = subs(diff(j4eq1, t),...
    [diff(j1x,t), diff(j1y,t),diff(theta1,t), diff(theta2,t), ...
    diff(phi1, t), diff(phi2, t)], [0, 0, d_theta1, d_theta2, d_phi1, d_phi2]);
pj4eq2 = subs(diff(j4eq2, t),...
    [diff(j1x,t), diff(j1y,t),diff(theta1,t), diff(theta2,t), ...
    diff(phi1, t), diff(phi2, t)], [0, 0, d_theta1, d_theta2, d_phi1, d_phi2]);
d_thetasolve = solve([pj4eq1, pj4eq2], [d_phi1, d_phi2]);
d_phi1 = simplify(d_thetasolve.d_phi1);
d_phi2 = simplify(d_thetasolve.d_phi2);

d_x = zoom_factor * subs(diff(j4x, t),...
    [diff(j1x,t), diff(j1y,t),diff(theta1,t), diff(theta2,t), ...
    diff(phi1, t), diff(phi2, t)], [0, 0, d_theta1, d_theta2, d_phi1, d_phi2]);
d_y = zoom_factor * subs(diff(j4y, t),...
    [diff(j1x,t), diff(j1y,t),diff(theta1,t), diff(theta2,t), ...
    diff(phi1, t), diff(phi2, t)], [0, 0, d_theta1, d_theta2, d_phi1, d_phi2]);
% calculate the diffrential of polar coordinates of the end effector 
diff_L = cos(alpha) * d_x + sin(alpha) * d_y;
diff_alpha = (-sin(alpha) * d_x + cos(alpha) * d_y) / L;
d_X = [d_x; d_y];
d_q = [d_theta1; d_theta2];
d_X = simplify(collect(d_X, d_q));
% jacobin matrix
J = simplify(jacobian(d_X, d_q));
% rotation matrix 
R = [-sin(alpha), cos(alpha);
     -cos(alpha),  sin(alpha)];
% zoom matrix
Z = [0, 1/L;
     1, 0];
% VMC transformation matrix
% [T1; T2] =T * [F; T]
T = J.'* R * Z;

%% Kinematic solver 

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


phi1 = 2 * atan(t1sol(2));
phi2 = 2 * atan(t2sol(1));



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
j9x = j4x * zoom_factor;
j9y = j4y * zoom_factor;
alpha = simplify(atan2(j9y, j9x));
L = sqrt(j9x^2 + j9y^2);
if visualization
    % create the kinematic solver GUI object
    GUI = kinematic_solver_GUI(j1x, j1y, j2x, j2y, j3x, j3y, j4x, j4y, j5x, j5y, j6x, j6y, j7x, j7y, j8x, j8y, j9x, j9y,...
        phi0, phi1, phi2, lambda1, lambda2, max_bias, min_bias, br, lr, ebr, elr, ivl);

end

%% phgysical modeling

% the variable of state

% the tourque of wheel
syms T_w;
% the torque of virtual leg
syms T_p;
% the position and velocity of the center of mass of main body
syms x_sym(t) x d_x d2_x;
syms x_p(t) y_p(t);
syms x_b(t) y_b(t);
% the variable of constrain force
syms N_wp P_wp N_pb P_pb f;

% the constant which is determined by the mechanical structrue
syms R_w L_wp L_pb L_c;
syms m_w m_p  m_b;
syms I_w I_p  I_b;
syms g;

syms gamma_sym(t) gamma d_gamma d2_gamma;

x_b = x_sym - sin(beta_sym) * (L_wp + L_pb) - sin(gamma_sym) * L_c;
y_b = cos(beta_sym) * (L_wp + L_pb) + cos(gamma_sym) * L_c;
x_p = x_sym - sin(beta_sym) * L_wp;
y_p = cos(beta_sym) * L_wp;

% solve constrain force
constrain_eq1 = N_pb                  == m_b * diff(x_b, t ,2);
constrain_eq2 = P_pb - m_b * g        == m_b * diff(y_b, t ,2);
constrain_eq3 = N_wp - N_pb           == m_p * diff(x_p, t ,2);
constrain_eq4 = P_wp - P_pb - m_p * g == m_p * diff(y_p, t ,2);

constrain_solve = solve([constrain_eq1, constrain_eq2, constrain_eq3, constrain_eq4],...
    [N_pb, P_pb, N_wp, P_wp]);
% N_pb = subs(subs(simplify(constrain_solve.N_pb),[diff(x,t), diff(beta,t), diff(gamma,t)], [d_x, d_beta, d_gamma]), [diff(x,t,t), diff(beta,t,t), diff(gamma,t,t)], [d2_x, d2_beta, d2_gamma]);
% N_pb = subs((constrain_solve.N_pb),[diff(x,t), diff(beta,t), diff(gamma,t)], [d_x, d_beta, d_gamma]);
N_pb = subs(subs(simplify(constrain_solve.N_pb),[diff(x_sym,t,t), diff(beta_sym,t,t), diff(gamma_sym,t,t)], [d2_x, d2_beta, d2_gamma]), [diff(x_sym,t), diff(beta_sym,t), diff(gamma_sym,t)], [d_x, d_beta, d_gamma]);
P_pb = subs(subs(simplify(constrain_solve.P_pb),[diff(x_sym,t,t), diff(beta_sym,t,t), diff(gamma_sym,t,t)], [d2_x, d2_beta, d2_gamma]), [diff(x_sym,t), diff(beta_sym,t), diff(gamma_sym,t)], [d_x, d_beta, d_gamma]);
N_wp = subs(subs(simplify(constrain_solve.N_wp),[diff(x_sym,t,t), diff(beta_sym,t,t), diff(gamma_sym,t,t)], [d2_x, d2_beta, d2_gamma]), [diff(x_sym,t), diff(beta_sym,t), diff(gamma_sym,t)], [d_x, d_beta, d_gamma]);
P_wp = subs(subs(simplify(constrain_solve.P_wp),[diff(x_sym,t,t), diff(beta_sym,t,t), diff(gamma_sym,t,t)], [d2_x, d2_beta, d2_gamma]), [diff(x_sym,t), diff(beta_sym,t), diff(gamma_sym,t)], [d_x, d_beta, d_gamma]);

% dynamic equations
dyn_eq1 = isolate((I_w * d2_x / R_w == -T_w - f * R_w), f) - ...
                                isolate((m_w * d2_x == f - N_wp), f);
dyn_eq2 = I_p * d2_beta == T_p - T_w + P_wp * L_wp * sin(beta_sym) + ...
                N_wp * L_wp * cos(beta_sym) + P_pb * L_pb * sin(beta_sym) + ...
                N_pb * L_pb * cos(beta_sym);
dyn_eq3 = I_b * d2_gamma == -T_p + P_pb * L_c * sin(gamma_sym) + ...
                                N_pb * L_c * cos(gamma_sym);
    
model_solve = solve([dyn_eq1, dyn_eq2, dyn_eq3], [d2_x, d2_beta, d2_gamma]);
model_solve = subs(model_solve,{x_sym, beta_sym,gamma_sym},{x,beta,gamma});
% X = [x, d_x, beta, d_beta, gamma, d_gamma].';
% dX = [d_x, simplify(model_solve.d2_x), ...  
%     d_beta, simplify(model_solve.d2_beta), ...
%     d_gamma, simplify(model_solve.d2_gamma)].';
X = [x, d_x, gamma, d_gamma, beta, d_beta].';
dX = [d_x, simplify(model_solve.d2_x), ...  
    d_gamma, simplify(model_solve.d2_gamma),...
    d_beta, simplify(model_solve.d2_beta)].';

U = [T_w; T_p];
A_sym = jacobian(dX, X);
B_sym = jacobian(dX, U);
% A_sym = subs(jacobian(dX, X),{x_sym(t),beta_sym(t),gamma_sym(t)},{x,beta,gamma});
% B_sym = subs(jacobian(dX, U),{x_sym(t),beta_sym(t),gamma_sym(t)},{x,beta,gamma});
syms phi theta d_phi d_theta d2_phi d2_theta

A_test = subs(A_sym,{beta,d_beta,d2_beta,gamma,d_gamma,d2_gamma},{theta,d_theta,d2_theta,phi,d_phi,d2_phi});
B_test = subs(B_sym,{beta,d_beta,d2_beta,gamma,d_gamma,d2_gamma},{theta,d_theta,d2_theta,phi,d_phi,d2_phi});
N_pb_test = subs(N_pb,{beta_sym,d_beta,d2_beta,gamma_sym,d_gamma,d2_gamma},{theta,d_theta,d2_theta,phi,d_phi,d2_phi});
P_pb_test = subs(P_pb,{beta_sym,d_beta,d2_beta,gamma_sym,d_gamma,d2_gamma},{theta,d_theta,d2_theta,phi,d_phi,d2_phi});
N_wp_test = subs(N_wp,{beta_sym,d_beta,d2_beta,gamma_sym,d_gamma,d2_gamma},{theta,d_theta,d2_theta,phi,d_phi,d2_phi});
P_wp_test = subs(P_wp,{beta_sym,d_beta,d2_beta,gamma_sym,d_gamma,d2_gamma},{theta,d_theta,d2_theta,phi,d_phi,d2_phi});
d2_x_test = subs(model_solve.d2_x,{beta,d_beta,d2_beta,gamma,d_gamma,d2_gamma},{theta,d_theta,d2_theta,phi,d_phi,d2_phi});
d2_beta_test = subs(model_solve.d2_beta,{beta,d_beta,d2_beta,gamma,d_gamma,d2_gamma},{theta,d_theta,d2_theta,phi,d_phi,d2_phi});
d2_gamma_test = subs(model_solve.d2_gamma,{beta,d_beta,d2_beta,gamma,d_gamma,d2_gamma},{theta,d_theta,d2_theta,phi,d_phi,d2_phi});
dX_test = subs(dX,{beta_sym,d_beta,d2_beta,gamma_sym,d_gamma,d2_gamma},{theta,d_theta,d2_theta,phi,d_phi,d2_phi});
save(fullfile(fileparts(mfilename("fullpath")),'ABmat'),'A_sym',"B_sym")
save(fullfile(fileparts(mfilename("fullpath")),'test_data'),'A_test',"B_test", "N_pb_test", "P_pb_test", "N_wp_test", "P_wp_test","d2_x_test", "d2_beta_test", "d2_gamma_test", "dX_test")

