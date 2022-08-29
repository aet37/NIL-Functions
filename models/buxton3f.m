function [signal,deoxy,extr,rcbv,fin,fout]=buxton3f(x0,t,u,ic,parmstofit,parms,y)
% Usage ... [s,v,extr,fin,fout]=buxton3(x0,t,u,ic,parmstofit,parms,data)
%
% Calculates the signal change in bold experiment using
% the expandable compartment model. This version (3) assumes the
% time step size is constant and the input waveform, u and fin, can
% be linearly interpolated to calculate the RK (if on). 

% Sample model simulation command
% parms=[.7/5 15 .7 2 2 .4 .4 0 .1 .004 10 0 1 2.8 2.0 0.6];
% x=buxton1(0,65,0.1,[1 1],parms);
% the x vector is 651 elements long

h=t(2)-t(1);
tlen=length(t);

for m=1:length(parmstofit), parms(parmstofit(m))=x0(m); end;

fin_slope=parms(1); 	% 2.0    0.7/5.0
fin_fwhm=parms(2);	% 0.0    15.0
fin_amp=parms(3);	% 0.7    0.7
fin_del=parms(4);	% 0.0    10.0
tau0=parms(5);		% 2.0    2.0
e0=parms(6);		% 0.4    0.4 
alpha=parms(7);		% 0.4    0.4
tauv=parms(8);		% 0.0    0.0
beta=parms(9);		% 0.1    0.1
gamma=parms(10);	% 0.004  0.004
eta=parms(11);		% 0.04   0.04
zeta=parms(12);		% 0.0    0.0
v0=parms(13);		% 1.0    1.0
k1=parms(14);		% 2.8    2.8
k2=parms(15);		% 2.0    2.0
k3=parms(16);		% 0.6    0.6

form=6;
rk=0;
verbose=1;
trapezoid=1;

if (verbose), disp('Model Simulation...'); end;

deoxy(1)=ic(1);
rcbv(1)=ic(2);

tuk(1)=0; for m=2:length(t), tuk(m)=tuk(m-1)+h; end; tuk=tuk(:);
if fin_fwhm<h,
  unew=u;
else,
  uk=rect(tuk,fin_fwhm,fin_fwhm/2+fin_del)';
  uk=uk./sum(uk);
  unew=myconv(u,uk);
  %plot(tuk,u,tuk,uk,tuk,unew),pause,
end;
%plot(t,unew), pause,
fin=mysol([fin_amp/fin_slope],[1 1/fin_slope],unew,t); fin=fin.';
fin=1+fin;

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

  tmpfin=0.5*(fin(m)+fin(m+1));
  tmpextr = 1 - (1-e0)^(1/tmpfin);
  dvdt = (k1v/2)/(h/2);
  %tmpfout = (rcbv(m)+k1v/2)^(1/alpha) + tauv*dvdt*(rcbv(m)+k1v/2)^(-1/2);
  tmpfout = fout_fun(rcbv(m)+k1v/2, [alpha tauv dvdt beta gamma eta zeta form]);
 
  k2q = h*(1/tau0)*(tmpfin*tmpextr/e0 - tmpfout*(deoxy(m)+k1q/2)/(rcbv(m)+k1v/2));
  k2v = h*(1/tau0)*(tmpfin - tmpfout);

  tmpfin=0.5*(fin(m)+fin(m+1));
  tmpextr = 1 - (1-e0)^(1/tmpfin);
  dvdt = (k2v/2)/(h/2);
  %tmpfout = (rcbv(m)+k2v/2)^(1/alpha) + tauv*dvdt*(rcbv(m)+k2v/2)^(-1/2);
  tmpfout = fout_fun(rcbv(m)+k2v/2, [alpha tauv dvdt beta gamma eta zeta form]);
 
  k3q = h*(1/tau0)*(tmpfin*tmpextr/e0 - tmpfout*(deoxy(m)+k2q/2)/(rcbv(m)+k2v/2));
  k3v = h*(1/tau0)*(tmpfin - tmpfout);

  tmpfin=fin(m+1);
  tmpextr = 1 - (1-e0)^(1/tmpfin);
  dvdt = (k3v)/h;
  %tmpfout = (rcbv(m)+k3v)^(1/alpha) + tauv*dvdt*(rcbv(m)+k3v)^(-1/2);
  tmpfout = fout_fun(rcbv(m)+k3v, [alpha tauv dvdt beta gamma eta zeta form]);

  k4q = h*(1/tau0)*(tmpfin*tmpextr/e0 - tmpfout*(deoxy(m)+k3q)/(rcbv(m)+k3v));
  k4v = h*(1/tau0)*(tmpfin - tmpfout);

  deoxy(m+1) = deoxy(m) + k1q/6 + k2q/3 + k3q/3 + k4q/6;
  rcbv(m+1) = rcbv(m) + k1v/6 + k2v/3 + k3v/3 + k4v/6;

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

  extr(m+1) = 1 - ((1-e0)^(1/fin(m+1)));
  dvdt = (rcbv(m+1)-rcbv(m))/h;
  %fout(m+1) = (rcbv(m+1)^(1/alpha)) + tauv*dvdt*(rcbv(m+1)^(-1/2));
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

if ((nargout==1)&(nargin<7)),
  signal=[signal;deoxy;extr;rcbv;fin;fout];
  signal=signal.';
elseif (nargin==7),
  signal=[signal;deoxy;extr;rcbv;fin;fout];
  signal=signal.';
  deoxy=signal; clear signal
  signal=(deoxy(:,1)-y);
end;

