syms x(t) d_x(t) d2_x %基本时变变量x，d_x为其一阶导，d2_x为其二阶导
syms a b %一些常数
syms y%代求变量y

y = a*x^2 + b*x;%y与x的关系

subs(subs(diff(y,t,2),diff(x, t),d_x),diff(d_x,t),d2_x)
