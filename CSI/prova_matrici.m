m11 = 19;   %[kg]
m22 = 35;   %[kg]
m33 = 4;   %[kg]

d11 = 3;    %[kg/s]
d22 = 10;    %[kg/s]
d33 = 1;    %[kg/s]

params = [m11, m22, m33, d11, d22, d33];

tau_u_0 = 0;
tau_r_0 = 0;

u_0 = 0;
v_0 = 0;
r_0 = 0;

x_0 = 0;
y_0 = 0;
phi_0 = 0;

% TODO
Km1 = 1;
Km2 = 1;
Tm1 = 1;
Tm2 = 1;

T1 = 1;

freq_sys = 1000; %[Hz]
dT = 1/freq_sys;

P_E = [0, 0 ,0 ,0];     %[u, v, r, psi]

A = [       1-dT*d11/m11,        dT*m22/m11*P_E(3),     dT*m22/m11*P_E(2),  0;...
        -dT*m11/m22*P_E(3),         1-dT*d22/m22,       dT*m11/m22*P_E(1),  0;...
     dT*(m11-m22)/m33*P_E(2), dT*(m11-m22)/m33*P_E(1),      1-dT*d33/m33,   0;...
                0,                      0,                      dT,         1];

B = [dT/m11,    0    ;...
        0,      0    ;...
        0,    dT/m33 ;...
        0,      0    ];

C = [cos(P_E(4)), -sin(P_E(4)), 0, -P_E(1)*P_E(3)*sin(P_E(4))-P_E(2)*P_E(3)*cos(P_E(4));...
     sin(P_E(4)),  cos(P_E(4)), 0,  P_E(1)*P_E(3)*cos(P_E(4))-P_E(2)*P_E(3)*sin(P_E(4))];

D = 0;

Sys= ss(A,B,C,D);

Gs = zpk(Sys);


