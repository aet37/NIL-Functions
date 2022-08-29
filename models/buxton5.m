function [signal,deoxy,rcbv,fin,fout,extr]=buxton5(t,u,ic,n,parms)
% Usage ... [s,v,fin,fout,extr]=buxton5(t,u,ic,n_compartments,parameter_list)
%
% Calculates the signal change in bold experiment using
% the expandable compartment model. This version assumes the
% time step size is constant and the input waveform, u and fin, can
% be linearly interpolated to calculate the RK (when available) 

% entries 1 and 2 of ensuing compartments are the velocity and
% adjacent distance of each compartment (to calculate delay)

% Sample model simulation command
% parms=[.7/5 15 .7 2 2 .4 .4 0 .1 .004 10 0 1 2.8 2.0 0.6];
% x=buxton1(0,65,0.1,[1 1],parms);
% the x vector is 651 elements long

%fout(1) = (rcbv(1)^(1/alpha)) + (tauv*dvdt*(rcbv(1)^(-1/2)));

h=t(2)-t(1);
tlen=length(t);

% Initialization
signal=zeros([tlen n]);
deoxy=zeros([tlen n]);
rcbv=zeros([tlen n]);
fin=zeros([tlen n]);
fout=zeros([tlen n]);
extr=zeros([tlen n]);

fin_slope=parms(1,1); 	% 2.0    0.7/5.0
fin_fwhm=parms(2,1);	% 0.0    15.0
fin_amp=parms(3,1);	% 0.7    0.7
fin_del=parms(4,1);	% 0.0    10.0
tau0=parms(5,1);	% 2.0    2.0
e0=parms(6,1);		% 0.4    0.4 
alpha=parms(7,1);	% 0.4    0.4
tauv=parms(8,1);	% 0.0    0.0
beta=parms(9,1);	%0.1    0.1
gamma=parms(10,1);	% 0.004  0.004
eta=parms(11,1);	% 0.04   0.04
zeta=parms(12,1);	% 0.0    0.0
v0=parms(13,1);		% 1.0    1.0
k1=parms(14,1);		% 2.8    2.8
k2=parms(15,1);		% 2.0    2.0
k3=parms(16,1);		% 0.6    0.6

form=0;
rk=0;
verbose=1;
trapezoid=1;

if (verbose), disp('Model Simulation...'); end;

deoxy(1)=ic(1,1);
rcbv(1)=ic(2,1);

% in-flow waveform generation
% linear model used
tuk(1)=0; for m=2:length(t), tuk(m)=tuk(m-1)+h; end; tuk=tuk(:);
uk=rect(tuk,fin_fwhm,fin_fwhm/2+fin_del); 
uk=uk./trapz(tuk,uk);
if fin_fwhm<h, unew=u; else, unew=myconv(u,uk); end;
fin=mysol([fin_amp/fin_slope],[1 1/fin_slope],unew,t); fin=fin.';
fin=1+fin;
fin=fin(:);

% initial conditions for other waveforms

extr(1) = 1 - (1-e0)^(1/fin(1));
dvdt = 0;
fout(1) = fout_fun(rcbv(1), [alpha tauv dvdt beta gamma eta zeta form]);

if n>1,
  for m=2:n,
    fin_slope(m)=parms(1,m);   % 2.0    0.7/5.0
    fin_fwhm(m)=parms(2,m);    % 0.0    15.0
    fin_amp(m)=parms(3,m);     % 0.7    0.7
    fin_del(m)=parms(4,m);     % 0.0    10.0
    tau0(m)=parms(5,m);        % 2.0    2.0
    e0(m)=parms(6,m);          % 0.4    0.4
    alpha(m)=parms(7,m);       % 0.4    0.4
    tauv(m)=parms(8,m);        % 0.0    0.0
    beta(m)=parms(9,m);        %0.1    0.1
    gamma(m)=parms(10,m);      % 0.004  0.004
    eta(m)=parms(11,m);        % 0.04   0.04
    zeta(m)=parms(12,m);       % 0.0    0.0
    v0(m)=parms(13,m);         % 1.0    1.0
    k1(m)=parms(14,m);         % 2.8    2.8
    k2(m)=parms(15,m);         % 2.0    2.0
    k3(m)=parms(16,m);         % 0.6    0.6

    deoxy(1,m)=ic(1,m);
    rcbv(1,m)=ic(2,m);

    vel_0(m)=fin_slope(m);			% mm/s (f=kv)
    dis_0(m)=fin_fwhm(m);			% mm
    tim_0(m)=dis_0(m)/vel_0(m);			% s
    del_i(m)=floor(tim_0(m)/h);			% samples

    fin(1,m)=fout(1,m-1);
    extr(1,m) = 1 - (1-e0(m))^(1/fin(1,m));
    dvdt(m) = 0;
    fout(1,m) = fout_fun(rcbv(1,m), [alpha(m) tauv(m) dvdt(m) beta(m) gamma(m) eta(m) zeta(m) form]);
  end;
end;

% discrete differentiation only allowed for now

for m=1:tlen-1,

  deoxy(m+1,1) = deoxy(m,1) + h*(1/tau0(1))*(fin(m,1)*extr(m,1)/e0(1) - fout(m,1)*deoxy(m,1)/rcbv(m,1));
  rcbv(m+1,1) = rcbv(m,1) + h*(1/tau0(1))*(fin(m,1)-fout(m,1));

  extr(m+1,1) = 1 - ((1-e0(1))^(1/fin(m+1,1)));
  dvdt(1) = (rcbv(m+1,1)-rcbv(m,1))/h;
  fout(m+1,1) = fout_fun(rcbv(m+1,1), [alpha(1) tauv(1) dvdt(1) beta(1) gamma(1) eta(1) zeta(1) form]);

  if n>1,
    for mm=2:n,
      %dis_0(mm), vel_0(mm), fout(m+1,mm-1),
      tim_0(mm)=dis_0(mm)/(vel_0(mm)*fout(m+1,mm-1));
      del_i(mm)=floor(tim_0(mm)/h);
      if (m+1-del_i(mm))<1,
        fin(m+1,mm)=fout(1,mm-1);
      else,
        fin(m+1,mm)=fout(m+1-del_i(mm),mm-1);
      end;

      deoxy(m+1,mm) = deoxy(m,mm) + h*(1/tau0(mm))*(fin(m,mm)*extr(m,mm)/e0(mm) - fout(m,mm)*deoxy(m,mm)/rcbv(m,mm));
      rcbv(m+1,mm) = rcbv(m,mm) + h*(1/tau0(mm))*(fin(m,mm)-fout(m,mm));

      extr(m+1,mm) = 1 - ((1-e0(mm))^(1/fin(m+1,mm)));
      dvdt(mm) = (rcbv(m+1,mm)-rcbv(m,mm))/h;
      fout(m+1,mm) = fout_fun(rcbv(m+1,mm), [alpha(mm) tauv(mm) dvdt(mm) beta(mm) gamma(mm) eta(mm) zeta(mm) form]);
    end;
  end;

end;

for m=1:n,
  signal(:,m) = v0(m)*(k1(m)*(1-deoxy(:,m)) + k2(m)*(1-deoxy(:,m)./rcbv(:,m)) + k3(m)*(1-rcbv(:,m)));
end;

