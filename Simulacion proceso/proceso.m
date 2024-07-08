function xk1=proceso(u,x)

%Matrices A y B del sistema discreto
Ad=[0.9888    0.0001    0.0112;
    0.0001    0.9781    0.0111;
    0.0112    0.0111    0.9776];

Bd=[64.5687    0.0014;
    0.0014   64.2202;
    0.3650    0.3637];


%calculo los estados
x1_k1=Ad(1,:)*x+Bd(1,:)*u;%A11*x1(i)+A12*x2(i)+A13*x3(i)+B11*u1+B12*u2;
x2_k1=Ad(2,:)*x+Bd(2,:)*u;%A21*x1(i)+A22*x2(i)+A23*x3(i)+B21*u1+B22*u2;
x3_k1=Ad(3,:)*x+Bd(3,:)*u;%A31*x1(i)+A32*x2(i)+A33*x3(i)+B31*u1+B32*u2;

xk1=[x1_k1 x2_k1 x3_k1]';

end
