
clear all

T=2.0;          % units: min
dt=1/(60*20);   % units: min (0.5 sec resolution)
t=[0:dt:T];

grubb=0.4;
F0=60;
V0=1;
ctype=4;
Vk1=1.0;
Vk2=20;
Vk22=0.004;
Vk3=0.5;

ust=4/60; udur=40/60; uramp=1/60;
utype=[1];
yamp=0.62;
ytau=3/60;

VV(1)=V0;
y(1)=0;
for mm=2:length(t),

  y(mm)=y(mm-1)+(dt/ytau)*( mytrapezoid(t(mm-1),ust,udur,uramp,utype)-y(mm-1) );
  Fin(mm-1) = F0*(1+yamp*y(mm-1));

  if (ctype==2),
    Fout(mm-1)=F0*( Vk22*exp(Vk2*(VV(mm-1)/V0-1)) +1 );
    VV(mm)=VV(mm-1)+dt*(Fin(mm-1)-Fout(mm-1));
  elseif (ctype==3),
    Fout(mm-1)=F0*( Vk22*exp(Vk2*(VV(mm-1)/V0-1)) +1 );
    if (mm>2), dVVdt=(VV(mm-1)-VV(mm-2))/dt; else, dVVdt=0; end;
    Fout(mm-1)=Fout(mm-1) + Vk3*dVVdt;
    VV(mm)=VV(mm-1)+dt*(Fin(mm-1)-Fout(mm-1));
  elseif (ctype==4),
    %VV(mm)=VV(mm-1)+(dt/(1+F0*Vk3))*(Fin(mm-1)-F0*((VV(mm-1)/V0)^(1/grubb)));
    %Fout(mm-1)=F0*((VV(mm-1)/V0)^(1/grubb))+Vk3*(VV(mm)-VV(mm-1))/dt;
    Fout(mm-1)=F0*( Vk1*(((VV(mm-1)/V0)^(1/grubb))-1) +1);
    if (mm>2), dVVdt=(VV(mm-1)-VV(mm-2))/dt; else, dVVdt=0; end;
    Fout(mm-1)=Fout(mm-1) + Vk3*dVVdt;
    VV(mm)=VV(mm-1)+dt*(Fin(mm-1)-Fout(mm-1));
  else,
    Fout(mm-1)=F0*( Vk1*(((VV(mm-1)/V0)^(1/grubb))-1) +1);
    VV(mm)=VV(mm-1)+dt*(Fin(mm-1)-Fout(mm-1));
  end;

end;
Fin(mm)=Fin(mm-1);
Fout(mm)=Fout(mm-1);
 
