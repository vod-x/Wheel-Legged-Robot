function [max_bias, min_bias] = bias_angle_calc(br, lr, max_angle, min_angle)
    % calculate max bias
    l = sqrt(br*br + lr*lr -2*br*lr*cos(min_angle));
    max_bias = asin(lr / l * sin(min_angle));
    % calculate min bias
    l = sqrt(br*br + lr*lr - 2*br*lr*cos(max_angle));
    min_bias = asin(lr / l * sin(max_angle));
