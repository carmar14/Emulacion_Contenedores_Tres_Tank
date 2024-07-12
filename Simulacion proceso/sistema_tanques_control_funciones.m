clc 
clear
close all

%vector de tiempo
t=0:3000;
%referencia acorde al punto de equilibrio Y0=[Y10; Y20;Y30]  Y10=0.400; Y20=0.200; Y30=0.300;
r1=[0.4*ones(1,250) 0.45*ones(1,1250) 0.4*ones(1,1000) 0.45*ones(1,501)];
r2=[0.2*ones(1,400) 0.225*ones(1,1600) 0.2*ones(1,1001)];
r1=[0.35*ones(1,250) 0.42*ones(1,1250) 0.38*ones(1,1000) 0.47*ones(1,501)];
r2=[0.21*ones(1,400) 0.22*ones(1,1600) 0.18*ones(1,1001)];
t=t';
r1=r1'; %vector columna ref 1
r2=r2'; %vector columna ref 2

[n m]=size(r1); % n vector de tiempos en muestras

%Estados en el tiempo k
x1=zeros(n,1);
x2=zeros(n,1);
x3=zeros(n,1);

%Estados en el tiempo k+1
x1_k1=zeros(n,1);
x2_k1=zeros(n,1);
x3_k1=zeros(n,1);

%accion integral en el tiempo k
ai1=0;
ai2=0;

%accion integral en el tiempo k-1
ai1_k1=0;
ai2_k1=0;

%Condiciones iniciales
x=[0 0 0]';


%Proceso con controlador
for i=1:n-1
    q1=r1(i);
    q2=r2(i);
    
    %controlador
    [u,ai1,ai2]=controlador(x,q1,q2,ai1_k1,ai2_k1);
    %actualizo
    ai1_k1=ai1;
    ai2_k1=ai2;
    
    %calculo los estados
    xk1=proceso(u,x);
    
    %actualizo los estados
    x=xk1;
    x1(i+1)=x(1);
    x2(i+1)=x(2);
    x3(i+1)=x(3);
end

plot(t,x1,'b',t,r1,'--r')
grid on
xlabel('Time(s)')
ylabel('l_{1}(m)')
legend('Level 1','q_{1}(m)')
title('Tank Level 1')
figure
plot(t,x2,'b',t,r2,'--r')
grid on
xlabel('Time(s)')
ylabel('l_{2}(m)')
legend('Level 2','q_{2}(m)')
title('Tank Level 2')
figure
plot(t,x3,'b')
grid on
xlabel('Time(s)')
ylabel('l_{3}(m)')
title('Tank Level 3')

%-----------
figure
subplot(3,1,1)
plot(t,x1,'b',t,r1,'--r')
grid on
xlabel('Time(s)')
ylabel('l_{1}(m)')
legend('Level 1','q_{1}(m)')
title('Tank Level 1')
subplot(3,1,2)
plot(t,x2,'b',t,r2,'--r')
grid on
xlabel('Time(s)')
ylabel('l_{2}(m)')
legend('Level 2','q_{2}(m)')
title('Tank Level 2')
subplot(3,1,3)
plot(t,x3,'b')
grid on
xlabel('Time(s)')
ylabel('l_{3}(m)')
title('Tank Level 3')