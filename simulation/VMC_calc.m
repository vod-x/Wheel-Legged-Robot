function [L, d_L , alpha, d_alpha, T] = VMC_calc(interval, lr, theta1, theta2, d_theta1, d_theta2, F)

j5.x = (39*cos(theta1))/250;
j5.y = (39*sin(theta1))/250;
j3.x = (39*cos(theta2))/250 - 33/250;
j3.y = (39*sin(theta2))/250;

p = j5.y - j3.y;
q = j5.x - j3.x;
a = (lr * lr) - (lr * lr) - (p * p)...
    - (q * q) + (2 * q * lr);
b = -4 * p * lr;
c = (lr * lr) - (lr * lr) - (p * p)...
    - (q * q) - (2 * q * lr);
z1 = (-b + sqrt(b * b - 4 * a * c)) / (2  * a);
z2 = (-b - sqrt(b * b - 4 * a * c)) / (2  * a);
z1 = mod(z1, 2*pi);
z2 = mod(z2, 2*pi);
if 2 * atan(z1) > pi/2
    phi1 = 2 * atan(z1);
else
    phi1 = 2 * atan(z2);
end

p = j3.y - j5.y;
q = j3.x - j5.x;
a = (lr * lr) - (lr * lr) - (p * p)...
    - (q * q) + (2 * q * lr);
b = -4 * p * lr;
c = (lr * lr) - (lr * lr) - (p * p)...
    - (q * q) - (2 * q * lr);
z1 = (-b + sqrt(b * b - 4 * a * c)) / (2  * a);
z2 = (-b - sqrt(b * b - 4 * a * c)) / (2  * a);
z1 = mod(z1, 2*pi);
z2 = mod(z2, 2*pi);
if 2 * atan(z1) < pi/2
    phi2 = 2 * atan(z1);
else
    phi2 = 2 * atan(z2);
end

j4.x = (201*cos(phi1))/1000 + (39*cos(theta1))/250;
j4.y = (201*sin(phi1))/1000 + (39*sin(theta1))/250;
j4.dx = - (39*d_theta1*sin(theta1))/250 - (sin(phi1)*(sin(phi2)*((39*d_theta1*cos(theta1))/250 - (39*d_theta2*cos(theta2))/250) - cos(phi2)*((39*d_theta1*sin(theta1))/250 - (39*d_theta2*sin(theta2))/250)))/sin(phi1 - phi2);
j4.dy = (39*d_theta1*cos(theta1))/250 + (cos(phi1)*(sin(phi2)*((39*d_theta1*cos(theta1))/250 - (39*d_theta2*cos(theta2))/250) - cos(phi2)*((39*d_theta1*sin(theta1))/250 - (39*d_theta2*sin(theta2))/250)))/sin(phi1 - phi2);
L = sqrt((j4.x + (interval / 2))^2 + j4.y^2);
d_L = ((j4.x + (interval / 2)) * j4.dx + j4.y * j4.dy) / L;

alpha = atan2(j4.y, (j4.x + interval / 2));
d_alpha = (j4.dy * (j4.x + interval / 2) - j4.y * j4.dx) / L;

M = [-(39*sin(alpha + phi2)*sin(phi1 - theta1))/(250*sin(phi1 - phi2)),  (39*cos(alpha + phi2)*sin(phi1 - theta1))/(250*L*sin(phi1 - phi2));...
    (39*sin(alpha + phi1)*sin(phi2 - theta2))/(250*sin(phi1 - phi2)), -(39*cos(alpha + phi1)*sin(phi2 - theta2))/(250*L*sin(phi1 - phi2))];

T = M * F;
