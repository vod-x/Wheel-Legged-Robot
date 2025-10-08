classdef VMC_test < handle
    properties
        theta1
        theta2
        theta0
        phi1
        phi2
        d_theta1
        d_theta2
        j1
        j2
        j3
        j4
        j5
        interval
        br1
        br2
        lr1
        lr2
        M
        J
        R
        N
        L
    end
    methods
        function obj = VMC_test(interval, br1, br2, lr1, lr2)
            syms theta1(t) theta2(t) phi1(t) phi2(t)
            syms d_theta1 d_theta2
            syms theta0 L;

            obj.theta1 = theta1(t);
            obj.theta2 = theta2(t);
            obj.theta0 = theta0;
            obj.phi1   = phi1(t);
            obj.phi2   = phi2(t);
            obj.d_theta1 = d_theta1;
            obj.d_theta2 = d_theta2;
            obj.interval = interval / 1000;
            obj.br1      = br1 / 1000;
            obj.br2      = br2 / 1000; 
            obj.lr1      = lr1 / 1000;
            obj.lr2      = lr2 / 1000;
            obj.L        = L;

            obj.j1.x = 0;
            obj.j1.y = 0;
            obj.j2.x = obj.j1.x - interval;
            obj.j2.y = obj.j1.y;
            
            obj.j5.x = obj.j1.x + obj.br1 * cos(obj.theta1);
            obj.j5.y = obj.j1.y + obj.br1 * sin(obj.theta1);
            obj.j3.x = obj.j2.x + obj.br2 * cos(obj.theta2);
            obj.j3.y = obj.j2.y + obj.br2 * sin(obj.theta2); 
            
            obj.j4.x = obj.j5.x + obj.lr1 * cos(obj.phi1);
            obj.j4.y = obj.j5.y + obj.lr1 * sin(obj.phi1);
            
            obj.j5.dx = diff(obj.j5.x, t);
            obj.j5.dy = diff(obj.j5.y, t);
            obj.j3.dx = diff(obj.j3.x, t);
            obj.j3.dy = diff(obj.j3.y, t);
            obj.j4.dx = diff(obj.j4.x, t);
            obj.j4.dy = diff(obj.j4.y, t);
            
            d_phi1 = ((obj.j5.dx - obj.j3.dx) * cos(phi2)...
                        + (obj.j5.dy - obj.j3.dy) * sin(phi2))...
                        /(obj.lr1 * sin(obj.phi1 - obj.phi2));
            obj.j4.dx = subs(obj.j4.dx, diff(phi1, t), d_phi1);
            obj.j4.dy = subs(obj.j4.dy, diff(phi1, t), d_phi1);
            
            obj.j4.dx = subs(obj.j4.dx, [diff(obj.theta1, t); diff(obj.theta2, t)], [d_theta1; d_theta2]);
            obj.j4.dy = subs(obj.j4.dy, [diff(obj.theta1, t); diff(obj.theta2, t)], [d_theta1; d_theta2]);
            
            d_X = [obj.j4.dx, obj.j4.dy];
            d_Q = [d_theta1,  d_theta2];
            d_X = simplify(collect(d_X, d_Q));
            obj.J = simplify(jacobian(d_X, d_Q));

            obj.R = [ cos(obj.theta0), sin(obj.theta0);...
                     -sin(obj.theta0), cos(obj.theta0) ];
            obj.N = [1, 0;...
                     0, 1/obj.L];
            obj.M = simplify(obj.J.'*obj.R*obj.N);                     
        end
        function ret = transform(obj, a1, a2, x, y, T)
            l = sqrt((x + (obj.interval / 2))^2 + y^2);
            a0 = atan2(y, x);
            m = subs(obj.M, [obj.theta0, obj.theta1, obj.theta2, obj.L], [a0, a1, a2, l]);
            ret = m * T;

        end

    end
end