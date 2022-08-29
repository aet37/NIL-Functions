function [signal,deoxy,rcbv,fin,fout,extr]=buxton4(t,u,ic,parms)
% Usage ... [s,v,fin,fout,extr]=buxton4(t,u,ic,parameter_list)
%
% Calculates the signal change in bold experiment using
% the expandable compartment model. This version assumes the
% time step size is constant and the input waveform, u and fin, can
% be linearly interpolated to calculate the RK (when available) 

% Sample model simulation command
% parms=[.7/5 15 .7 2 2 .4 .4 0 .1 .004 10 0 1 2.8 2.0 0.6];
% x=buxton1(0,65,0.1,[1 1],parms);
% the x vector is 651 elements long

%fout(1) = (rcbv(1)^(1/alpha)) + (tauv*dvdt*(rcbv(1)^(-1/2)));

h=t(2)-t(1);
tlen=length(t);

fin_slope=parms(1,1); 	vel_0=parms(1,2);	% 2.0    0.7/5.0
fin_fwhm=parms(2,1);	dis_0=parms(2,2);	% 0.0    15.0
fin_amp=parms(3,1);				% 0.7    0.7
fin_del=parms(4,1);				% 0.0    10.0
tau0=parms(5,1);	tau02=parms(5,2);	% 2.0    2.0
e0=parms(6,1);		e02=parms(6,2);		% 0.4    0.4 
alpha=parms(7,1);	alpha2=parms(7,2);	% 0.4    0.4
tauv=parms(8,1);	tauv2=parms(8,2);	% 0.0    0.0
beta=parms(9,1);	beta2=parms(9,2);	% 0.1    0.1
gamma=parms(10,1);	gamma2=parms(10,2);	% 0.004  0.004
eta=parms(11,1);	eta2=parms(11,2);	% 0.04   0.04
zeta=parms(12,1);	zeta2=parms(12,2);	% 0.0    0.0
v0=parms(13,1);		v02=parms(13,2);	% 1.0    1.0
k1=parms(14,1);					% 2.8    2.8
k2=parms(15,1);					% 2.0    2.0
k3=parms(16,1);					% 0.6    0.6

form=0;
rk=0;
verbose=1;
trapezoid=1;

if (verbose), disp('Model Simulation...'); end;

deoxy(1)=ic(1,1); 	deoxy2(1)=ic(1,2);
rcbv(1)=ic(2,1); 	rcbv2(1)=ic(2,2);

% in-flow waveform generation
% linear model used
tuk(1)=0; for m=2:length(t), tuk(m)=tuk(m-1)+h; end; tuk=tuk(:);
uk=rect(tuk,fin_fwhm,fin_fwhm/2+fin_del); 
uk=uk./trapz(tuk,uk);
if fin_fwhm<h, unew=u; else, unew=myconv(u,uk); end;
fin=mysol([fin_amp/fin_slope],[1 1/fin_slope],unew,t); fin=fin.';
fin=1+fin;

% initial conditions for other waveforms

extr(1) = 1 - (1-e0)^(1/fin(1));
dvdt = 0;
fout(1) = fout_fun(rcbv(1), [alpha tauv dvdt beta gamma eta zeta form]);

%vel_0=10.0;	% mm/s (f=kv)
%dis_0=10.0;	% mm
tim_0=dis_0/vel_0;	% s
del_i=floor(tim_0/h);	% samples
extr2(1) = 1 - (1-e02)^(1/fout(1));
dvdt2 = 0;
foutin(1) = fout(1);
fout2(1) = fout_fun(rcbv2(1), [alpha2 tauv2 dvdt2 beta2 gamma2 eta2 zeta2 form]);

% discrete differentiation only allowed for now

for m=1:tlen-1,

  deoxy(m+1) = deoxy(m) + h*(1/tau0)*(fin(m)*extr(m)/e0 - fout(m)*deoxy(m)/rcbv(m));
  rcbv(m+1) = rcbv(m) + h*(1/tau0)*(fin(m)-fout(m));	

  extr(m+1) = 1 - ((1-e0)^(1/fin(m+1)));
  dvdt = (rcbv(m+1)-rcbv(m))/h;
  fout(m+1) = fout_fun(rcbv(m+1), [alpha tauv dvdt beta gamma eta zeta form]);

  tim_0=dis_0/(vel_0*fout(m+1));
  del_i=floor(tim_0/h);
  if (m+1-del_i)<1,
    foutin(m+1)=fout(1);
  else,
    foutin(m+1)=fout(m+1-del_i);
  end;

  deoxy2(m+1) = deoxy2(m) + h*(1/tau02)*(foutin(m)*extr2(m)/e02 - fout2(m)*deoxy2(m)/rcbv2(m));
  rcbv2(m+1) = rcbv2(m) + h*(1/tau02)*(foutin(m)-fout2(m));

  extr2(m+1) = 1 - ((1-e02)^(1/foutin(m+1)));
  dvdt2 = (rcbv2(m+1)-rcbv2(m))/h;
  fout2(m+1) = fout_fun(rcbv2(m+1), [alpha2 tauv2 dvdt2 beta2 gamma2 eta2 zeta2 form]);

end;

signal = v0*(k1*(1-deoxy) + k2*(1-deoxy./rcbv) + k3*(1-rcbv));
signal2 = v02*(k1*(1-deoxy2) + k2*(1-deoxy2./rcbv2) + k3*(1-rcbv2));

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
  signal=[signal;signal;deoxy;rcbv;fin;fout;extr;signal2;deoxy2;rcbv2;fout2;extr2];
  signal=signal.';
end;

signal(:,1)=signal(:,1)+signal2.';

