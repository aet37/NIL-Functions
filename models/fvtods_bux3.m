function [signal,deoxy,extr]=buxton3(fin,fout,rcbv,ic,parms)
% Usage ... [s,q,e]=buxton3(fin,fout,rcbv,ic,parameter_list)
%
% Calculates the signal change in bold experiment using
% the expandable compartment model. This version (3) assumes the
% time step size is constant and the input waveform, u and fin, can
% be linearly interpolated to calculate the RK (if on). 

% Sample model simulation command
% parms=[.7/5 15 .7 2 2 .4 .4 0 .1 .004 10 0 1 2.8 2.0 0.6];
% x=buxton1(0,65,0.1,[1 1],parms);
% the x vector is 651 elements long

tlen=length(fin);

dt=parms(1);
% this started at 5
tau0=parms(2);		% 2.0    2.0
e0=parms(3);		% 0.4    0.4 
% this started at 13
v0=parms(4);		% 1.0    1.0
k1=parms(5);		% 2.8    2.8
k2=parms(6);		% 2.0    2.0
k3=parms(7);		% 0.6    0.6

h=dt;
form=0;
verbose=1;
trapezoid=1;

if (verbose), disp('Model Simulation...'); end;

if (fin(1)~=1), fin0=fin(1); fin=fin/fin0; end;
if (fout(1)~=1), fout0=fout(1); fout=fout/fout0; end;
if (rcbv(1)~=1), rcbv0=rcbv(1); rcbv=rcbv/rcbv0; end;

deoxy(1)=1;
extr(1) = 1 - (1-e0)^(1/fin(1));

if (verbose), disp('Using discrete differentiation...'); end;
for m=1:tlen-1,
  deoxy(m+1) = deoxy(m) + h*(1/tau0)*(fin(m)*extr(m)/e0 - fout(m)*deoxy(m)/rcbv(m));
  extr(m+1) = 1 - ((1-e0)^(1/fin(m+1)));
end;
deoxy=deoxy(:);
extr=extr(:);

signal = v0*(k1*(1-deoxy) + k2*(1-deoxy./rcbv) + k3*(1-rcbv));

if (verbose),
  disp(['a(01)= h= ',num2str(h)]);
  disp(['a(02)= tau0=  ',num2str(tau0)]);
  disp(['a(03)= e0=    ',num2str(e0)]);
  disp(['a(10)= V0=    ',num2str(v0)]);
  disp(['a(11)= k1=    ',num2str(k1)]);
  disp(['a(12)= k2=    ',num2str(k2)]);
  disp(['a(13)= k3=    ',num2str(k3)]);
end;

if nargout==1,
  signal=[signal deoxy extr];
end;

