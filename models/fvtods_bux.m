function [signal,deoxy,extr]=fvtods_bux(fin,fout,rcbv,parms)
% Usage ... [s,q,extr]=fvtods_bux(fin,fout,v,parameter_list)
%
% parms = [ dt tau0 e0 v0 k1 k2 k3 ]
%
% calculates the signal change in bold experiment using
% Buxton's model


% Sample model simulation command
% parms=[.7/5 15 .7 2 2 .4 .4 0 .1 .004 10 0 1 2.8 2.0 0.6];
% x=buxton1(0,65,0.1,[1 1],parms);
% the x vector is 651 elements long

tlen=length(fin);

fin=fin(:);
fout=fout(:);
rcbv=rcbv(:);

if nargin<4,
  dt=1;
  tau0=2;
  e0=0.4;
  v0=1;
  k1=2.8;
  k2=2.0;
  k3=0.6;
else,
  dt=parms(1);
  tau0=parms(2);
  e0=parms(3);
  v0=parms(4);
  k1=parms(5);
  k2=parms(6);
  k3=parms(7);
end;

verbose=1;

if (verbose), disp('Model Simulation...'); end;

% normalize incomming data if not normalized
if (fin(1)~=1), fin0=fin(1); fin=fin/fin0; end;
if (fout(1)~=1), fout0=fout(1); fout=fout/fout0; end;
if (rcbv(1)~=1), rcbv0=rcbv(1); rcbv=rcbv/rcbv0; end;

deoxy=zeros([tlen 1]);
extr=zeros([tlen 1]);

deoxy(1)=1;
extr(1) = 1 - (1-e0)^(1/fin(1));

for m=1:tlen-1,
  deoxy(m+1) = deoxy(m) + dt*(1/tau0)*(fin(m)*extr(m)/e0 - fout(m)*deoxy(m)/rcbv(m));
  extr(m+1) = 1 - ((1-e0)^(1/fin(m+1)));
end;

signal = v0*(k1*(1-deoxy) + k2*(1-deoxy./rcbv) + k3*(1-rcbv));

if (verbose),
  disp(['a(1)= tau0=  ',num2str(tau0)]);
  disp(['a(2)= e0=    ',num2str(e0)]);
  disp(['a(3)= V0=    ',num2str(v0)]);
  disp(['a(4)= k1=    ',num2str(k1)]);
  disp(['a(5)= k2=    ',num2str(k2)]);
  disp(['a(6)= k3=    ',num2str(k3)]);
end;

if nargout==1,
  signal=[signal;deoxy;extr];
  signal=signal.';
end;

if nargout==0,
  t=[0:dt:(tlen-1)/dt];
  subplot(321)
  plot(t,fin,t,fout), grid,
  ylabel('Flow')
  legend('Fin','Fout')
  subplot(322)
  plot(t,rcbv), grid,
  ylabel('Volume')
  subplot(323)
  plot(t,extr), grid,
  ylabel('Oxygen Extr')
  subplot(324)
  plot(t,deoxy), grid,
  ylabel('[Deoxy-Hb]')
  subplot(313)
  %plot(t,signal,t,v0*k1*(1-deoxy),t,v0*k2*(1-deoxy./rcbv),t,v0*k3*(1-rcbv)), grid,
  plot(t,signal), grid,
  ylabel('MR Signal')
  xlabel('Time')
end;

