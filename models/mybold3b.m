function [y,qin,qout,v,e,q,mtt,p,vel]=mybold(x,t,u,parms,parmstofit,data,erange)
% Usage ... [y,qin,qout,v,e,q,mtt,p]=mybold(x,t,u,parms,parmstofit,data,erange)

verbose_flag=1;

if (exist('parmstofit')),
  if (length(x)>0),
    for m=1:length(parmstofit),
      disp(sprintf('parms(%d)= %e',parmstofit(m),x(m)));
      parms(parmstofit(m))=x(m);
    end;
  end;
end;

%parms1=[Iamp Itau Cart Ccap Cven Cvbas Cvamp Cvtau R10art VcapVart VvenVcap]
%parms1=[0.15 2.0 1e14 3e15 8e12 2e13 -0.25 15 25e-6 0.2 10.0];
parms1def=[+0.05 2.0 1e14 3e15 8e12 2e14 -0.25 15 28e-6 1e-3 5e-6 400e-6 80e-6 90e-3 0.2 10.0 70 30 20 14];
parms1=[parms(1:20)];

parms1(1:4)=parms1(1:4)*1e-12;
parms1(7:12)=parms1(7:12)*1e+3;

[qin,qout,v,mtt,p,vel]=elecan2fc(t,u,parms1);

%parms2=[dt [dHB]0 v0 E0 Q0];
parms2def=[t(2)-t(1) 1 v(1,3) 0.4 1e-10];
%parms2=[t(2)-t(1) parms2(1) v(1,3) parms2(2) parms2(3)];
parms2=[t(2)-t(1) parms(21) v(1,3) parms(22:end)];

[y,q,e]=fvtods2(qin,qout,v,parms2);

if (nargin>5),
  yo=y;
  y=y-data;
  if (nargin>6), y=y(erange(1):erange(2)); end;
  disp(sprintf('Error= %e',sqrt((1/length(y))*sum((y).^2))));
end;

if (nargout==0),
  if (nargin>5),
    plot(t,data,t,yo)
  else,
    plot(t,y)
  end;
end;

