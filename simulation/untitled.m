%% 理想密闭环境温度控制系统仿真
% 被控对象：环境温度
% 执行器：陶瓷加热片（功率输入）
% 控制器：一阶PID

clear; clc; close all;

%% 系统参数设置
% 环境热力学参数
C = 100;       % 环境热容 (J/°C)
R = 1;        % 热阻 (°C/W)
T_out = 20;     % 外界环境温度 (°C)
T0 = 25;        % 初始环境温度 (°C)

% 陶瓷加热片参数
P_max = 60;   % 加热片最大功率 (W)
P_min = 0;      % 加热片最小功率 (W)

% 控制器参数（一阶PID）
Kp = 100;        % 比例增益
Ki = 2;         % 积分增益
Kd = 300;       % 微分增益
tau_d = 0.1;    % 微分时间常数

% 仿真参数
T_sim = 300;    % 总仿真时间 (s)
dt = 0.1;       % 采样时间 (s)
t = 0:dt:T_sim; % 时间向量
N = length(t);  % 仿真步数

%% 系统初始化
% 状态变量初始化
T = zeros(1, N);        % 环境温度
T(1) = T0;              % 初始温度
P_heat = zeros(1, N);   % 加热功率
e = zeros(1, N);        % 误差
e_int = 0;              % 误差积分
e_deriv = 0;            % 误差微分
e_deriv_filt = 0;       % 滤波后的误差微分

% 设定点（温度参考轨迹）
T_setpoint = zeros(1, N);
% 阶跃响应测试：在100秒时从25°C切换到40°C
T_setpoint(1:find(t>=100,1)) = 25;
T_setpoint(find(t>=100,1):end) = 40;

%% 主仿真循环
for k = 1:N-1
    % 计算当前误差
    e(k) = T_setpoint(k) - T(k);
    
    % PID控制器计算（一阶微分滤波）
    % 比例项
    P_term = Kp * e(k);
    
    % 积分项（防止积分饱和）
    e_int = e_int + e(k) * dt;
    I_term = Ki * e_int;
    
    % 微分项（一阶滤波）
    if k > 1
        e_deriv = (e(k) - e(k-1)) / dt;
    end
    e_deriv_filt = e_deriv_filt + (e_deriv - e_deriv_filt) * dt / (tau_d + dt);
    D_term = Kd * e_deriv_filt;
    
    % 总控制输出
    u = P_term + I_term + D_term;
    
    % 功率限制
    P_heat(k) = max(min(u, P_max), P_min);
    
    % 系统动力学：能量平衡方程
    % C * dT/dt = P_heat - (T - T_out)/R
    dT_dt = (P_heat(k) - (T(k) - T_out)/R) / C;
    T(k+1) = T(k) + dT_dt * dt;
end

% 最后一步的控制计算
e(N) = T_setpoint(N) - T(N);
P_heat(N) = P_heat(N-1);

%% 结果可视化
figure('Position', [100, 100, 1200, 800]);

% 子图1：温度响应
subplot(3,2,[1,2]);
plot(t, T_setpoint, 'r--', 'LineWidth', 2, 'DisplayName', '设定温度');
hold on;
plot(t, T, 'b-', 'LineWidth', 2, 'DisplayName', '实际温度');
grid on;
xlabel('时间 (s)');
ylabel('温度 (°C)');
title('温度响应');
legend('Location', 'best');
ylim([20, 45]);

% 子图2：加热功率
subplot(3,2,3);
plot(t, P_heat, 'g-', 'LineWidth', 2);
grid on;
xlabel('时间 (s)');
ylabel('功率 (W)');
title('加热功率');
ylim([0, P_max*1.1]);

% 子图3：控制误差
subplot(3,2,4);
plot(t, e, 'm-', 'LineWidth', 2);
grid on;
xlabel('时间 (s)');
ylabel('误差 (°C)');
title('控制误差');

% 子图4：PID各项贡献
subplot(3,2,5);
P_terms = Kp * e;
I_terms = Ki * cumtrapz(e) * dt;
D_terms = zeros(1, N);
for k = 2:N
    e_deriv_temp = (e(k) - e(k-1)) / dt;
    if k == 2
        D_terms(k) = Kd * e_deriv_temp;
    else
        D_terms(k) = D_terms(k-1) + (e_deriv_temp - D_terms(k-1)/Kd) * dt / (tau_d + dt) * Kd;
    end
end

plot(t, P_terms, 'r-', 'LineWidth', 1.5, 'DisplayName', '比例项');
hold on;
plot(t, I_terms, 'g-', 'LineWidth', 1.5, 'DisplayName', '积分项');
plot(t, D_terms, 'b-', 'LineWidth', 1.5, 'DisplayName', '微分项');
grid on;
xlabel('时间 (s)');
ylabel('控制量');
title('PID各项贡献');
legend;

% 子图6：性能指标
subplot(3,2,6);
% 计算性能指标
IAE = trapz(t, abs(e));     % 绝对误差积分
ISE = trapz(t, e.^2);      % 平方误差积分
ITAE = trapz(t, t.*abs(e)); % 时间加权绝对误差积分

performance_data = [IAE, ISE, ITAE];
performance_labels = {'IAE', 'ISE', 'ITAE'};
bar(performance_data);
set(gca, 'XTickLabel', performance_labels);
ylabel('性能指标值');
title('控制系统性能指标');
grid on;

% 在图中显示数值
for i = 1:length(performance_data)
    text(i, performance_data(i), sprintf('%.1f', performance_data(i)), ...
         'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom');
end

%% 系统阶跃响应分析
% 在稳定后分析系统性能
settling_index = find(t >= 200, 1);  % 200秒后系统基本稳定
steady_state_error = mean(e(settling_index:end));
overshoot = max(T) - T_setpoint(end);
if overshoot < 0
    overshoot = 0;
end

% 计算调节时间（进入±2%误差带的时间）
target_range = 0.02 * (T_setpoint(end) - T_setpoint(1));
settling_time_index = find(abs(T - T_setpoint(end)) <= target_range, 1);
if ~isempty(settling_time_index)
    settling_time = t(settling_time_index) - 100;  % 从设定点变化开始计算
else
    settling_time = T_sim;
end

fprintf('=== 系统性能分析 ===\n');
fprintf('稳态误差: %.3f °C\n', steady_state_error);
fprintf('超调量: %.3f °C\n', overshoot);
fprintf('调节时间: %.1f 秒\n', settling_time);
fprintf('IAE: %.1f\n', IAE);
fprintf('ISE: %.1f\n', ISE);
fprintf('ITAE: %.1f\n', ITAE);

%% 参数敏感性分析（可选）
% 分析不同PID参数对系统性能的影响
if false  % 设置为true运行参数分析
    figure('Position', [100, 100, 1000, 600]);
    
    Kp_values = [25, 50, 100];
    colors = ['r', 'g', 'b'];
    
    for i = 1:length(Kp_values)
        % 重新仿真（简化版本）
        [T_test, ~, ~] = simulate_temperature_control(Kp_values(i), Ki, Kd, tau_d, T_sim, dt);
        
        subplot(2,1,1);
        plot(t, T_test, 'Color', colors(i), 'LineWidth', 2, ...
             'DisplayName', sprintf('Kp=%.0f', Kp_values(i)));
        hold on;
        
        subplot(2,1,2);
        plot(t, T_setpoint - T_test, 'Color', colors(i), 'LineWidth', 2, ...
             'DisplayName', sprintf('Kp=%.0f', Kp_values(i)));
        hold on;
    end
    
    subplot(2,1,1);
    plot(t, T_setpoint, 'k--', 'LineWidth', 2, 'DisplayName', '设定值');
    grid on; legend; title('不同Kp值的温度响应'); ylabel('温度 (°C)');
    
    subplot(2,1,2);
    grid on; legend; title('不同Kp值的控制误差'); ylabel('误差 (°C)'); xlabel('时间 (s)');
end

%% 辅助函数：参数化仿真
function [T, P_heat, e] = simulate_temperature_control(Kp, Ki, Kd, tau_d, T_sim, dt)
    % 简化的仿真函数，用于参数分析
    
    % 固定系统参数
    C = 1000; R = 0.1; T_out = 20; T0 = 25;
    P_max = 1000; P_min = 0;
    
    t = 0:dt:T_sim;
    N = length(t);
    
    T = zeros(1, N); T(1) = T0;
    P_heat = zeros(1, N);
    e = zeros(1, N);
    
    e_int = 0; e_deriv_filt = 0;
    
    % 设定点
    T_setpoint = 25 * ones(1, N);
    T_setpoint(t >= 100) = 40;
    
    for k = 1:N-1
        e(k) = T_setpoint(k) - T(k);
        
        % PID控制
        P_term = Kp * e(k);
        e_int = e_int + e(k) * dt;
        I_term = Ki * e_int;
        
        if k > 1
            e_deriv = (e(k) - e(k-1)) / dt;
            e_deriv_filt = e_deriv_filt + (e_deriv - e_deriv_filt) * dt / (tau_d + dt);
        end
        D_term = Kd * e_deriv_filt;
        
        u = P_term + I_term + D_term;
        P_heat(k) = max(min(u, P_max), P_min);
        
        dT_dt = (P_heat(k) - (T(k) - T_out)/R) / C;
        T(k+1) = T(k) + dT_dt * dt;
    end
    
    e(N) = T_setpoint(N) - T(N);
    P_heat(N) = P_heat(N-1);
end