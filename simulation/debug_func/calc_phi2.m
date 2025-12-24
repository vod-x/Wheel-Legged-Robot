function ret = calc_phi2(a1, a2)
    syms theta1 theta2
    phi2 = evalin('base', 'phi2');
    ret = double(subs(phi2, {theta1, theta2}, {a1, a2}));
end