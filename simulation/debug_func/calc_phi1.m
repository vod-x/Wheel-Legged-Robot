function ret = calc_phi1(a1, a2)
    syms theta1 theta2
    phi1 = evalin('base', 'phi1');
    ret = double(subs(phi1, {theta1, theta2}, {a1, a2}));
end