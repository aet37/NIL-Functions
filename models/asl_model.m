
clear all

Cwbl=1000;		% units: mmol/ml ?????
fmagw=1e-3;
Cinvbl=Cblw*fmagw;	% units: mmol

R1bl=1/1.5;		% units: 1/s
R1tiss=1/1.4;		% units: 1/s

Vlabel=1000/60;		% units: ml/s
VOLlabel=pi*(1e-1^2)*2;	% units: ml
VOLna=VOLlabel*20;

k=0.02;
Vart0=60/60;		% units: ml/s
VOLart=pi*(1e-2^2)*0.5; % units: ml


dt=1e-3;
t=[0:dt:10];

% initial conditions
A(1)=0;		% amount (moles?)
C(1)=0;		% amount (moles?)
T(1)=0;		% amount (moles?)
V(1)=0;		% amount (moles?)

% model loop
for mm=2:length(t),
  N(mm) = N(mm-1) + dt*( Cinvbl*VOLlabel*L(mm-1) - (Vlabel/VOLlabel)*N(mm-1) );
  TTTi=round((VOLtransit/Vlabel)/dt);
  A(mm) = A(mm-1) + dt*( k*(Vlabel/VOLlabel)*N(mm-1-TTTi) - (Vart(mm-1)/VOLart)*A(mm-1) - R1bl*A(mm-1) );
  C(mm) = C(mm-1) + dt*( (Vart(mm-1)/VOLart)*A(mm-1) - f(mm)*C(mm-1) + fo*T(mm-1) - (Vart/VOLcap)*C(mm-1) - R1bl*C(mm-1)  ); 
  T(mm) = T(mm-1) + dt*( f(mm)*C(mm-1) - fo*T(mm-1) - R1tiss*T(mm-1) );
end;

