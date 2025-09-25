clear
clc
count = 0;

leg_x = 0.12:0.01:0.38;
K_11 = 0.12:0.01:0.38;
K_12 = 0.12:0.01:0.38;
K_13 = 0.12:0.01:0.38;
K_14 = 0.12:0.01:0.38;
K_15 = 0.12:0.01:0.38;
K_16 = 0.12:0.01:0.38;
K_21 = 0.12:0.01:0.38;
K_22 = 0.12:0.01:0.38;
K_23 = 0.12:0.01:0.38;
K_24 = 0.12:0.01:0.38;
K_25 = 0.12:0.01:0.38;
K_26 = 0.12:0.01:0.38;


syms theta phi R L x x_b N N_f T T_p m_w I_w m_p I_p I_M g l M N_M P_M L_M
syms theta_dot x_dot phi_dot theta_ddot x_ddot phi_ddot

N_M = M*(x_ddot+(L+L_M)*theta_ddot*cos(theta)-(L+L_M)*theta_dot^2*sin(theta)-l*phi_ddot*cos(phi)+l*phi_dot^2*sin(phi));
P_M = M*(g-(L+L_M)*theta_ddot*sin(theta)-(L+L_M)*theta_dot^2*cos(theta)-l*phi_ddot*sin(phi)-l*phi_dot^2*cos(phi));
N = m_p*(x_ddot+L*theta_ddot*cos(theta)-L*theta_dot^2*sin(theta))+N_M;
P = m_p*(g-L*theta_dot^2*cos(theta)-L*theta_ddot*sin(theta))+P_M;

eqA = x_ddot == (T-N*R)/(I_w/R+m_w*R);
eqB = I_p*theta_ddot == (P*L+P_M*L_M)*sin(theta)-(N*L+N_M*L_M)*cos(theta) - T + T_p;
eqC = I_M*phi_ddot == T_p + N_M*l*cos(phi) + P_M*l*sin(phi);

model_sol = solve([eqA eqB eqC],[theta_ddot,x_ddot,phi_ddot]);
X = [x,x_dot,phi,phi_dot,theta,theta_dot].';
dX = [x_dot,simplify(model_sol.x_ddot),...
    phi_dot,simplify(model_sol.phi_ddot),...
    theta_dot,simplify(model_sol.theta_ddot)].';

U = [T T_p].';
A_sym = jacobian(dX,X);
B_sym = jacobian(dX,U);

for LengthLeg=0.12:0.01:0.38

    N_M = M*(x_ddot+(L+L_M)*theta_ddot*cos(theta)-(L+L_M)*theta_dot^2*sin(theta)-l*phi_ddot*cos(phi)+l*phi_dot^2*sin(phi));
    P_M = M*(g-(L+L_M)*theta_ddot*sin(theta)-(L+L_M)*theta_dot^2*cos(theta)-l*phi_ddot*sin(phi)-l*phi_dot^2*cos(phi));
    N = m_p*(x_ddot+L*theta_ddot*cos(theta)-L*theta_dot^2*sin(theta))+N_M;
    P = m_p*(g-L*theta_dot^2*cos(theta)-L*theta_ddot*sin(theta))+P_M;
    
    eqA = x_ddot == (T-N*R)/(I_w/R+m_w*R);
    eqB = I_p*theta_ddot == (P*L+P_M*L_M)*sin(theta)-(N*L+N_M*L_M)*cos(theta) - T + T_p;
    eqC = I_M*phi_ddot == T_p + N_M*l*cos(phi) + P_M*l*sin(phi);
    
    model_sol = solve([eqA eqB eqC],[theta_ddot,x_ddot,phi_ddot]);
    X = [x,x_dot,phi,phi_dot,theta,theta_dot].';
    dX = [x_dot,simplify(model_sol.x_ddot),...
        phi_dot,simplify(model_sol.phi_ddot),...
        theta_dot,simplify(model_sol.theta_ddot)].';
    
    U = [T T_p].';
    % A_sym = jacobian(dX,X);
    % B_sym = jacobian(dX,U);
    count = count + 1;
    % 结构参数定义
    % 非变量
    wh_Leg = 0.09; %摆杆宽度
    % LengthLeg = 0.4;%摆杆长度
    m_body = 6.0; %车身质量
    wh_body = 0.2;%上车体高度
    L_body = 0.37; %上车体长度
    
    %变量
    R = 0.075; %车轮的半径
    m_w = 1.15; %驱动轮转子质量
    I_w = 0.0015056;%m_w*R^2/2; %驱动轮转动惯量 0.00104 0.0004656
    l = -0.01; %车体质心到关节中点（用于计算）
    m_p = 1.2; %摆杆质量
    L_M = LengthLeg*(LengthLeg/0.38)*0.4; %摆杆中心到驱动关节
    L = LengthLeg - L_M; %摆杆中心到驱动轮
    I_p = m_p*(wh_Leg^2+LengthLeg^2)/12 + 0.00007+0.07*L*L; %摆杆转动惯量 

    M = m_body/2; %车身质量 
    I_M = M*(wh_body^2+L_body^2)/12; %车体转动惯量
    




    theta = 0.0;
    theta_dot = 0;
    phi = 0;
    phi_dot = 0;
    g = 9.71;

    
    A = double(subs(A_sym));
    B = double(subs(B_sym));
    Tc = ctrb(A,B);                     %能控性矩阵 
    if (rank(Tc)==6)                    %判断是否满秩，如果是6，则系统是可控的
    %权重矩阵 Q 的设计
    Q = 1.0*[120      0       0        0       0       0    ;    %x
             0       40      0        0       0       0    ;    %v
             0       0       9500     0       0       0    ;    %theta
             0       0       0        5       0       0    ;    %thetadot
             0       0       0        0       50       0    ;    %alpha
             0       0       0        0       0       1    ];   %alphadot
    R_juzhen = [1      0;
                 0      1.45];
    T_count = 0.002;
    if LengthLeg == 0.25
    K = lqrd(A,B,Q,R_juzhen,T_count)               %调用 lqr 函数用以求解状态反馈矩阵 K
    else
    K = lqrd(A,B,Q,R_juzhen,T_count);   
    end
    K_11(count)= K(1,1);
    K_12(count)= K(1,2);
    K_13(count)= K(1,3);
    K_14(count)= K(1,4);
    K_15(count)= K(1,5);
    K_16(count)= K(1,6);
    K_21(count)= K(2,1);
    K_22(count)= K(2,2);
    K_23(count)= K(2,3);
    K_24(count)= K(2,4);
    K_25(count)= K(2,5);
    K_26(count)= K(2,6);

    end
end

    % figure(1) %第一张图片命名为figure 1
	% plot(leg_x,K_11);  %在图figure 1 中绘制曲线
    % figure(2) %第二张图片命名为figure 2leg_x
    % plot(leg_x',K_11);  %在图figure 2 中绘制曲线
    % 

    f_11=fit(leg_x',K_11','poly2');
    f_12=fit(leg_x',K_12','poly2');
    f_13=fit(leg_x',K_13','poly2');
    f_14=fit(leg_x',K_14','poly2');
    f_15=fit(leg_x',K_15','poly2');
    f_16=fit(leg_x',K_16','poly2');
    f_21=fit(leg_x',K_21','poly2');
    f_22=fit(leg_x',K_22','poly2');
    f_23=fit(leg_x',K_23','poly2');
    f_24=fit(leg_x',K_24','poly2');
    f_25=fit(leg_x',K_25','poly2');
    f_26=fit(leg_x',K_26','poly2');

	subplot(4,4,1); 
	plot(leg_x,K_11,'-','color','b','MarkerSize',2);
	grid on    
	subplot(4,4,2);  
	plot(leg_x,K_12,'-','color','b','MarkerSize',2);
	grid on
	subplot(4,4,3);  
	plot(leg_x,K_13,'-','color','b','MarkerSize',2);
	grid on
	subplot(4,4,5);  
	plot(leg_x,K_14,'-','color','b','MarkerSize',2);
	grid on
    subplot(4,4,6); 
	plot(leg_x,K_15,'-','color','b','MarkerSize',2);
	grid on    
	subplot(4,4,7);  
	plot(leg_x,K_16,'-','color','b','MarkerSize',2);
	grid on
	subplot(4,4,9);  
	plot(leg_x,K_21,'-','color','b','MarkerSize',2);
	grid on
	subplot(4,4,10);  
	plot(leg_x,K_22,'-','color','b','MarkerSize',2);
	grid on
    subplot(4,4,11); 
	plot(leg_x,K_23,'-','color','b','MarkerSize',2);
	grid on    
	subplot(4,4,13);  
	plot(leg_x,K_24,'-','color','b','MarkerSize',2);
	grid on
	subplot(4,4,14);  
	plot(leg_x,K_25,'-','color','b','MarkerSize',2);
	grid on
	subplot(4,4,15);  
	plot(leg_x,K_26,'-','color','b','MarkerSize',2);
	grid on



