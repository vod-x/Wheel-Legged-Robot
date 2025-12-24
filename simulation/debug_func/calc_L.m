function L_val = calc_L(theta1_val, theta2_val)
    syms theta1 theta2 phi1 phi2 j1x j1y
    L = evalin('base', 'L');
    phi1_val = calc_phi1(theta1_val, theta2_val);
    phi2_val = calc_phi2(theta1_val, theta2_val);
    L_val = double(subs(L, {theta1, theta2, phi1, phi2, j1x, j1y}, ...
                        {theta1_val, theta2_val, phi1_val, phi2_val, 0, 0}));
end
