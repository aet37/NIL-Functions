function [y,fneu,t]=myCMRO2model(x,tparms,xparms,parms2fit,tdata,data)
% Usage ... [CMRO2,fneu,t]=myCMRO2model(x,tparms,xparms,parms2fit,tdata,data)
%
%


if (~isempty('parms2fit')),
  xparms(parms2fit)=x;
end;

dt=tparms(1);
tfin=tparms(2);
t=[0:dt:tfin];

t0=xparms(1);
udur=xparms(2);
uramp=xparms(3);
namp=xparms(4);
ntau=xparms(5);
utype=[tparms(3) namp ntau];
fneu=mytrapezoid3(t,t0-uramp,udur,uramp,utype);

if (tparms(4)==1),
  ii=find(fneu==1);
  nref=ones(size(fneu));
  nref=nref.*(t<t(ii(end)));
  nref2=(~nref).*exp(-(t-t(ii(end)))/ntau);
  fneu=fneu.*nref + nref2;
end;

kamp=xparms(6);
ytau=xparms(7);

y(1)=0;
for mm=2:length(t),

  y(mm) = y(mm-1) + dt*( (1/ytau)*( kamp*fneu(mm-1) - y(mm-1)) );

end;
y=y+1;


if (nargin>4),
  datai=interp1(tdata,data,t);
  z=datai-y;
  plot(t,datai,t,y)
  [x sum(z.*z)/length(z)],
  y=z;
end;


