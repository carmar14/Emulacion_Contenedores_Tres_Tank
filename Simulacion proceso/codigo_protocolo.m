%accion integral en el tiempo k
ai1=0;
ai2=0;

%accion integral en el tiempo k-1
ai1_k1=0;
ai2_k1=0;

%Condiciones iniciales: niveles iniciales del tanque
x=[0.2 0.2 0.1]';

%Proceso con controlador
% n = tiempo
for i=1:n-1  %debería ser un while
    q1=r1; %referencias a seguir
    q2=r2; %referencias a seguir
    
    %controlador
    [u,ai1,ai2]=controlador(x,q1,q2,ai1_k1,ai2_k1);
    %actualizo
    ai1_k1=ai1;
    ai2_k1=ai2;
    
    %calculo los estados
    xk1=proceso(u,x);
    
    %actualizo los estados;niveles de los tanques
    x=xk1;
    x(1); %level T1
    x(2); %level T2
    x(3); %level T3

    %caudales entre tanques
    q13 = 0.5*5e-5*(x(1)-x(3))*sqrt(2*9.8*abs(x(3)-x(1)));
    q32 = 0.5*5e-5*(x(3)-x(2))*sqrt(2*9.8*abs(x(3)-x(2)));
    %----caudal de salida
    q20 = 0.675*5e-5*sqrt(2*9.8*x(2));
end