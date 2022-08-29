
clear all

A_D=[0.12 0.06 0.03 0.02 0.01];	% mm
A_L=[5.39 2.69 1.35 0.90 0.45];	% mm
A_N=[1880 1.5e4 1.15e5 3.92e5 3.01e6];	

C_D=[0.0056];
C_L=[0.6];
C_N=5.92e7;

V_D=A_D*1.5;
V_L=A_L;
V_N=A_N;

% volume fraction corrections
A_N=0.75*A_N;
C_N=0.10*C_N;

A_V=sum(pi*(A_D.*A_D)*(1/4).*A_L.*A_N*(.1*.1*.1));	% ml
C_V=sum(pi*(C_D.*C_D)*(1/4).*C_L.*C_N*(.1*.1*.1));	% ml
V_V=sum(pi*(V_D.*V_D)*(1/4).*V_L.*V_N*(.1*.1*.1));	% ml

% average vessel velocity expression
% vi = 0.34*Di + 0.309
%
% this expression may need to be corrected for
% average brain flow-rates (1L/min)

A_v=0.34*A_D+0.309;
C_v=0.34*C_V+0.309;
V_v=0.34*V_V+0.309;

A_Q=pi*A_D.*A_D.*A_N.*A_v*(0.1*0.1*0.1);	% ml/s
C_Q=pi*C_D.*C_D.*C_N.*C_v*(0.1*0.1*0.1);	% ml/s
V_Q=pi*V_D.*V_D.*V_N.*V_v*(0.1*0.1*0.1);	% ml/s

% Assume the following velocity distributions
%  * Capillary plugged flow (Di between 4-20um)
%  * Laminar flow according to Re = Di*Vi*rho/mu < 2000 > 0.1
%  * Creeping flow for Re < 0.1

rho=1.06;	% g/ml or kg/L
mu=0.004;	% Ns/m2 or cP??? (0.0027-0.004 @ Hct 40%)

A_Re=A_D*(0.1).*A_v*(0.1)*rho/(mu*10);
C_Re=C_D*(0.1).*C_v*(0.1)*rho/(mu*10);
V_Re=V_D*(0.1).*V_v*(0.1)*rho/(mu*10);

