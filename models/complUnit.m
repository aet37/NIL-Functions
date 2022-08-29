function [P2new,C,V,Q1,Q2,dP2dt_2]=complUnit(P,P0,R,Cparms,dt,V0,P2t)
% Usage ... [P2new,C,V,Q1,Q2,dPdt]=complUnit(P123,P0,R12,Cparms,dt,V0,P2t)

if (length(P2t)>1), Cdpdt=1; else, Cdpdt=0; end;

Q1=(P(1)-P(2))/R(1);
Q2=(P(2)-P(3))/R(2);

PP2=P(2)-P0;
PP20=P2t(1)-P0;

ctype=Cparms(1);
if (ctype==4),	% ad-hoc, not correct for either C or V
  C0=Cparms(2); y2=Cparms(3); y2amp=Cparms(4); 
  k1=3;
  C = C0*k1*(1+y2amp*y2);
  V = V0 + C*(PP2-PP20);
elseif (ctype==2),	% exponential
  k=Cparms(2); k1=Cparms(3);
  C=(V0/k)*(1/(PP2-PP20+k1*PP20));
  V=(V0/k)*log((1/k1)*(PP2/PP20-1)+1)+V0;
else,	% constant
  C0=Cparms(2);
  C = C0;
  V = V0 + C*(PP2-PP20);
end;

if (Cdpdt),
  k2=Cparms(end);
  dP2dt=diff(P2t)/dt;
  dP2dt=[0 dP2dt];
  C=C+k2*dP2dt(end);
  dP2ineg=find(dP2dt<0);
  dP2dt(dP2ineg)=-1*dP2dt(dP2ineg);
  iPdP=trapz(P2t,dP2dt); 
  Vdp=k2*iPdP;
  V=V+Vdp;
  dP2dt(dP2ineg)=-1*dP2dt(dP2ineg);
  dP2dt=dP2dt(end);
end;

P2new = P0 + (P(2)-P0) + (dt/C)*(Q1-Q2);

dP2dt_2 = (P2new-P(2))/dt;

