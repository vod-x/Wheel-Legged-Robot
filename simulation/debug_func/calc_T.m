function [T1, T2] = calc_T(theta1_val, theta2_val, F, T)
    ret= clac_T_matrix(theta1_val, theta2_val) * [F, T]';
    T1 = ret(1);
    T2 = ret(2);
    fprintf('T1 = %.6f\n', T1);
    fprintf('T2 = %.6f\n', T2);
end