function alpha_val = calc_alpha(theta1_val, theta2_val)
    syms theta1 theta2 phi1 phi2 j1x j1y
    alpha = evalin('base', 'alpha');
    phi1_val = calc_phi1(theta1_val, theta2_val);
    phi2_val = calc_phi2(theta1_val, theta2_val);
    alpha_val = double(subs(alpha, {theta1, theta2, phi1, phi2, j1x, j1y}, ...
                        {theta1_val, theta2_val, phi1_val, phi2_val, 0, 0}));
end