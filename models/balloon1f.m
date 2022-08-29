function [Fin,Fout,VV,t]=balloon1f(x,tparms,parms,parms2fit,data)
% Usage ... [Fin,Fout,VV]=balloon1f(x,tparms,parms,parms2fit,data)

% tparms = [dt T]
% parms = [ust udur uramp yamp ytau F0 V0 Vk1]

if (~isempty(parms2fit)), parms(parms2fit)=x; end;

T=tparms(2);          % units: min
dt=tparms(1);   % units: min (0.5 sec resolution)
t=[0:dt:T];

grubb=0.4;
F0=parms(6);
V0=parms(7);
Vk1=parms(8);

ust=parms(1); udur=parms(2); uramp=parms(3);
utype=[1];
yamp=parms(4);
ytau=parms(5);

VV(1)=V0;
y(1)=0;
for mm=2:length(t),

  y(mm)=y(mm-1)+(dt/ytau)*( mytrapezoid(t(mm-1),ust,udur,uramp,utype)-y(mm-1) );
  Fin(mm-1) = F0*(1+yamp*y(mm-1));

  VV(mm)=VV(mm-1)+(dt/(1+F0*Vk1))*( Fin(mm-1) - F0*((VV(mm-1)/V0)^(1/grubb)) );

  Fout(mm-1) = F0*( (VV(mm-1)/V0)^(1/grubb) + Vk1*(VV(mm)-VV(mm-1))/dt );

end;
Fin(mm)=Fin(mm-1);
Fout(mm)=Fout(mm-1);

if (nargin>4),
  if (outdata==1),
    yy=Fin;
  elseif (outdata==2),
    yy=Fout;
  elseif (outdata==3),
    yy=VV;
  else,
    yy=[Fin Fout VV];
  end;
  zz=yy-data;
  x,
  sum(sum(zz.*zz))/length(zz),
  Fin=zz;
end;
 
