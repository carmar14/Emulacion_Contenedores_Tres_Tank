clc 
clear
close all


%referencia acorde al punto de equilibrio Y0=[Y10; Y20;Y30]  Y10=0.400; Y20=0.200; Y30=0.300;
%r1=[0.4*ones(1,250) 0.45*ones(1,1250) 0.38*ones(1,1000) 0.35*ones(1,501)];
%r2=[0.15*ones(1,400) 0.225*ones(1,1600) 0.2*ones(1,1001)];
r1=[0.4*ones(1,250) 0.45*ones(1,280) 0.38*ones(1,600) 0.35*ones(1,820) 0.48*ones(1,650)];
r2=[0.15*ones(1,400) 0.35*ones(1,200) 0.2*ones(1,850) 0.3*ones(1,500) 0.25*ones(1,650)];
%r1=[0.35*ones(1,250) 0.42*ones(1,1250) 0.38*ones(1,1000) 0.47*ones(1,501)];
%r2=[0.21*ones(1,400) 0.22*ones(1,1600) 0.18*ones(1,1001)];
%vector de tiempo
t=linspace(0,length(r2),length(r2));
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

%close all

%------animacion a partir de la dinamica-----
%Tanque animación
h_tanque = max(max(max(x1),max(x2)),max(x3)); %altura de los tanques
lt=2; %largo de la tuberia de union
at=0.05; %ancho de la tuberia de union
subplot(2,2,4)
l=length(t);
C1 = 5; %S=0.01564
C2 = C1;
C3 = C1;

t1=[0 C1 C1 0]; %para el fill
t3=[C1+lt C1+lt+C2 C1+lt+C2 C1+lt]; %para el fill
%tanque 3
t2=[C1+2*lt+C2 C1+2*lt+C2+C3 C1+2*lt+C2+C3 C1+2*lt+C2]; %para el fill

%Caudales
q13max = max(q13);
q32max = max(q32);
q20max = max(q20);
q13min = min(q13);
q32min = min(q32);
q20min = min(q20);
m1 = 1/(q13max-q13min);
m2 = 1/(q32max-q32min);
m3 = 1/(q20max-q20min);
b1 = 1-m1*q13max;
b2 = 1-m2*q32max;
b3 = 1-m3*q20max;

% q1_3=[0 C1 C1 0]; %para el fill
% q3_2=[C1+lt C1+lt+C2 C1+lt+C2 C1+lt]; %para el fill
% %tanque 3
% q2_0=[C1+2*lt+C2 C1+2*lt+C2+C3 C1+2*lt+C2+C3 C1+2*lt+C2]; %para el fill

%close all
%Tuberia de union entre los dos tanques
%xu=[C1 C1+lt C1+lt C1];
%yu=[0 0 at at];
%fill(xu,yu,'k');
%Llenado de tanque

% 2. Crear un archivo GIF vacío inicial
fig = figure;
gifFileName = 'animacion.gif';
exportgraphics(fig, gifFileName, 'Append', false);

for i=1:l
    
    subplot(2,2,1)
    plot(t(1:i),x1(1:i),'b',t(1:i),r1(1:i),'--r')
    xlabel('Time(s)')
    ylabel('l_{1}(m)')
    title('Tank Level 1')
    hold on
    grid on
    %grid minor
    subplot(2,2,2)
    plot(t(1:i),x2(1:i),'b',t(1:i),r2(1:i),'--r')
    xlabel('Time(s)')
    ylabel('l_{2}(m)')
    title('Tank Level 2')
    hold on
    grid on
    %grid minor
    subplot(2,2,3)
    plot(t(1:i),x3(1:i),'b')
    xlabel('Time(s)')
    ylabel('l_{3}(m)')
    title('Tank Level 3')
    hold on
    grid on
    %grid minor
    subplot(2,2,4)
    hold off
        
    nively=[0 0 x1(i) x1(i)]; %para el fill
    fill(t1,nively,'b','FaceAlpha',0.1)%,'EdgeColor','none')
    hold on
    ylim([0 h_tanque*1.15])
    
    nively2=[0 0 x3(i) x3(i)];
    fill(t3,nively2,'b','FaceAlpha',0.1)%,'EdgeColor','none')

    nively3=[0 0 x2(i) x2(i)];
    fill(t2,nively3,'b','FaceAlpha',0.1)%,'EdgeColor','none')

    %caudal en las tuberias
    tuberia13=[C1 C1+lt C1+lt C1];
    p1 = m1*q13(i)+b1;
    p2 = m2*q32(i)+b2;
    p3 = m3*q20(i)+b3;

    if q13(i) >=0        
        fill(tuberia13,[0 0 at at],'b','FaceAlpha',p1)%,'EdgeColor','none')
    else
        fill(tuberia13,[0 0 at at],'g','FaceAlpha',p1)
    end

    tuberia32=[C1+C2+lt C1+C2+2*lt C1+C2+2*lt C1+C2+lt];
    if q32(i) >=0        
        fill(tuberia32,[0 0 at at],'b','FaceAlpha',p2)%,'EdgeColor','none')
    else        
        fill(tuberia32,[0 0 at at],'g','FaceAlpha',abs(p2))
    end

    tuberia20=[C1+C2+C3+2*lt C1+C2+C3+3*lt C1+C2+C3+3*lt C1+C2+C3+2*lt];
    if q20(i) >=0        
        fill(tuberia20,[0 0 at at],'b','FaceAlpha',p3)%,'EdgeColor','none')
    else
        fill(tuberia20,[0 0 at at],'g','FaceAlpha',p3)
    end
  
    
    %Creación de los tanques
    %tanque 1
    
    line([0 0],[0 h_tanque*1.15],'Color','black','LineWidth',2)
    % hold on
    line([0 C1],[0 0],'Color','black','LineWidth',2)
    line([C1 C1],[0 h_tanque*1.15],'Color','black','LineWidth',2)
    %tanque 2
    
    line([C1+lt C1+lt],[0 h_tanque*1.15],'Color','black','LineWidth',2)
    line([C1+lt C1+lt+C2],[0 0],'Color','black','LineWidth',2)
    line([C1+lt+C2 C1+lt+C2],[0 h_tanque*1.15],'Color','black','LineWidth',2)    
    
    line([C1+2*lt+C2 C1+2*lt+C2],[0 h_tanque*1.15],'Color','black','LineWidth',2)
    line([C1+2*lt+C2 C1+2*lt+C2+C3],[0 0],'Color','black','LineWidth',2)
    line([C1+2*lt+C2+C3 C1+2*lt+C2+C3],[0 h_tanque*1.15],'Color','black','LineWidth',2)

    %tuberias
    %union 13
    line([C1 C1+lt],[at at],'Color','black','LineWidth',2)
    line([C1 C1+lt],[0 0],'Color','black','LineWidth',2)
    %union 32
    line([C1+C2+lt C1+C2+2*lt],[at at],'Color','black','LineWidth',2)
    line([C1+C2+lt C1+C2+2*lt],[0 0],'Color','black','LineWidth',2)
    %union 20
    line([C1+C2+C3+2*lt C1+C2+C3+3*lt],[at at],'Color','black','LineWidth',2)
    line([C1+C2+C3+2*lt C1+C2+C3+3*lt],[0 0],'Color','black','LineWidth',2)

    xlabel('Three tank system')
    ylabel('level(m)')
    title('Levels of the three tanks')
     
    % Agregar el cuadro actual al archivo GIF
    exportgraphics(fig, gifFileName, 'Append', true, 'Resolution', 150);
    pause(0.001)
   
end