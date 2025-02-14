clc 
clear
close all

%vector de tiempo
t=0:3000;
%referencia acorde al punto de equilibrio Y0=[Y10; Y20;Y30]  Y10=0.400; Y20=0.200; Y30=0.300;
r1=[0.4*ones(1,250) 0.45*ones(1,1250) 0.38*ones(1,1000) 0.35*ones(1,501)];
r2=[0.15*ones(1,400) 0.225*ones(1,1600) 0.2*ones(1,1001)];
%r1=[0.35*ones(1,250) 0.42*ones(1,1250) 0.38*ones(1,1000) 0.47*ones(1,501)];
%r2=[0.21*ones(1,400) 0.22*ones(1,1600) 0.18*ones(1,1001)];
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

%Condiciones iniciales: niveles iniciales del tanque
x=[0.2 0.2 0.1]';

%caudales entre tanques
q13 = zeros(n,1);
q32 = zeros(n,1);
q20 = zeros(n,1);

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
    
    %actualizo los estados;niveles de los tanques
    x=xk1;
    x1(i+1)=x(1);
    x2(i+1)=x(2);
    x3(i+1)=x(3);

    %caudales entre tanques
    q13(i) = 0.5*5e-5*(x(1)-x(3))*sqrt(2*9.8*abs(x(3)-x(1)));
    q32(i) = 0.5*5e-5*(x(3)-x(2))*sqrt(2*9.8*abs(x(3)-x(2)));
    %----caudal de salida
    q20(i) = 0.675*5e-5*sqrt(2*9.8*x(2));
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


%-----caudales en las  tuberias-----
figure
subplot(3,1,1)
plot(t,q13,'k')
grid on
xlabel('Time(s)')
ylabel('q_{13}(m3/seg)')
legend('Caudal 13')

subplot(3,1,2)
plot(t,q32,'k')
grid on
xlabel('Time(s)')
ylabel('q_{32}(m3/seg)')
legend('Caudal 32')


subplot(3,1,3)
plot(t,q20,'k')
grid on
xlabel('Time(s)')
ylabel('q_{20}(m3/seg)')
legend('Caudal 20')
title('Caudal de salida')


%------animacion a partir de la dinamica-----
%Tanque animación
lt=10; %largo de la tuberia de union
at=2; %ancho de la tuberia de union
figure
l=length(t);
C1 = 5; %S=0.01564
C2 = C1;
%Creación del tanque1
x11=[0 0];
y1=[0 x1(end)+1.15*x1(end)];
x2_=[0 C1];
y2=[0 0];
x3=[C1 C1];
y3=[0 x1(end)+1];
%Creación del tanque2
x12=[C1+lt C1+lt];
y12=[0 x2(end)+1];
x22=[C1+lt C1+lt+C2];
y22=[0 0];
x32=[C1+lt+C2 C1+lt+C2];
y32=[0 x2(end)+1];

x=[0 C1 C1 0]; %para el fill
line(x11,y1,'Color','black')%,'LineWidth',2)
hold on
line(x2_,y2,'Color','black')%,'LineWidth',2)
line(x3,y3,'Color','black')%,'LineWidth',2)

x20=[C1+lt C1+lt+C2 C1+lt+C2 C1+lt]; %para el fill
line(x12,y12,'Color','black')%,'LineWidth',2)
line(x22,y22,'Color','black')%,'LineWidth',2)
line(x32,y32,'Color','black')%,'LineWidth',2)



%Tuberia de union entre los dos tanques
%xu=[C1 C1+lt C1+lt C1];
%yu=[0 0 at at];
%fill(xu,yu,'k');
%Llenado de tanque
for i=1:l
   
    nively=[0 0 x1(i) x1(i)]; %para el fill
    fill(x,nively,'b')
    hold on
    ylim([0 x1(end)+1.5])
    
    nively2=[0 0 x2(i) x2(i)];
    fill(x20,nively2,'b')
    
    pause(0.1)
   
end