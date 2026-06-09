function displa(a)
    % 在图形窗口中显示LaTeX公式
    
    % 解析输入参数
    p = inputParser;
    addParameter(p, 'title', 'LaTeX公式显示', @ischar);
    addParameter(p, 'fontsize', 16, @isnumeric);
    addParameter(p, 'position', [0.1, 0.1, 0.8, 0.8]);
    
    % 创建图形窗口
    figure('Name',inputname(1), ...
                 'NumberTitle', 'off', ...
                 'Position', [100, 100, 600, 300]);
    
    % 创建坐标轴
    axes('Position', [0.1, 0.1, 0.8, 0.8]);
    axis off;
    
    % 显示LaTeX公式
    text(0.5, 0.5, ['$$' latex(a) '$$'], ...
         'Interpreter', 'latex', ...
         'FontSize', 16, ...
         'HorizontalAlignment', 'center', ...
         'VerticalAlignment', 'middle');
    
end