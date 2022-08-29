function [time,signal,deoxy,rcbv,fin,fout,extr]=buxton1(t0,tfinal,tstep,ic,parms)
% Usage ... [t,s,v,fin,fout,extr]=buxton1(t0,tfinal,tstep,ic,parameter_list)
%
% Calculates the signal change in bold experiment using
% Robert Buxton's model.

% Sample model simulation command
% parms=[.7/5 15 .7 2 2 .4 .4 0 .1 .004 10 0 1 2.8 2.0 0.6];
% x=buxton1(0,65,0.1,[1 1],parms);
% the x vector is 651 elements long

h=tstep;
time=[t0:h:tfinal];
tlen=length(time);

if nargin<5,
  fin_slope=0.7/5;
  fin_fwhm=15;
  fin_amp=0.7;
  fin_del=2;
  tau0=2;
  e0=0.4;
  alpha=0.4;
  tauv=0;
  beta=0.1;
  gamma=0.004;
  eta=10;
  zeta=0;
  v0=1;
  k1=2.8;
  k2=2.0;
  k3=0.6;
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
rk=0;
verbose=1;
trapezoid=0;

if (verbose), disp('Model Simulation...'); end;

%deoxy=zeros([tlen 1]);
%rcbv=zeros([tlen 1]);
%fin=zeros([tlen 1]);
%fout=zeros([tlen 1]);
%extr=zeros([tlen 1]);

deoxy(1)=ic(1);
rcbv(1)=ic(2);

fin(1) = ic(3);
extr(1) = 1 - (1-e0)^(1/fin(1));
dvdt = 0;
fout(1) = fout_fun(rcbv(1), [alpha tauv dvdt beta gamma eta zeta form]);
%fout(1) = (rcbv(1)^(1/alpha)) + (tauv*dvdt*(rcbv(1)^(-1/2)));

if (rk),

 if (verbose), disp('Using Runge-Kutta...'); end;
 for m=1:tlen-1,
  tmpfin=fin(m);
  tmpextr=extr(m);
  tmpfout=fout(m);

  k1q = h*(1/tau0)*(tmpfin*tmpextr/e0 - tmpfout*deoxy(m)/rcbv(m));
  k1v = h*(1/tau0)*(tmpfin - tmpfout);

  if (trapezoid),
    tmpfin = 1 + mtrap1(time(m)+h/2,0,fin_fwhm,fin_slope,fin_amp,fin_del);
  else,
    tmpfin = 1+fin_fun(time(m),h/2,fin_slope,fin(m)-1,fin_del,fin_fwhm,fin_amp);
  end;
  tmpextr = 1 - (1-e0)^(1/tmpfin);
  dvdt = (k1v/2)/(h/2);
  %tmpfout = (rcbv(m)+k1v/2)^(1/alpha) + tauv*dvdt*(rcbv(m)+k1v/2)^(-1/2);
  tmpfout = fout_fun(rcbv(m)+k1v/2, [alpha tauv dvdt beta gamma eta zeta form]);
 
  k2q = h*(1/tau0)*(tmpfin*tmpextr/e0 - tmpfout*(deoxy(m)+k1q/2)/(rcbv(m)+k1v/2));
  k2v = h*(1/tau0)*(tmpfin - tmpfout);

  if (trapezoid),
    tmpfin = 1 + mtrap1(time(m)+h/2,0,fin_fwhm,fin_slope,fin_amp,fin_del);
  else,
    tmpfin = 1+fin_fun(time(m),h/2,fin_slope,fin(m)-1,fin_del,fin_fwhm,fin_amp);
  end;
  tmpextr = 1 - (1-e0)^(1/tmpfin);
  dvdt = (k2v/2)/(h/2);
  %tmpfout = (rcbv(m)+k2v/2)^(1/alpha) + tauv*dvdt*(rcbv(m)+k2v/2)^(-1/2);
  tmpfout = fout_fun(rcbv(m)+k2v/2, [alpha tauv dvdt beta gamma eta zeta form]);
 
  k3q = h*(1/tau0)*(tmpfin*tmpextr/e0 - tmpfout*(deoxy(m)+k2q/2)/(rcbv(m)+k2v/2));
  k3v = h*(1/tau0)*(tmpfin - tmpfout);

  if (trapezoid),
    tmpfin = 1 + mtrap1(time(m)+h,0,fin_fwhm,fin_slope,fin_amp,fin_del);
  else,
    tmpfin = 1+fin_fun(time(m),h,fin_slope,fin(m)-1,fin_del,fin_fwhm,fin_amp);
  end;
  tmpextr = 1 - (1-e0)^(1/tmpfin);
  dvdt = (k3v)/h;
  %tmpfout = (rcbv(m)+k3v)^(1/alpha) + tauv*dvdt*(rcbv(m)+k3v)^(-1/2);
  tmpfout = fout_fun(rcbv(m)+k3v, [alpha tauv dvdt beta gamma eta zeta form]);

  k4q = h*(1/tau0)*(tmpfin*tmpextr/e0 - tmpfout*(deoxy(m)+k3q)/(rcbv(m)+k3v));
  k4v = h*(1/tau0)*(tmpfin - tmpfout);

  deoxy(m+1) = deoxy(m) + k1q/6 + k2q/3 + k3q/3 + k4q/6;
  rcbv(m+1) = rcbv(m) + k1v/6 + k2v/3 + k3v/3 + k4v/6;

  if (trapezoid),
    fin(m+1) = 1 + mtrap1(time(m+1),0,fin_fwhm,fin_slope,fin_amp,fin_del);
  else,
    fin(m+1) = 1+fin_fun(time(m+1),h,fin_slope,fin(m)-1,fin_del,fin_fwhm,fin_amp);
  end;
  extr(m+1) = 1 - (1-e0)^(1/fin(m+1));
  dvdt=(rcbv(m+1)-rcbv(m))/h;
  %fout(m+1) = (rcbv(m+1))^(1/alpha) + tauv*dvdt*(rcbv(m+1))^(-1/2);
  fout(m+1) = fout_fun(rcbv(m+1), [alpha tauv dvdt beta gamma eta zeta form]);
 end;

else,

 if (verbose), disp('Using discrete differentiation...'); end;
 for m=1:tlen-1,
  deoxy(m+1) = deoxy(m) + h*(1/tau0)*(fin(m)*extr(m)/e0 - fout(m)*deoxy(m)/rcbv(m));
  rcbv(m+1) = rcbv(m) + h*(1/tau0)*(fin(m)-fout(m));	

  if (trapezoid),
    fin(m+1) = 1 + mtrap1(time(m+1),0,fin_fwhm,fin_slope,fin_amp,fin_del);
  else,
    fin(m+1) = 1+fin_fun(time(m+1),h,fin_slope,fin(m)-1,fin_del,fin_fwhm,fin_amp);
  end;
  extr(m+1) = 1 - ((1-e0)^(1/fin(m+1)));
  dvdt = (rcbv(m+1)-rcbv(m))/h;
  fout(m+1) = (rcbv(m+1)^(1/alpha)) + tauv*dvdt*(rcbv(m+1)^(-1/2));
  fout(m+1) = fout_fun(rcbv(m+1), [alpha tauv dvdt beta gamma eta zeta form]);
 end;

end;

signal = v0*(k1*(1-deoxy) + k2*(1-deoxy./rcbv) + k3*(1-rcbv));

if (verbose),
  disp(['a(01)= slope= ',num2str(fin_slope)]);
  disp(['a(02)= fwhm=  ',num2str(fin_fwhm)]);
  disp(['a(03)= amp=   ',num2str(fin_amp)]);
  disp(['a(04)= delay= ',num2str(fin_del)]);
  disp(['a(05)= tau0=  ',num2str(tau0)]);
  disp(['a(06)= e0=    ',num2str(e0)]);
  disp(['a(07)= alpha= ',num2str(alpha)]);
  disp(['a(08)= tauv=  ',num2str(tauv)]);
  disp(['a(09)= beta=  ',num2str(beta)]);
  disp(['a(10)= gamma= ',num2str(gamma)]);
  disp(['a(11)= eta=   ',num2str(eta)]);
  disp(['a(12)= zeta=  ',num2str(zeta)]);
  disp(['a(13)= V0=    ',num2str(v0)]);
  disp(['a(14)= k1=    ',num2str(k1)]);
  disp(['a(15)= k2=    ',num2str(k2)]);
  disp(['a(16)= k3=    ',num2str(k3)]);
end;

if nargout==1,
  time=[time;signal;deoxy;rcbv;fin;fout;extr];
  time=time.';
end;

if nargout==0,
  subplot(321)
  plot(time,fin,time,fout), grid,
  subplot(322)
  plot(time,rcbv), grid,
  subplot(323)
  plot(time,deoxy), grid,
  subplot(324)
  plot(time,extr), grid,
  subplot(313)
  plot(time,signal), grid,
end;

