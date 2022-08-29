function [BOLD,Q,V,Fout]=balloonBOLD(CBF,E,parms)
% Usage ... [BOLD,Q,V,Fout]=balloonBOLD(CBF,E,parms)
%
% parms=[dt k Ca F0 V0 stype ctype ...]

% Note, V0 is the initial VENOUS volume
% Take for example F0 = 50 ml/min
% for a transit time of 1/50 min (~1s) we need
% V0 ~ 1ml

dt=parms(1);
k=parms(2);
Ca=parms(3);
F0=parms(4);
V0=parms(5);
stype=parms(6);
ctype=parms(7);
if (ctype==2),
  Vk1=parms(8); Vk2=parms(9);
elseif (ctype==3),
  Vk1=parms(8); Vk2=parms(9); Vk3=parms(10);
elseif (ctype==4),
  Vk1=parms(8);
end;

grubb=0.4;
if (CBF(1)==1), CBF=CBF*F0; end;

Fin=CBF(:);
E=E(:);

V(1)=V0;
Q(1)=Ca*E(1)*V0;
Fout(1)=Fin(1);
for mm=2:length(Fin),
  if (ctype==2),
    Fout(mm-1) = F0*( Vk2*(exp(Vk1*(V(mm-1)/V0-1))-1)+1 );
    V(mm) = V(mm-1) + dt*( Fin(mm-1) - Fout(mm-1) );
  elseif (ctype==3),
    V(mm) = V(mm-1) + dt*(1/(1+F0*Vk3))*( Fin(mm-1) - F0*(Vk2*(exp(Vk1*(V(mm-1)/V0-1))-1)+1) );
    Fout(mm) = Fin(mm) - (1/dt)*( V(mm)-V(mm-1) );
  elseif (ctype==4),
    V(mm) = V(mm-1) + dt*(1/(1+F0*Vk1))*( Fin(mm-1) - F0*((V(mm-1)/V0)^(1/grubb)) );
    Fout(mm) = Fin(mm) - (1/dt)*( V(mm)-V(mm-1) );
  else,
    Fout(mm-1) = F0*( (V(mm-1)/V0)^(1/grubb) );
    V(mm) = V(mm-1) + dt*( Fin(mm-1) - Fout(mm-1) );
  end;
  Q(mm) = Q(mm-1) + dt*( Fin(mm-1)*E(mm-1)*Ca - Fout(mm-1)*Q(mm-1)/V(mm-1) );
end;
Fout(mm)=Fout(mm-1);
Fout=Fout(:);
V=V(:);
Q=Q(:);
rQ=Q/Q(1);
rV=V/V(1);

% Q is the amount of blood oxygen delivered which is proportional
% to the amount of venous deoxy-hemoglobin

if (stype==0),

  BOLD = 1 - rQ;
  BOLD = k*BOLD + 1;

else,

  sb0=1.5;
  sb1=7*E(1)*(sb0/1.5);
  sb2=2;
  sb3=2*E(1)-0.2;
  BOLD =  sb1*(1-rQ) + sb2*(1-rQ./rV) + sb3*(1-rV);
  k=k*0.2;

  BOLD = k*BOLD + 1;

end;


if (nargout==0),
  subplot(311)
  plot([Fin Fout])
  subplot(312)
  plot(V)
  subplot(313)
  plot([BOLD rQ])
end;

