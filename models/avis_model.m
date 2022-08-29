
clear all


% model issues
%  * the expression of the volume (diameter + compliance) not 
%    compliance only
%  * the flows in the arteriole-capillary of interest is conflicting
%    because we need to satisfy dV/dt so that Qart=Qcap in steady-state
%    but because of the volume fractions we may want to modify these
%     - fraction of the arteriole blood makes it to the
%       capillary unit of interest
%     - match the length to satisfy the desired volume
%


% conversion factors
cm2m=1e-2;
m2cm=1/cm2m;
mmHg2Pa=133.32;
Pa2mmHg=1/133.32;
ml2m3=1e-6;
m32ml=1/ml2m3;

% physiological constants
L0=50;			% mol

Qartle=2.0*ml2m3;	% m3/s
Vartle=1.0*ml2m3;
Lartle=11.8*cm2m;

Qcap=0.5*ml2m3;		% m3/s
Vcap=0.5*ml2m3;
Lcap=9.4*cm2m;

Qtiss=0.1*ml2m3;	% ml/s
Vtiss=96*ml2m3;		% ml

% Pm and Vcap need to be modified
Pi=80*mmHg2Pa;
Pm=40*mmHg2Pa;
Po=20*mmHg2Pa;

Ceq_artle=3e-10;

% other constants
R1bl=1/0.8;		% 1/s
R1tiss=1/0.8;		% 1/s

% simulation computations
mu=0.004;					% ???
Req_artle=(Pi-Pm)/Qartle;			% ???
Deq_artle=(128*mu*Lartle/(pi*Req_artle))^(1/4);	% m
Req_cap=(Pm-Po)/Qcap;				% ???
Deq_cap=(128*mu*Lcap/(pi*Req_cap))^(1/4);	% m
Nartle=round(Vartle/(pi*((Deq_artle/2)^2)*Lartle));
Ncap=round(Vcap/(pi*((Deq_cap/2)^2)*Lcap));

% perfusion rates ??? 
Qart=Qartle;		% m3/s
Vart=Vartle;
f=Qtiss/Vcap;
fo=Qtiss/Vtiss;
%f=0.1;
%fo=0;

% time vector
dt=0.01;		% s
T=44;			% s
t=[0:dt:T];

% flow time scale computations
TR=4;
nTRs=floor(t(end)/TR);
TRi=find(t==TR);
TI=0.8;
TIs=([1:nTRs]-1)*TR+TI;
for mm=1:nTRs,
  TIi(mm)=find((t>=(TIs(mm)-1e-6*dt))&(t<(TIs(mm)+1e-6*dt))); 
end;

% label input function
L=zeros(size(t));
for mm=1:nTRs,
  L=L+L0*exp(-(t-(mm-1)*TR)*R1bl).*(t>=((mm-1)*TR)).*(t<(mm*TR));
end;

% flow input function
u=mytrapezoid(t,10,20,0.4);
ytau=2; yamp=(1.1+1)^(0.25)-1;

% simulation
Vartle(1)=Vartle;
A(1)=0; A1(1)=0;
C(1)=0;
T(1)=0;
y(1)=0;
for mm=2:length(t),

  y(mm) = y(mm-1) + (dt/ytau)*( u(mm-1) - y(mm-1) );
  
  Deq_artle(mm-1) = Deq_artle(1)*(1+yamp*y(mm-1));
  Req_artle(mm-1) = Req_artle(1)*((Deq_artle(1)^4)/(Deq_artle(mm-1)^4));

  kac=Qcap(1)/Qartle(1);	% hummm ???
  Qartle(mm-1) = ( Pi - Pm(mm-1) )/Req_artle(mm-1);
  Qcap(mm-1) = ( Pm(mm-1) - Po )/Req_cap;
  Pm(mm) = Pm(mm-1) + (dt/Ceq_artle)*( kac*Qartle(mm-1) - Qcap(mm-1) );
  %Vartle(mm) = Vartle(mm-1) + Ceq_artle*(Pm(mm) - Pm(mm-1)) + ( Vartle(1)*((Deq_artle(mm-1)/Deq_artle(1))^2) - Vartle(1) );
  %Vartle(mm) = Ceq_artle*(Pm(mm) - Pm(mm-1)) + Vartle(1)*((Deq_artle(mm-1)/Deq_artle(1))^2);
  Vartle(mm) = Vartle(mm-1) + Ceq_artle*( Pm(mm) - Pm(mm-1) );

  kk=Qartle(mm-1)/Qartle(1);	% ok assumption
  A(mm) = A(mm-1) + dt*( kk*(Qart/Vart)*L(mm-1) - (Qartle(mm-1)/Vartle(mm-1))*A(mm-1) - R1bl*A(mm-1)  );

  C(mm) = C(mm-1) + dt*( kac*(Qartle(mm-1)/Vartle(mm-1))*A(mm-1) - f*C(mm-1) + fo*T(mm-1) - (Qcap(mm-1)/Vcap)*C(mm-1) - R1bl*C(mm-1) );

  T(mm) = T(mm-1) + dt*( f*C(mm-1) - fo*T(mm-1) );

  %CT(mm) = CT(mm-1) + dt*( (Qartle(mm-1)/Vartle(mm-1))*A(mm-1) - (Qcaptiss(mm-1)/Vcaptiss)*CT*(mm-1) - R1tiss*CT(mm-1) );
  A1(mm) = A1(mm-1) + dt*( kk*(Qart/Vart)*L0 - (Qartle(mm-1)/Vartle(mm-1))*A1(mm-1) );

  MTTart=Vart/Qart;
  MTTartle(mm-1) = Vartle(mm-1)/Qartle(mm-1);
  MTTcap(mm-1) = Vcap/Qcap(mm-1);

  if (rem(t(mm),TR)==0),
    A(mm)=0; A1(mm)=0;
    C(mm)=0;
    T(mm)=0;
  end;

end;
Deq_artle(mm)=Deq_artle(mm-1);
Req_artle(mm)=Req_artle(mm-1);
Qartle(mm)=Qartle(mm-1);
Qcap(mm)=Qcap(mm-1);
MTTartle(mm)=MTTartle(mm-1);
MTTcap(mm)=MTTcap(mm-1);

AVIS=A+C+T;
AVISi=A(TIi)+C(TIi)+T(TIi);
AVIS2i=C(TIi)+T(TIi);


figure(1)
subplot(211)
plot(t(1:TRi),[L(1:TRi)' A(1:TRi)' C(1:TRi)' T(1:TRi)'])
xlabel('Time (s)')
ylabel('AVIS Signal')
legend('Input','Arterial','Capillary','Tissue')
title('Baseline and Activation Uptake')
dofontsize(15), fatlines, grid('on'), axis('tight'),
subplot(212)
TRi2=[6*(TRi-1)+1:7*(TRi-1)+1];
plot(t(TRi2),[L(TRi2)' A(TRi2)' C(TRi2)' T(TRi2)'])
xlabel('Time (s)')
ylabel('AVIS Signal')
legend('Input','Arterial','Capillary','Tissue')
dofontsize(15), fatlines, grid('on'), axis('tight'),

figure(2)
subplot(211)
plot(t(1:TRi),[A(1:TRi)'+C(1:TRi)'+T(1:TRi)'],t(TRi2)-t(TRi2(1)),[A(TRi2)'+C(TRi2)'+T(TRi2)'])
xlabel('Time (s)')
ylabel('AVIS Signal')
legend('Baseline','Activation',4)
dofontsize(15), fatlines, grid('on'), axis('tight'),
subplot(212)
plot(t(1:TRi),[C(1:TRi)'+T(1:TRi)'],t(TRi2)-t(TRi2(1)),[C(TRi2)'+T(TRi2)'])
xlabel('Time (s)')
ylabel('AVIS Signal w/Sup')
legend('Baseline','Activation',4)
dofontsize(15), fatlines, grid('on'), axis('tight'),
t(find([A(1:TRi)'+C(1:TRi)'+T(1:TRi)']==max([A(1:TRi)'+C(1:TRi)'+T(1:TRi)']))),
t(find([A(TRi2)'+C(TRi2)'+T(TRi2)']==max([A(TRi2)'+C(TRi2)'+T(TRi2)']))),

figure(3)
subplot(211)
plot(t(1:TRi),-[A(1:TRi)'+C(1:TRi)'+T(1:TRi)']+[A(TRi2)'+C(TRi2)'+T(TRi2)'],t(1:TRi),-[C(1:TRi)'+T(1:TRi)']+[C(TRi2)'+T(TRi2)'])
xlabel('Time (s)')
ylabel('AVIS Signal Act-Base')
legend('Regular','w/Sup')
dofontsize(15), fatlines, grid('on'), axis('tight'),
subplot(212)
plot(t(1:TRi),[A(1:TRi)'],t(TRi2)-t(TRi2(1)),[A(TRi2)'])
xlabel('Time (s)')
ylabel('AVIS Signal Reg-Sup')
legend('Baseline','Activation')
dofontsize(15), fatlines, grid('on'), axis('tight'),

figure(4)
subplot(211)
plot(t,Vartle*m32ml)
ylabel('Volume (ml)')
xlabel('Time (s)')
legend('Arterial',2)
dofontsize(15), fatlines, grid('on'), axis('tight'),
subplot(212)
plot(t,Qartle*m32ml,t,Qcap*m32ml)
ylabel('Flow (ml/s)')
xlabel('Time (s)')
legend('Arterial','Capillary',2)
dofontsize(15), fatlines, grid('on'), axis('tight'),

figure(5)
plot(t,A+C+T,t,A,t,C,t,T,t,L)
xlabel('Time (s)')
ylabel('Signal')
legend('AVIS','Arterial','Capillary','Tissue','Input')

figure(6)
subplot(211)
plot(TIs,AVISi/AVISi(1),TIs,AVIS2i/AVIS2i(1),TIs,A(TIi)/A(TIi(1)))
ylabel('AVIS Signal Change')
xlabel('Time (s)')
legend('AVIS','AVIS w/sup','Artle only',2)
dofontsize(15), fatlines, grid('on'), axis('tight'),
subplot(212)
plot(t(TIi),Vartle(TIi)/Vartle(1),t(TIi),Qartle(TIi)/Qartle(1))
ylabel('Signal Change')
xlabel('Time (s)')
legend('Art Volume','Art Flow',2)
dofontsize(15), fatlines, grid('on'), axis('tight'),

figure(7)
subplot(211)
plot(t(1:TRi),A1(1:TRi),t(TRi2)-t(TRi2(1)),A1(TRi2))
ylabel('Arterial Tag (mmol)')
legend('Baseline','Active',4)
title('No T1 Decay')
dofontsize(15), fatlines, grid('on'), axis('tight'),
subplot(212)
plot(t(1:TRi),A1(1:TRi)/A1(TRi),t(TRi2)-t(TRi2(1)),A1(TRi2)/A1(TRi2(end-1)))
ylabel('Delivery Fraction')
xlabel('Time (s)')
dofontsize(15), fatlines, grid('on'), axis('tight'),

