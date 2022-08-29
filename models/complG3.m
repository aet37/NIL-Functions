
clear all

dt=1/(20*60);
tfin=48/60;		
t=[0:dt:tfin];		% units: Time (minutes)

load co2_4vals tt2 avgE2 avgE2b avgC2 avgC2b tt2
tt2=tt2/60;
avgC2i=interp1(tt2,avgC2,t);
avgC2bi=interp1(tt2,avgC2b,t);
avgE2i=interp1(tt2,avgE2,t);
avgE2bi=interp1(tt2,avgE2b,t);


% Model 1: Simple Balloon Approach
%
%  dQa/dt = kq1 * u(t) - kq2 * Qa + kq5 * du/dt
%

Qa0=50;			% units: Volume/Time (ml/min)
V0=1;			% units: Volume (ml)

kq2=1/(2*2.5/60);	% units: 1/Time
kq1=kq2*Qa0;	% units: Flow/Time
kq3=Qa0/V0;	% units: Flow/Volume = 1/Time
kq4=5.0;	% units: dimmensionless
kq5=0*25.00;	% units: dimmensionless

% Model 2: Dimmensional Equations
%
%  dRa/dt = kr1 * u(t) - kr2 * Ra
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
ust=3/60;	% start time of rectangle function (disturbance)
udur=12/60;	% duration of disturbance
uramp=1/60;	% transition duration of disturbance
u1amp=0.65;	% disturbance amplitude for model 1
u2amp=-0.67;	% disturbance amplitude for model 2

u1type=[10 1e7 200/60 0.02];
u1type=[10 1e5 180/60 0.01];
%u1type=[1];
u2type=[1];

u1=1+u1amp*mytrapezoid(t,ust,udur,uramp,u1type);
u2=1+u2amp*mytrapezoid(t,ust,udur,uramp,u2type);

%
% Solve equations in dimmensional form since they are simple
%
Q1a(1)=Qa0; 
Ra(1)=Ra0;
Q2a(1)=Qa0;
for mm=2:length(t),

  %
  % Model 1: Euler method
  %
  Q1a(mm) = Q1a(mm-1) + dt*( kq1*u1(mm-1) - kq2*Q1a(mm-1) + kq5*(u1(mm)-u1(mm-1))/dt );

  %
  % Model 2: Euler method
  %
  Ra(mm) = Ra(mm-1) + dt*( kr1*u2(mm-1) - kr2*Ra(mm-1) );
  Q2a(mm) = (Pa-P0)/Ra(mm);

end;


plot(t*60,Q1a/Q1a(1),t*60,avgC2i,t*60,avgC2bi)
ylabel('Qa'), xlabel('Time (min)'), axis('tight'), grid('on'),
legend('Model','Data','Data2')
 
