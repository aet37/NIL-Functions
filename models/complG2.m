%function [P,V,C,u,Qi,Qo]=complG2(x,uparms,params,params2fit,data)
% Usage ... [P,V,C,u,Fi,Fo]=complG2(x,uparms,params,params2fit,data)
%
% uparms = [ust udur uramp uamp]
% parms = [Pi P Po Pc Q0 V0 k1 k2 C0 alpha aa]


dt=1/(60*20);
tfin=2;		
t=[0:dt:tfin];		% units: Time (minutes)


% Model 1: Simple Balloon Approach
%
%  dQa/dt = kq1 * u(t) - kq2 * Qa
%
%  dV/dt = Qa - Qv
%  
%  Qv = kq3 * V  +  kq4 * dV/dt
%
%  Solve for Qa, Qv and V given kq1, kq2, kq3, kq4 (we know k's)
%    assuming u is a rectangular function (also known)


Qa0=50;			% units: Volume/Time (ml/min)
V0=1;			% units: Volume (ml)

kq2=1/(2/60);	% units: 1/Time
kq1=kq2*Qa0;	% units: Flow/Time
kq3=Qa0/V0;	% units: Flow/Volume = 1/Time
kq4=5.0;	% units: dimmensionless

% Model 2: Dimmensional Equations
%
%  dRa/dt = kr1 * u(t) - kr2 * Ra
%
%  C * dP/dt = ( Pa - P )/Ra - (P - Pv)/Rv
%
%  Qa = ( Pa - P )/Ra
%
%  Qv = ( P - Pv )/Rv
%
%  V = V0 + int( C , dP )   =   V0 + C * ( P - P0 )  for C constant
%
% Let:
%
%  T_hat = t * kr2
%  P_hat = ( P - Pv ) / ( Pa - Pv )
%  Ra_hat = Ra / Ra0
%    choose: Rv = Ra0
%
% Non-dimensional Equations
%
%  dRa_hat/dT = (kr1/kr2)*(1/Ra0) * u(t) - Ra_hat
%
%  dP_hat/dT = -(1/(kr2*Ra0*C))*(( 1 + Ra_hat )/Ra_hat )* ... 
%         ( P_hat - 1/( 1 + Ra_hat ) )
%
%  C is constant for now and we can assume we know k's
%

Pa=50;		% units: Pressure (mmHg)
Pv=10;		% units: Pressure (mmHg)
Pc=0;		% units: Pressure (mmHg)

P0=0.5*(Pa+Pv);		% units: Pressure (mmHg)

Ra0=(Pa-P0)/Qa0;		% units: Resistance = Pressure / Flow (mmHg/ml/min)
Rv=(P0-Pv)/Qa0;		% units: Resistance = Pressure / Flow (mmHg/ml/min)
Rv=Ra0;

kr2=1/(2/60);	% units: 1/Time
kr1=kr2*Ra0;	% units: Resistance/Time

C0=0.5*1/10;	% units: Volume/Pressure (ml/mmHg)

%
% Input Function (Rectangular, well actually Trapezoidal)
%
ust=4/60;	% start time of rectangle function (disturbance)
udur=60/60;	% duration of disturbance
uramp=1/60;	% transition duration of disturbance
u1amp=0.5;	% disturbance amplitude for model 1
u2amp=-0.67;	% disturbance amplitude for model 2

u1=1+u1amp*mytrapezoid(t,ust,udur,uramp);
u2=1+u2amp*mytrapezoid(t,ust,udur,uramp);

%
% Solve equations in dimmensional form since they are simple
%
Q1a(1)=Qa0; 
V1(1)=V0;
Ra(1)=Ra0;
P(1)=P0;
V2(1)=V0;
Q1v(1)=Qa0;
Q2a(1)=Qa0;
Q2v(1)=Qa0;
for mm=2:length(t),

  %
  % Model 1: Euler method
  %
  Q1a(mm) = Q1a(mm-1) + dt*( kq1*u1(mm-1) - kq2*Q1a(mm-1) );
  V1(mm) = V1(mm-1) + dt*(1/(1+kq4))*( Q1a(mm-1) - kq3*V1(mm-1) );
  Q1v(mm) = kq3*V1(mm) + kq4*(V1(mm)-V1(mm-1))/dt; % approximation!

  %
  % Model 2: Euler method
  %
  Ra(mm) = Ra(mm-1) + dt*( kr1*u2(mm-1) - kr2*Ra(mm-1) );
  P(mm) = P(mm-1) + dt*(1/C0)*( (Pa-P(mm-1))/Ra(mm-1) - (P(mm-1)-Pv)/Rv );
  V2(mm) = V2(mm-1) + C0*( P(mm) - P(mm-1) );
  Q2a(mm) = (Pa-P(mm))/Ra(mm);
  Q2v(mm) = (P(mm)-Pv)/Rv;

end;


plotnorm=0;
if (plotnorm),
  subplot(311)
  plot(t*60,Q1a/Qa0,t*60,Q2a/Qa0)
  ylabel('Qa'), xlabel('Time (min)'), axis('tight'), grid('on'),
  legend('Model1','Model2')
  subplot(312)
  plot(t*60,Q1v/Qa0,t*60,Q2v/Qa0)
  ylabel('Qv'), xlabel('Time (min)'), axis('tight'), grid('on'),
  subplot(313)
  plot(t*60,V1/V0,t*60,(V2/V0-1)/(1.67*kr2*Ra0*C0)+1)
  ylabel('V'), xlabel('Time (min)'), axis('tight'), grid('on'),
else,
  subplot(311)
  plot(t*60,Q1a,t*60,Q2a)
  ylabel('Qa'), xlabel('Time (min)'), axis('tight'), grid('on'),
  legend('Model1','Model2')
  subplot(312)
  plot(t*60,Q1v,t*60,Q2v)
  ylabel('Qv'), xlabel('Time (min)'), axis('tight'), grid('on'),
  subplot(313)
  plot(t*60,V1,t*60,V2)
  ylabel('V'), xlabel('Time (min)'), axis('tight'), grid('on'),
end;
 
