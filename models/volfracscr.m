
clear all

% conversion factors
cm2m=1e-2;
m2cm=1/cm2m;
mmHg2Pa=133.32;
Pa2mmHg=1/133.32;
ml2m3=1e-6;
m32ml=1/ml2m3;

% physiological constants
mu=0.004;		% ???

Qartle=2.0*ml2m3;	% m3/s
Vartle=1.0*ml2m3;
Lartle=1.0*cm2m;

Qcap=0.5*ml2m3;		% m3/s
Vcap=0.5*ml2m3;
Lcap=1.0*cm2m;

Qtiss=1.0*ml2m3;	% ml/s
Vtiss=96*ml2m3;		% ml

% Pm and Vcap need to be modified
Pi=80*mmHg2Pa;
Pm=40*mmHg2Pa;
Po=20*mmHg2Pa;


% simulation computations

Lartle=[0.1:0.1:20]*Lartle;
Req_artle=(Pi-Pm)/Qartle;			% ???
for mm=1:length(Lartle),
  Deq_artle(mm)=(128*mu*Lartle(mm)/(pi*Req_artle))^(1/4);	% m
  Veq_artle(mm)=pi*Deq_artle(mm)*Deq_artle(mm)*Lartle(mm);
end;
find(abs(Veq_artle-Vartle)==min(abs(Veq_artle-Vartle)))

Lcap=[0.1:0.1:20]*Lcap;
Req_cap=(Pm-Po)/Qcap;				% ???
for mm=1:length(Lcap),
  Deq_cap(mm)=(128*mu*Lcap(mm)/(pi*Req_cap))^(1/4);	% m
  Veq_cap(mm)=pi*Deq_cap(mm)*Deq_cap(mm)*Lcap(mm);
end;
find(abs(Veq_cap-Vcap)==min(abs(Veq_cap-Vcap)))

MTTartle=Veq_artle/Qartle;
MTTcap=Veq_cap/Qcap;

subplot(211)
plot(Lartle,Vartle*ones(size(Lartle)),Lartle,Veq_artle)
plot(Lcap,Vcap*ones(size(Lcap)),Lcap,Veq_cap)
subplot(212)
plot(Lartle,Deq_artle)
plot(Lcap,Deq_cap)

