function [BOLD,Fout,Q]=simpleBOLD(CBF,CBV,E,parms)
% Usage ... B=simpleBOLD(CBF,CBV,E,parms)
%
% parms=[dt k tau0 Ca F0 V0]

% Note, V0 is the initial VENOUS volume
% Take for example F0 = 50 ml/min
% for a transit time of 1/50 min (~1s) we need
% V0 ~ 1ml

dt=parms(1);
k=parms(2);
tau=parms(3);
Ca=parms(4);
if (CBF(1)==1), F0=parms(5); CBF=CBF*F0; end;
if (CBV(1)==1), V0=parms(6); CBV=CBV*V0; end;

Fin=CBF(:);
V=CBV(:);
E=E(:);

Q(1)=Ca*E(1)*V(1);
Fout(1)=Fin(1);
for mm=2:length(Fin),
  Fout(mm) = Fin(mm) - (1/dt)*( V(mm)-V(mm-1) );
  Q(mm) = Q(mm-1) + dt*( Fin(mm-1)*E(mm-1)*Ca - Fout(mm-1)*Q(mm-1)/V(mm-1) );
end;
Fout=Fout(:);
Q=Q(:);
rQ=Q/Q(1);
rV=V/V(1);

% Q is the amount of blood oxygen delivered which is proportional
% to the amount of venous deoxy-hemoglobin

BOLD = 1 - rQ;

sb1=7*E(1)*(3.0/1.5);
sb2=2;
sb3=2*E(1)-0.2;
BOLD =  sb1*(1-rQ) + sb2*(1-rQ./rV) + sb3*(1-rV);
k=k*0.2;

BOLD = k*BOLD + 1;

if (nargout==0),
  subplot(311)
  plot([Fin Fout])
  subplot(312)
  plot(V)
  subplot(313)
  plot([BOLD rQ])
end;

