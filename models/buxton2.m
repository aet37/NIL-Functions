function [time,signal]=buxton2(t0,tfinal,tstep,ic,parms)
% Usage ... [t,s]=buxton2(t0,tfinal,tstep,ic,parameter_list)
%
% Calculates the signal change in bold experiment using
% Robert Buxton's model.

% Sample model simulation command
% pamrs=[5 .7/5 .7 2 2 .4 .4 0 .1 .004 10 0 1 2.8 2.0 0.6 ...];
% x=buxton2(0,100,0.1,[1 1],parms);

disp('Model Simulation...');

h=tstep;
time=[t0:h:tfinal];
tlen=length(time);

if nargin<5,
  fin_slope=0.7/5;
  fin_fwhm=15;
  fin_amp=0.7;
  fin_del=2;
  tau0=4;
  e0=0.4;
  alpha1=0.4;
  tauv1=0;
  beta1=0.1;
  gamma1=0.004;
  eta1=10;
  zeta1=0;
  v0=1;
  k1=2.8;
  k2=2.0;
  k3=0.6;
  cdel=0;
  alpha2=0.4;
  tauv2=0;
  beta2=0.1;
  gamma2=0.004;
  eta2=10;
  zeta2=0; 
else,
  fin_slope=parms(1);
  fin_fwhm=parms(2);
  fin_amp=parms(3);
  fin_del=parms(4);
  tau0=parms(5);
  e0=parms(6);
  alpha=parms(7);
  tauv=parms(8);
  beta=parms(9);
  gamma=parms(10);
  eta=parms(11);
  zeta=parms(12);
  v0=parms(13);
  k1=parms(14);
  k2=parms(15);
  k3=parms(16);
end;

form=0;

deoxy1(1)=ic(1); deoxy2(1)=ic(1);
rcbv1(1)=ic(2); rcbv2(1)=ic(2);

fin1(1) = 1 + mtrap1(time(1),0,fin_fwhm,fin_slope,fin_amp,fin_del);
extr(1) = 1 - (1-e0)^(1/fin1(1));
dvdt1 = 0;
fout1(1) = fout_fun(rcbv1(1), [alpha1 tauv1 dvdt1 beta1 gamma1 eta1 zeta1 form]);

fin2(1) = 1 + mtrap1(time(1),0,fin_fwhm,fin_slope,fin_amp,fin_del+cdel);
%extr2(1) = 1 - (1-e0)^(1/fin2(1));
dvdt2 = 0;
fout2(1) = fout_fun(rcbv2(1), [alpha2 tauv2 dvdt2 beta2 gamma2 eta2 zeta2 form]);

%disp('Using discrete differentiation...');
for m=1:tlen-1,
  deoxy1(m+1) = deoxy1(m) + h*(1/tau0)*(fin1(m)*extr(m)/e0 - fout1(m)*deoxy1(m)/rcbv1(m));
  rcbv1(m+1) = rcbv1(m) + h*(1/tau0)*(fin1(m)-fout1(m));

  fin1(m+1) = 1 + mtrap1(time(m+1),0,fin_fwhm,fin_slope,fin_amp,fin_del);
  extr(m+1) = 1 - ((1-e0)^(1/fin1(m+1)));
  dvdt1 = (rcbv1(m+1)-rcbv1(m))/h;
  fout1(m+1) = fout_fun(rcbv1(m+1), [alpha1 tauv1 dvdt1 beta1 gamma1 eta1 zeta1 form]);

  deoxy2(m+1) = deoxy2(m) + h*(1/tau0)*(fin2(m)*extr(m)/e0 - fout2(m)*deoxy2(m)/rcbv2(m));
  rcbv2(m+1) = rcbv2(m) + h*(1/tau0)*(fin2(m)-fout2(m));

  fin2(m+1) = 1 + mtrap1(time(m+1),0,fin_fwhm,fin_slope,fin_amp,fin_del+cdel);
  extr(m+1) = 1 - ((1-e0)^(1/fin2(m+1)));
  dvdt2 = (rcbv2(m+1)-rcbv2(m))/h;
  fout2(m+1) = fout_fun(rcbv2(m+1), [alpha2 tauv2 dvdt2 beta2 gamma2 eta2 zeta2 form]);
end;

signal1 = v0*(k1*(1-deoxy1) + k2*(1-deoxy1./rcbv1) + k3*(1-rcbv1));
signal2 = v0*(k1*(1-deoxy2) + k2*(1-deoxy2./rcbv2) + k3*(1-rcbv2));
signal= signal1+signal2;

if nargout==1,
  time=[time;signal;extr;signal1;signal2;deoxy1;deoxy2;rcbv1;rcbv2;fin1;fin2;fout1;fout2];
  time=time.';
end;

