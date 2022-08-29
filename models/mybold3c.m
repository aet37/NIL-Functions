function [y,qin,qout,v,e,q,mtt,p,vel]=mybold(x,t,parms,parmstofit,data,erange)
% Usage ... [y,qin,qout,v,e,q,mtt,p]=mybold(x,t,parms,parmstofit,data,erange)

verbose_flag=1;

if (exist('parmstofit')),
  if (length(x)>0),
    for m=1:length(parmstofit),
      disp(sprintf('parms(%d)= %e',parmstofit(m),x(m)));
      parms(parmstofit(m))=x(m);
    end;
  end;
end;

udur=parms(1);
udel=parms(2);
u=rect(t,udur,[udel+udur/2]);

if (verbose_flag),
  disp(sprintf('Udur= %1.2e  Udel= %1.2e',udur,udel));
end;

%parms1=[Iamp Itau Cart Ccap Cven Cvbas Cvamp Cvtau R10art VcapVart VvenVcap]
%parms1=[0.15 2.0 1e14 3e15 8e12 2e13 -0.25 15 25e-6 0.2 10.0];
parms1def=[+0.05 2.0 1e14 3e15 8e12 2e14 -0.25 15 28e-6 1e-3 5e-6 400e-6 80e-6 90e-3 0.2 10.0 70 30 20 14];
parms1=[parms(3:22)];

parms1(3:6)=parms1(3:6)*1e-12;
parms1(9:14)=parms1(9:14)*1e+3;

[qin,qout,v,mtt,p,vel]=elecan2fc(t,u,parms1);

%parms2=[dt [dHB]0 v0 E0 Q0];
parms2def=[t(2)-t(1) 1 v(1,3) 0.4 1e-10];
%parms2=[t(2)-t(1) parms2(1) v(1,3) parms2(2) parms2(3)];
parms2=[t(2)-t(1) parms(23) v(1,3) parms(24:end)];

[y,q,e]=fvtods2(qin,qout,v,parms2);

if (nargin>4),
  %y=sum(v'); y=y/y(1);
  %yo=y;
  y=y-data;
  if (exist('erange')), y=y(erange(1):erange(2)); end;
  ee=y.*y; ee=sum(ee)/length(ee);
  disp(sprintf('Error= %e',ee));
end;

if (nargout==0),
  if (nargin>4),
    plot(t,data,t,yo)
  else,
    plot(t,y)
  end;
end;

