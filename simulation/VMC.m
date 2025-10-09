classdef VMC < handle
    properties
    theta0, theta1, theta2,d_theta1, d_theta2
    phi1, phi2,
    j1, j2, j3, j4, j5
    interval, br1, br2, lr1, lr2, L
    M, J, R, N
    end

    methods
        function obj = VMC(interval, br1, br2, lr1, lr2)
            syms theta1(t) theta2(t) phi1(t) phi2(t)
            syms d_theta1 d_theta2
            syms theta0 L

            obj.theta1 = theta1(t);
            obj.theta2 = theta2(t);
            obj.d_theta1 = d_theta1;
            obj.d_theta2 = d_theta2;
            obj.theta0 = theta0;
            obj.phi1   = phi1(t);
            obj.phi2   = phi2(t);
            obj.L        = L;

            obj.interval = interval / 1000;
            obj.br1 = br1 / 1000;
            obj.br2 = br2 / 1000;
            obj.lr1 = lr1 / 1000;
            obj.lr2 = lr2 / 1000;

            obj.j1.x = 0;
            obj.j1.y = 0;
            obj.j2.x = obj.j1.x - obj.interval;
            obj.j2.y = obj.j1.y;

            obj.j5.x = obj.j1.x + obj.br1 * cos(theta1 );
            obj.j5.y = obj.j1.y + obj.br1 * sin(theta1);
            obj.j3.x = obj.j2.x + obj.br2 * cos(theta2);
            obj.j3.y = obj.j2.y + obj.br2 * sin(theta2); 
            
            obj.j4.x = obj.j5.x + obj.lr1 * cos(phi1);
            obj.j4.y = obj.j5.y + obj.lr1 * sin(phi1);
            
            obj.j5.dx = diff(obj.j5.x, t);
            obj.j5.dy = diff(obj.j5.y, t);
            obj.j3.dx = diff(obj.j3.x, t);
            obj.j3.dy = diff(obj.j3.y, t);
            obj.j4.dx = diff(obj.j4.x, t);
            obj.j4.dy = diff(obj.j4.y, t);
            
            d_phi1 = ((obj.j5.dx - obj.j3.dx) * cos(phi2)...
                        + (obj.j5.dy - obj.j3.dy) * sin(phi2))...
                        /(obj.lr1 * sin(phi1 - phi2));
            obj.j4.dx = subs(obj.j4.dx, diff(phi1, t), d_phi1);
            obj.j4.dy = subs(obj.j4.dy, diff(phi1, t), d_phi1);
            
            obj.j4.dx = subs(obj.j4.dx, [diff(theta1, t); diff(theta2, t)], [d_theta1; d_theta2]);
            obj.j4.dy = subs(obj.j4.dy, [diff(theta1, t); diff(theta2, t)], [d_theta1; d_theta2]);
            
            d_X = [obj.j4.dx, obj.j4.dy];
            d_Q = [d_theta1,  d_theta2];
            d_X = simplify(collect(d_X, d_Q));
            obj.J = simplify(jacobian(d_X, d_Q));

            obj.R = [ cos(theta0), sin(theta0);...
                     -sin(theta0), cos(theta0) ];
            obj.N = [1, 0;...
                     0, 1/L];
            obj.M = simplify(obj.J.'*obj.R*obj.N);             
        end

        function ret = transform(obj, theta1, theta2, d_theta1, d_theta2, F)
            j5.x = vpa(subs(obj.j5.x, obj.theta1, theta1));
            j5.y = vpa(subs(obj.j5.y, obj.theta1, theta1));
            j3.x = vpa(subs(obj.j3.x, obj.theta2, theta2));
            j3.y = vpa(subs(obj.j3.y, obj.theta2, theta2)); %#ok<*PROPLC>
            
            p = j5.y - j3.y;
            q = j5.x - j3.x;
            a = (obj.lr2 * obj.lr2) - (obj.lr1 * obj.lr1) - (p * p)...
                                           - (q * q) + (2 * q * obj.lr1);
            b = -4 * p * obj.lr1;
            c = (obj.lr2 * obj.lr2) - (obj.lr1 * obj.lr1) - (p * p)...
                                           - (q * q) - (2 * q * obj.lr1);
            z1 = (-b + sqrt(b * b - 4 * a * c)) / (2  * a);
            z2 = (-b - sqrt(b * b - 4 * a * c)) / (2  * a);
            z1 = vpa(mod(z1, 2*pi));
            z2 = vpa(mod(z2, 2*pi));
            if 2 * atan(z1) > pi/2
                phi1 = 2 * atan(z1);
            else
                phi1 = 2 * atan(z2);
            end

            p = j3.y - j5.y;
            q = j3.x - j5.x;
            a = (obj.lr1 * obj.lr1) - (obj.lr2 * obj.lr2) - (p * p)...
                                           - (q * q) + (2 * q * obj.lr2);
            b = -4 * p * obj.lr2;
            c = (obj.lr1 * obj.lr1) - (obj.lr2 * obj.lr2) - (p * p)...
                                           - (q * q) - (2 * q * obj.lr2);
            z1 = (-b + sqrt(b * b - 4 * a * c)) / (2  * a);
            z2 = (-b - sqrt(b * b - 4 * a * c)) / (2  * a);
            z1 = vpa(mod(z1, 2*pi));
            z2 = vpa(mod(z2, 2*pi));
            if 2 * atan(z1) < pi/2
                phi2 = 2 * atan(z1);
            else
                phi2 = 2 * atan(z2);
            end

            j4.x = subs(obj.j4.x, [obj.phi1, obj.theta1], [phi1, theta1]);
            j4.y = subs(obj.j4.y, [obj.phi1, obj.theta1], [phi1, theta1]);
            j4.dx = subs(obj.j4.dx, ...
                        [obj.theta1, obj.theta2, obj.d_theta1, obj.d_theta2, obj.phi1, obj.phi2], ...
                        [theta1, theta2, d_theta1, d_theta2, phi1, phi2]);
            j4.dy = subs(obj.j4.dy, ...
                        [obj.theta1, obj.theta2, obj.d_theta1, obj.d_theta2, obj.phi1, obj.phi2], ...
                        [theta1, theta2, d_theta1, d_theta2, phi1, phi2]);


            L = sqrt((j4.x + (obj.interval / 2))^2 + j4.y^2);
            dL = ((j4.x + (obj.interval / 2)) * j4.dx + j4.y * j4.dy) / L;

            theta0 = atan2(j4.y, (j4.x + obj.interval / 2));
            d_theta0 = (j4.dy * (j4.x + obj.interval / 2) - j4.y * j4.dx) / L;
            
            M = subs(obj.M, ...
            [obj.theta0, obj.theta1, obj.theta2, obj.phi1, obj.phi2, obj.L], ...
            [theta0, theta1, theta2, phi1, phi2, L]);
            
           
            ret.T = vpa(M * F);
            ret.L = vpa(L);
            ret.dL = vpa(dL);
            ret.alpha = vpa(theta0);
            ret.d_alpha = vpa(d_theta0);

        end
    
    end
end