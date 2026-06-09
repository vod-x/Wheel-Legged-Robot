function T_ret = clac_T_matrix(theta1_val, theta2_val)
    syms theta1 theta2 phi1 phi2 j1x j1y L
    alpha = sym('alpha');
    T = evalin('base', 'T');
    phi1_val = calc_phi1(theta1_val, theta2_val);
    phi2_val = calc_phi2(theta1_val, theta2_val);
    alpha_val = calc_alpha(theta1_val, theta2_val);
    L_val = calc_L(theta1_val, theta2_val);
    % T_func = matlabFunction(T, 'Vars', {theta1, theta2, phi1, phi2, L});
    T_ret = double(subs(T, {theta1, theta2, phi1, phi2, j1x, j1y, alpha ,L}, ...
        {theta1_val, theta2_val, phi1_val, phi2_val, 0, 0, alpha_val, L_val}));
end