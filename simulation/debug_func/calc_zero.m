function [zero] = calc_zero(index,rad)
theta1_zero = -0.5536;
theta2_zero = 0.770;
if 1==index
    zero = theta1_zero - wrapToPi(rad);
end
if 2==index
    zero = theta2_zero - wrapToPi(rad);
end

