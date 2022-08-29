function [BOLD,Bs]=balloon2(x,parms,parms2fit,Sinput,Sdt,BOLDdata,BOLDtt)
% Usage .. [BOLD,struc]=balloon2(x,parms,parms2fit,Sinput,Sdt,BOLDdata,BOLDtt)

if ~isempty(parms2fit),
  parms(parms2fit)=x;
end;

k=parms(1);
Ti=parms(2);
N0=parms(3);
kh=parms(4);
Th=parms(5);
f1=parms(6);
n=parms(7);
dtf=parms(8);
dtt=parms(9);
a=parms(10);
Tvp=parms(11);
Tvn=parms(12);
Tmtt=parms(13);
E0=parms(14);
b=parms(15);
A=parms(16);

%
% BOLD model by Buxton, et al., in Neuroimage 23: S220 (2004)
% Implemented by Alberto Vazquez, University of Michigan (2005)
%
% input: s(t)
% output: f(t), m(t), BOLD(t)
% parameters: k Ti N0 kh Th f1 n dtf dtt a Tvp Tvm Tmtt E0 b A
% 
% N(t) = s(t) - I(t)
% dI(t)/dt = (1/Ti)(kN(t) - I(t))
% 
% h(t) = (1/kh Th (kh - 1)!)(t/Th)^kh exp(-t/Th)
% (m1 - 1)=(f1 - 1)/n
% dtm=dtf+dtt
% 
% f(t) = 1 + (f1 - 1)h(t - dtf)*N(t)
% m(t) = 1 + (m1 - 1)h(t - dtm)*N(t)
% 
% fout(t) = v^(1/a) + Tv*dv/dt
% dv/dt = (1/Tmmt)(f(t) - fout(t))
% dq/dt = (1/Tmmt)(f(t)E(t)/E0 - q(t)fout(t)/v(t))
% 
% BOLD = A(1 - f^(a-b) m^b) in the steady-state
% BOLD = A(a1(1 - q) - a2(1 - v))
%


dtm=dtf+dtt;
m1=(f1-1)/n+1;


t=[0:length(Sinput)-1]*Sdt; 
hf=(1/(kh*Th*factorial(kh-1)))*(((t-dtf)/Th).^kh).*exp(-(t-dtf)/Th);
hm=(1/(kh*Th*factorial(kh-1)))*(((t-dtm)/Th).^kh).*exp(-(t-dtm)/Th);
ii=find((t-dtf)<0); if ~isempty(ii), hf(ii)=0; end;
ii=find((t-dtm)<0); if ~isempty(ii), hm(ii)=0; end;

%% Uncomment these for testing the hrf
%hf=zeros(size(hf)); hf(1:1000)=1;
%hm=zeros(size(hm)); hm(1:1000)=1;

hf=hf/sum(hf);
hm=hm/sum(hm);


N(1)=Sinput(1);
I(1)=0;
f(1)=1; m(1)=1;
v(1)=1; fout(1)=1; q(1)=1;
E(1)=E0;
Tvv=Tvp;
for nn=2:length(Sinput),
  I(nn) = I(nn-1) + Sdt*(1/Ti)*(k*N(nn-1) - I(nn-1));
  N(nn) = Sinput(nn) - I(nn);
  N(nn) = N(nn)*(1+k);
  if (N(nn)<0), N(nn)=0; end;
  f(nn) = 1+(f1-1)*sum(N(1:nn).*hf(nn:-1:1));
  m(nn) = 1+(m1-1)*sum(N(1:nn).*hm(nn:-1:1));
  E(nn) = E0*(2-m(nn));
  v(nn) = v(nn-1) + Sdt*(1/Tvv)*(f(nn-1) - v(nn-1)^(1/a) );
  fout(nn) = f(nn) - (v(nn)-v(nn-1))/Sdt;
  if (v(nn)-v(nn-1))>0, Tvv=Tmtt+Tvp; else, Tvv=Tmtt+Tvn; end;
  q(nn) = q(nn-1) + Sdt*(1/Tmtt)*( f(nn-1)*E(nn-1)/E0 - q(nn-1)*fout(nn-1)/v(nn-1) );
end;

BOLD = A*(3.4*(1-q) - 1.0*(1-v));
%% Uncomment this for Davis signal equation, otherwise use above by Buxton
%BOLD = A*(1 - (v.^(1-b)).*(q.^b));

if (nargout==2),
  Bs.BOLD=BOLD;
  Bs.q=q;
  Bs.N=N;
  Bs.I=I;
  Bs.hf=hf;
  Bs.hm=hm;
  Bs.f=f;
  Bs.m=m;
  Bs.E=E;
  Bs.v=v;
  Bs.fout=fout;
end;

if (nargout==0),
  figure(1)
  subplot(211)
  plot(t,N)
  subplot(212)
  plot(t,hf,t,hm)
  figure(2)
  subplot(211)
  plot(t,f,t,v,t,m)
  subplot(212)
  plot(t,BOLD)
end;

if (nargin>5),
  BOLDi=interp1(t,BOLD,BOLDtt);
  err=BOLDi-BOLDdata;
  if (nargin==2),
    Bs.BOLDi=BOLDi;
    Bs.err=err;
  end;
  if nargout==0,
    figure(3)
    subplot(211)
    plot(BOLDtt,BOLDdata,t,BOLD,BOLDtt,BOLDi)
    subplot(212)
    plot(err)
  end;
  BOLD=err;
end;


