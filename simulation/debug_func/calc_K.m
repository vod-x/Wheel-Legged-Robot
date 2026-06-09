function K_val = calc_K(l)
    K = evalin('base', 'K');
    K_val = subs(K,sym('L0'),l);
end
