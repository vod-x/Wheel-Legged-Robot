%% 清理环境
clear all; close all; clc;

%% 从Excel表格数据中提取数值
% 注意：Excel中的数据格式为"X = -47.869"，需要提取数值部分
% 中心距数据
center = [147.15, 152.15, 157.15, 162.15, 167.15, 172.15, 177.15, 182.15,...
          187.15, 192.15, 197.15, 202.15, 207.15, 212.15, 217.15, 222.15,...
          227.15, 232.15, 237.15, 242.15, 247.15, 252.15, 257.15, 262.15,...
          267.15, 272.15, 277.15, 282.15, 287.15, 292.15, 297.15, 302.15,...
          307.15, 312.15, 317.15, 322.15, 327.15, 329.3]';

% X数据（提取数值部分）
x_str = {'X = -47.869', 'X = -47.795', 'X = -47.701', 'X = -47.588', 'X = -47.456', 'X = -47.308',...
         'X = -47.144', 'X = -46.964', 'X = -46.770', 'X = -46.563', 'X = -46.341', 'X = -46.107',...
         'X = -45.859', 'X = -45.599', 'X = -45.327', 'X = -45.042', 'X = -44.745', 'X = -44.436',...
         'X = -44.115', 'X = -43.782', 'X = -43.437', 'X = -43.079', 'X = -42.709', 'X = -42.326',...
         'X = -41.931', 'X = -41.522', 'X = -41.101', 'X = -40.666', 'X = -40.217', 'X = -39.754',...
         'X = -39.277', 'X = -38.785', 'X = -38.277', 'X = -37.754', 'X = -37.214', 'X = -36.657',...
         'X = -36.082', 'X = -35.830'};

% Y数据（提取数值部分）
y_str = {'Y = -48.940', 'Y = -51.708', 'Y = -54.443', 'Y = -57.147', 'Y = -59.823', 'Y = -62.474',...
         'Y = -65.101', 'Y = -67.708', 'Y = -70.295', 'Y = -72.863', 'Y = -75.415', 'Y = -77.952',...
         'Y = -80.474', 'Y = -82.982', 'Y = -85.479', 'Y = -87.963', 'Y = -90.437', 'Y = -92.901',...
         'Y = -95.356', 'Y = -97.801', 'Y = -100.23', 'Y = -102.66', 'Y = -105.08', 'Y = -107.50',...
         'Y = -109.91', 'Y = -112.31', 'Y = -114.71', 'Y = -117.10', 'Y = -119.48', 'Y = -121.87',...
         'Y = -124.24', 'Y = -126.61', 'Y = -128.98', 'Y = -131.34', 'Y = -133.70', 'Y = -136.06',...
         'Y = -138.41', 'Y = -139.42'};

% 提取X和Y的数值
x = zeros(size(x_str));
y = zeros(size(y_str));

for i = 1:length(x_str)
    % 提取X数值（去掉"X = "部分）
    x(i) = str2double(x_str{i}(5:end));
    
    % 提取Y数值（去掉"Y = "部分）
    y(i) = str2double(y_str{i}(5:end));
end

%% 计算关键参数
% Y的最大值（注意：Y值全是负数，所以最大值是绝对值最小的）
y_max = max(y);  % 应该是-48.940

% X的最大偏离值（X距离0最远的点，即|X|最大值）
% 由于X全为负，所以绝对值最大的X就是偏离最远的
x_abs = abs(x);
[x_max_deviation, x_max_idx] = max(x_abs);  % x_max_deviation应该是47.869
x_max_point = [x(x_max_idx), y(x_max_idx)];  % 最大偏离点的坐标
center_max_x = center(x_max_idx);  % 最大偏离点对应的中心距

fprintf('数据统计：\n');
fprintf('中心距范围: %.2f 到 %.2f\n', min(center), max(center));
fprintf('X值范围: %.3f 到 %.3f\n', min(x), max(x));
fprintf('Y值范围: %.3f 到 %.3f\n', min(y), max(y));
fprintf('Y最大值: %.3f\n', y_max);
fprintf('X最大偏离值: |X| = %.3f\n', x_max_deviation);
fprintf('最大偏离点: (X=%.3f, Y=%.3f)\n', x(x_max_idx), y(x_max_idx));
fprintf('对应的中心距: %.2f\n', center_max_x);

%% 创建X-Y曲线（使用插值平滑）
% 使用样条插值创建平滑曲线
num_spline_points = 1000;
center_spline = linspace(min(center), max(center), num_spline_points)';
x_spline = spline(center, x, center_spline);
y_spline = spline(center, y, center_spline);

%% 在同一张图中绘制X-Y曲线和参考直线
figure('Position', [100, 100, 1200, 800]);

% 主绘图区
hold on;
grid on;
box on;

% 1. 绘制X-Y曲线（样条插值平滑）
plot(x_spline, y_spline, 'b-', 'LineWidth', 3, 'DisplayName', 'X-Y曲线');

% 2. 绘制原始数据点（可选显示）
plot(x, y, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k', 'DisplayName', '原始数据点');

% 3. 绘制参考直线：从(0,0)到(0,Y最大值)
x_line = [0, 0];
y_line = [0, y_max];
plot(x_line, y_line, 'r-', 'LineWidth', 3, 'DisplayName', '参考直线');

% 标记参考直线的起点和终点
plot(0, 0, 'go', 'MarkerSize', 12, 'MarkerFaceColor', 'g', 'DisplayName', '参考直线起点 (0,0)');
plot(0, y_max, 'ro', 'MarkerSize', 12, 'MarkerFaceColor', 'r', 'DisplayName', sprintf('参考直线终点 (0,%.3f)', y_max));

% 4. 标注X的最大偏离点
plot(x(x_max_idx), y(x_max_idx), 'ms', 'MarkerSize', 15, 'MarkerFaceColor', 'm', 'LineWidth', 2, ...
     'DisplayName', sprintf('X最大偏离点 (|X|=%.3f)', x_max_deviation));

% 5. 添加从最大偏离点到参考直线的垂直线（显示偏离距离）
plot([x(x_max_idx), 0], [y(x_max_idx), y(x_max_idx)], 'm--', 'LineWidth', 1.5, ...
     'DisplayName', sprintf('偏离距离: %.3f', abs(x(x_max_idx))));

% 设置坐标轴标签
xlabel('X值', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Y值', 'FontSize', 14, 'FontWeight', 'bold');
title('X-Y曲线与参考直线对比图', 'FontSize', 16, 'FontWeight', 'bold');

% 设置坐标轴范围
x_limits = [min(x)-2, 2];  % 留出空间显示参考直线
y_limits = [min(y)-5, 5];  % 留出空间显示原点附近区域
xlim(x_limits);
ylim(y_limits);

% 添加图例
legend('Location', 'best', 'FontSize', 10);

% 添加网格
grid on;

% 添加坐标轴参考线
hline = refline(0, 0);  % 水平参考线（X轴）
hline.Color = [0.7 0.7 0.7];
hline.LineStyle = ':';
hline.HandleVisibility = 'off';

vline = line([0 0], ylim, 'Color', [0.7 0.7 0.7], 'LineStyle', ':');  % 垂直参考线（Y轴）
vline.HandleVisibility = 'off';

%% 添加详细标注

% 1. 参考直线标注
text(0.3, y_max/2, sprintf('参考直线\n从(0,0)到(0,%.3f)', y_max), ...
     'FontSize', 11, 'FontWeight', 'bold', 'Color', 'r', ...
     'BackgroundColor', [1 0.95 0.95], 'EdgeColor', 'r', ...
     'HorizontalAlignment', 'left');

% 2. 最大偏离点详细标注
dev_text = sprintf('X最大偏离点\n坐标: (%.3f, %.3f)\n|X| = %.3f\n中心距: %.2f\n偏离距离: %.3f', ...
                   x(x_max_idx), y(x_max_idx), x_max_deviation, center_max_x, abs(x(x_max_idx)));
text(x(x_max_idx)+1, y(x_max_idx), dev_text, ...
     'FontSize', 10, 'FontWeight', 'bold', ...
     'BackgroundColor', [1 0.95 1], 'EdgeColor', 'm', ...
     'HorizontalAlignment', 'left');

% 3. 曲线起点和终点标注
text(x(1), y(1), sprintf('起点\n中心距=%.1f', center(1)), ...
     'FontSize', 10, 'VerticalAlignment', 'top', 'HorizontalAlignment', 'right', ...
     'BackgroundColor', [0.9 1 0.9], 'EdgeColor', 'g');

text(x(end), y(end), sprintf('终点\n中心距=%.1f', center(end)), ...
     'FontSize', 10, 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'left', ...
     'BackgroundColor', [0.9 1 0.9], 'EdgeColor', 'g');

% 4. 添加箭头指示曲线方向
arrow_idx = round(length(x_spline)/3);
quiver(x_spline(arrow_idx), y_spline(arrow_idx), ...
       x_spline(arrow_idx+50)-x_spline(arrow_idx), ...
       y_spline(arrow_idx+50)-y_spline(arrow_idx), ...
       0.5, 'Color', 'b', 'LineWidth', 2, 'MaxHeadSize', 1.5);
text(x_spline(arrow_idx), y_spline(arrow_idx)+5, '中心距增加方向', ...
     'FontSize', 10, 'FontWeight', 'bold', 'Color', 'b');

% 5. 添加数据统计信息
info_text = sprintf('数据统计:\n\n中心距范围: %.1f~%.1f\nX值范围: %.3f~%.3f\nY值范围: %.3f~%.3f\n\nX最大偏离: |X|=%.3f\n最大偏离点: (%.3f, %.3f)\n对应中心距: %.1f', ...
                    min(center), max(center), min(x), max(x), min(y), max(y), ...
                    x_max_deviation, x(x_max_idx), y(x_max_idx), center_max_x);

annotation('textbox', [0.72, 0.15, 0.25, 0.25], 'String', info_text, ...
           'FontSize', 10, 'FontWeight', 'bold', ...
           'BackgroundColor', [0.95 0.95 1], 'EdgeColor', 'b', ...
           'FitBoxToText', 'on');

%% 创建带子图的综合图表
figure('Position', [150, 150, 1400, 600]);

% 子图1：X-Y曲线与参考直线
subplot(1, 3, [1, 2]);
hold on;
grid on;

% 绘制X-Y曲线
plot(x_spline, y_spline, 'b-', 'LineWidth', 3);
plot(x, y, 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');

% 绘制参考直线
plot(x_line, y_line, 'r-', 'LineWidth', 3);
plot(0, 0, 'go', 'MarkerSize', 10, 'MarkerFaceColor', 'g');
plot(0, y_max, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');

% 标注最大偏离点
plot(x(x_max_idx), y(x_max_idx), 'ms', 'MarkerSize', 12, 'MarkerFaceColor', 'm', 'LineWidth', 2);
plot([x(x_max_idx), 0], [y(x_max_idx), y(x_max_idx)], 'm--', 'LineWidth', 1.5);

% 设置坐标轴
xlabel('X值', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Y值', 'FontSize', 12, 'FontWeight', 'bold');
title('X-Y曲线与参考直线', 'FontSize', 14, 'FontWeight', 'bold');
xlim(x_limits);
ylim(y_limits);

% 添加图例
legend({'X-Y曲线', '原始数据点', '参考直线', '起点(0,0)', sprintf('终点(0,%.3f)', y_max), ...
        sprintf('X最大偏离点', x_max_deviation), '偏离距离'}, ...
       'Location', 'best', 'FontSize', 9);

% 子图2：数据表格摘要
subplot(1, 3, 3);
axis off;

% 创建表格文本
table_text = {
    '数据摘要', '', '';
    '中心距范围:', sprintf('%.1f ~ %.1f', min(center), max(center)), '';
    'X值范围:', sprintf('%.3f ~ %.3f', min(x), max(x)), '';
    'Y值范围:', sprintf('%.3f ~ %.3f', min(y), max(y)), '';
    'Y最大值:', sprintf('%.3f', y_max), '';
    'X最大偏离:', sprintf('|X| = %.3f', x_max_deviation), '';
    '最大偏离点:', sprintf('(%.3f, %.3f)', x(x_max_idx), y(x_max_idx)), '';
    '对应中心距:', sprintf('%.1f', center_max_x), '';
    '偏离距离:', sprintf('%.3f', abs(x(x_max_idx))), '';
    '数据点数:', sprintf('%d', length(center)), '';
    'Z值(常数):', '-45.887', ''
};

% 显示表格
text(0.1, 0.95, '数据摘要', 'FontSize', 12, 'FontWeight', 'bold');
for i = 2:size(table_text, 1)
    text(0.1, 0.9 - (i-1)*0.06, table_text{i, 1}, 'FontSize', 10, 'FontWeight', 'bold');
    text(0.4, 0.9 - (i-1)*0.06, table_text{i, 2}, 'FontSize', 10);
end

% 添加边框
rectangle('Position', [0.05, 0.05, 0.9, 0.9], 'EdgeColor', 'k', 'LineWidth', 1.5);

%% 输出结果摘要
fprintf('\n=== 绘图完成 ===\n');
fprintf('已在同一张图中绘制：\n');
fprintf('1. X-Y曲线（蓝色平滑曲线）\n');
fprintf('2. 参考直线（红色垂直线）从(0,0)到(0,%.3f)\n', y_max);
fprintf('3. X最大偏离点（洋红色方块）在(%.3f, %.3f)\n', x(x_max_idx), y(x_max_idx));
fprintf('4. 偏离距离线（洋红色虚线）长度: %.3f\n', abs(x(x_max_idx)));
fprintf('\n图表说明：\n');
fprintf('- X轴：X坐标值（从%.3f到%.3f）\n', min(x), max(x));
fprintf('- Y轴：Y坐标值（从%.3f到%.3f）\n', min(y), max(y));
fprintf('- 参考直线：从原点(0,0)垂直向下到Y最大值点(0,%.3f)\n', y_max);
fprintf('- 最大偏离点：X距离原点最远的点，|X|=%.3f\n', x_max_deviation);