function [s,q,E]=fvtods(fin,fout,v,parms)
% Usage ... ds=fvtods(fin,fout,v,parms)
%
% parms = [dt [dHb] V0 E0]

verbose_flag=1;

if nargin<4,
  parms=[1 1 v(1) 0.41 1e-10 1 1 5];
end;
if length(parms)==5,
  parms=[parms 1 1 5];
end;

dt=parms(1);
cHb=parms(2);
v0=parms(3);
E0=parms(4);
q0=parms(5);
ks=parms(6);
TE=parms(7);
ka=parms(8);

if (verbose_flag),
  disp(sprintf('dt= %1.2e  cHb= %1.2e  V0= %1.2e  E0= %1.2e',dt,cHb,v0,E0));
  disp(sprintf('q0= %1.2e  ks= %1.2e  TE= %1.2e  ka=%1.2e',q0,ks,TE,ka));
end;

Nav=6.022e23;
Hct=0.4;
cHb=(1/65000)*50e-12/(Hct*v(1));
q0=v(1)*cHb*E0;

k1=v0*cHb*E0;
k2=k1;

oxlim=2;
if (oxlim==1),
  %ke1=1;
  ke1=1.00;	% 1.50 seems to work well
  ke=ke1*fin(1)./fin-(ke1-1);
  %ke=fin(1)./fin;
  %ke=diff(ke); ke(end+1)=ke(end);
  %ke=1-E0*(ke<0);
  E=1-((1-E0).^(ke));
elseif (oxlim==2),
  % D is a function of time and it depends on Hct, PcapO2 and/or CBV
  % Deff is also given by:
  %    Deff = (kr)_net * CBV
  %    Deff = (kr)_net * CBV / 0.5 Ravg
  % Deff*fin should be ~ 0.2-0.5 at rest
  knet=1.3;
  rnet=0.6;
  rbar=2;
  %rbar=parms(6);
  Deff_c=knet*rnet/(0.5*rbar);
  Deff_c=4.0;
  Deff_c=(fout(1)/v(1))*log(1/(1-E0));
  Deff=Deff_c*v;
  E=1-exp(-Deff./fout);
  %E0=E(1);
else,
  E=ones(size(fin));
  ke=ones(size(fin));
end;

q(1)=q0;
for m=1:length(fin)-1,
 q(m+1) = q(m) + dt*( (q0/v0)*(E(m)/E0)*fin(m) - (q(m)/v(m))*fout(m) );
end;
q=q(:);
rqin=(q0/v0)*(E/E0).*fin;
rqout=(q./v).*fout;

%ka=5;
%TE=1;
%ks=1;
nq=q./q(1);
s=ka*(1-ks*nq*TE);

ii=[1:length(fin)];
if (nargout==0),
  subplot(311)
  plot((ii-1)/dt,ke), grid,
  ylabel('Extraction')
  subplot(312)
  %plot((ii-1)/dt,rqin,(ii-1)/dt,rqout), grid,
  plot((ii-1)/dt,nq,(ii-1)/dt,rqin/rqin(1),(ii-1)/dt,rqout/rqout(1)), grid,
  subplot(313)
  plot((ii-1)/dt,s), grid,
  ylabel('Signal')
end;

if nargout==1,
  s=[s q E rqin rqout];
end;

