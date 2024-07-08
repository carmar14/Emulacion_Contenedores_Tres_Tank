function [u,ai1,ai2] = controlador(x,q1,q2,ai1_k1,ai2_k1)

q_max=0.0015;
q_min=0;

K1=[0.0216    0.0030   -0.0050;
    0.0029    0.0190   -0.0040];
K2=[-0.9500   -0.3200;
    -0.3000   -0.9100];
K2=1.0e-03 *K2;

%calculo el error
e1=q1-x(1);
e2=q2-x(2);

%calculo la accion de control u1 y u2
ai1=e1+ai1_k1;
ai2=e2+ai2_k1;
ui1=K2(1,1)*ai1+K2(1,2)*ai2;
ui2=K2(2,1)*ai1+K2(2,2)*ai2;
ui1=-ui1; %accion integral
ui2=-ui2; %accion integral
up1=K1(1,:)*x;%K1(1,1)*x1(i)+K1(1,2)*x2(i)+K1(1,3)*x3(i);
up2=K1(2,:)*x;%K1(2,1)*x1(i)+K1(2,2)*x2(i)+K1(2,3)*x3(i);
up1=-up1; %accion propocional
up2=-up2; %accion propocional
u1=ui1+up1; %accion de control
u2=ui2+up2; %accion de control
%Saturacion para evitar daños en los acutadores
if u1>q_max
    u1=q_max;
end

if u2>q_max
    u2=q_max;
end

if u1<q_min
    u1=q_min;
end

if u2<q_min
    u2=q_min;
end

u=[u1 u2]';


end

