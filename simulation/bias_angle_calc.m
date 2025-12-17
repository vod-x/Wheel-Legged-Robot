function [max_bias, min_bias] = bias_angle_calc(br, lr, max_angle, min_angle)
    % calculate max bias
    l = sqrt(br*br + lr*lr -2*br*lr*cos(pi-max_angle));
    max_bias = 2 * asin(lr / l * sin(pi-max_angle));
    % calculate min bias
    l = sqrt(br*br + lr*lr - 2*br*lr*cos(pi-min_angle));
    min_bias = 2 * asin(lr / l * sin(pi-min_angle));