%init
clear;
close all;
clc;

%define the system
A = [0 1; -1 -0.5];
n = size(A, 1);
B = [0 ;1];
p = size(B, 1);
C = [1 0; 0 1];
D = [0; 0];

%discrete system
Ts = 0.1; %the time step
sys = c2d(ss(A, B, C, D), Ts);
A = sys.A;
B = sys.B;

%system init
x0 = [100; 1]; %state init
x = x0;

u0 = 0.1; %input init
u = u0;

total_step = 150;
x_history = zeros(n, total_step);
x_history(:, 1) = x;
u_history = zeros(p, total_step);
u_history(:, 1) = u;

Q = [1 0; 0 1];
S = [1 0; 0 1];
R = 1000;

N = total_step;
p_k = S;

for k = 1:N
    F = (B'*p_k*A)/(R + B'*p_k*B);
    p_k = (A-B*F)'*p_k*(A-B*F) + (F)' * R * F + Q;
    if k == 1
        F_N = F;
    else
        F_N = [F;F_N];
    end
end

for k = 1 : total_step
    u = -F_N(total_step - k+1 ,: )*x;
    x = A * x + B * u;
    
    x_history(:, k+1) = x;
    u_history(:, k+1) = u;

end

subplot(2,1,1);
for i = 1:n
    plot(x_history(i,:));
    hold;
end
legend(num2str((1:n)', 'x %d'));
xlim([1, total_step]);
grid on;

subplot(2,1,2);
for i =1:p
    stairs(u_history(i,:))
    hold;
end
legend(num2str((1:p)', 'x %d'));
xlim([1, total_step]);
grid on;

