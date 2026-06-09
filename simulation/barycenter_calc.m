% 读取Excel数据
data = readtable('barycenter_data.xlsx', 'Range', 'A2:D38'); % 根据您的数据范围调整
% 提取中心距、X、Y、Z（注意：Excel中可能包含“X=”等字符，需转换为数值）
center = data{:, 1}/1000; % 中心距列
x_str = data{:, 2}; % X列（字符串格式，如“X = -47.869”）
y_str = data{:, 3}; % Y列
z_str = data{:, 4}; % Z列

% 将字符串转换为数值（提取“=”后的数字）
x = cellfun(@(s) str2double(s(strfind(s, '=')+1:end)), x_str);
y = cellfun(@(s) str2double(s(strfind(s, '=')+1:end)), y_str);
z = cellfun(@(s) str2double(s(strfind(s, '=')+1:end)), z_str);

% 拟合X（二次多项式）
p_x = polyfit(center, x, 2); % 2代表二次，可调整阶数
x_fit = polyval(p_x, center);

% 绘制拟合效果
figure;
subplot(2,1,1);
plot(center, x, 'o', center, x_fit, '-');
xlabel('中心距'); ylabel('X');
legend('原始数据', sprintf('拟合曲线: %.4f*c^2 + %.4f*c + %.4f', p_x(1), p_x(2), p_x(3)));
title('X vs 中心距');

% 计算拟合误差（均方根误差RMSE）
rmse_x = sqrt(mean((x - x_fit).^2));
fprintf('X拟合RMSE: %.6f\n', rmse_x);
% 拟合Y（二次多项式）
p_y = polyfit(center, y, 2);
y_fit = polyval(p_y, center);

% 绘制拟合效果
subplot(2,1,2);
plot(center, y, 'o', center, y_fit, '-');
xlabel('中心距'); ylabel('Y');
legend('原始数据', sprintf('拟合曲线: %.4f*c^2 + %.4f*c + %.4f', p_y(1), p_y(2), p_y(3)));
title('Y vs 中心距');

% 计算拟合误差
rmse_y = sqrt(mean((y - y_fit).^2));
fprintf('Y拟合RMSE: %.6f\n', rmse_y);