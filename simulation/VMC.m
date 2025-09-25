classdef VMC < handle
    properties
        theta1
        theta2
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
    end
    methods
        function obj = VMC()
            syms theta1(t) theta2(t) phi1(t) phi2(t)
            syms d_theta1 d_theta2
            syms interval br1 br2 lr1 lr2

            obj.theta1 = theta1(t);
            obj.theta2 = theta2(t);
            obj.phi1   = phi1(t);
            obj.phi2   = phi2(t);
            obj.d_theta1 = d_theta1;
            obj.d_theta2 = d_theta2;
            obj.interval = interval;
            obj.br1      = br1;
            obj.br2      = br2; 
            obj.lr1      = lr1;
            obj.lr2      = lr2;
            
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
            obj.j4.yx = diff(obj.j4.y, t);
            
            d_theta1 =  
        end
    end
end