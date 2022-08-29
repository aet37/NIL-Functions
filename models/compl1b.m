
clear all

mmHg2Pa=133.32;
Pa2mmHg=1/mmHg2Pa;
m32ml=1e6;
ml2m3=1e-6;
min2sec=1/60;
sec2min=60;

ctype=2;
doplots=1;

dt=0.005;
t=[0:dt:50];
tlen=length(t);

mu=0.004;
alpha=0.4;
L=1e-2;

F0=60*ml2m3*min2sec;

P1=40*mmHg2Pa;
P2=20*mmHg2Pa;
P3=10*mmHg2Pa;
P0=5*mmHg2Pa;

R0=(P1-P2)/F0;
D=((128*mu*L)/(pi*R0))^(1/4);
V0=pi*((D/2)^2)*1e-2;

Ca=9;
E0=0.4;
q0=Ca*E0*V0;

U=mytrapezoid(t,10,10,2);

F1p=0.7; V1p=((F1p+1)^alpha)-1; 
R1=R0;
k=1; k1=(R0/R1)*(F1p+1)/(exp(k*V1p)-1);
k=30; k1=0.01;
k2=1.36e-17;
C0=(V1p*V0)/(F1p*P2);

V(1)=V0;
Pm(1)=P2;
q(1)=q0;

ytau=5; yamp=+0.40; y(1)=0;
y2tau=40; y2amp=-2.0; y2(1)=0;
xflag=0;

for m=1:length(t),

  dPdt(m)=0;

  if (m>1),
    y(m)=y(m-1)+dt*( (1/ytau)*( u(m-1) - y(m-1) ));
    y2(m)=y2(m-1)+dt*( (1/y2tau)*( u(m-1) - y2(m-1) ));
    dPdt(m)=(Pm(m)-Pm(m-1))/dt;
  end;

  Ra(m) = 0.5*R0*((1+yamp*y(m))^(-4));
  Va(m) = (0.5*V0 + pi*((D*(1+yamp*y(m))/2)^2)*(L/2));

  Qin(m) = ( P1 - Pm(m) )/Ra(m);
  Qout(m) = ( Pm(m) - P3 )/(0.5*R0);

  PPm(m)=(Pm(m)-P0);

  % determine compliance and volume
  if (ctype==4),	% ad-hoc, not correct for either C or V
    k4=3;
    C(m)=C0*k4*(1+y2amp*y2(m));
    V(m)=V(1)+C(m)*(PPm(m)-PPm(1));
  elseif (ctype==21),	% exponential, dP/dt
    C(m)=(V(1)/k)*(1/(PPm(m)-PPm(1)+k1*PPm(1)))+k2*dPdt(m);
    if (C(m)<=0), disp('Warning: C < 0 !!!'); end;
    % this may not be right
    if (dPdt(m)<0), dPdt2(m)=-dPdt(m); else, dPdt2(m)=dPdt(m); end;
    if (m>1), iPdP(m)=trapz(PPm(1:m),dPdt2(1:m)); else, iPdP(m)=0; end;
    Vdp=k2*iPdP(m);
    V(m)=(V(1)/k)*log((1/k1)*(PPm(m)/PPm(1)-1)+1)+V(1)+Vdp;
  elseif (ctype==2),	% exponential
    C(m)=(V(1)/k)*(1/(PPm(m)-PPm(1)+k1*PPm(1)));
    V(m)=(V(1)/k)*log((1/k1)*(PPm(m)/PPm(1)-1)+1)+V(1);
  else,		% constant
    C(m)=C0;
    V(m)=V(1)+C(m)*(PPm(m)-PPm(1));
  end;

  E(m) = 1 - (1-E0)^(Qin(1)/Qin(m));

  if (m<tlen),
    Pm(m+1) = P0 + ( Pm(m) - P0 ) + (dt/C(m))*( Qin(m) - Qout(m) );
    q(m+1) = q(m) + dt*( q0*(E(m)/E0)*(Qin(m)/V(1)) - q(m)*(Qout(m)/V(m)) );
  end;

end;

%Qin=N*Qin;
%Qout=N*Qout;
%V=N*V;

kk=1;
S = 1 - kk*(q/q(1));

if (doplots),
  figure(1)
  subplot(231)
  plot(t,Qin,t,Qout)
  legend('Qin','Qout')
  subplot(232)
  plot(t,Pm*Pa2mmHg)
  legend('Pm')
  subplot(233)
  plot(t,V*m32ml),
  legend('V'),
  subplot(234)
  plot(V/V(1),PPm/PPm(1))
  xlabel('rV'), ylabel('rPm'),
  subplot(235)
  plot(t,C)
  legend('C')
  subplot(236)
  plot(t,dPdt)
  legend('dPdt')
  
  figure(2)
  plot(t,(PPm/PPm(1)-1),t,(V/V(1)-1),t,(Qin/Qin(1)-1),t,(Qout/Qout(1)-1))
  axis('tight'), grid,
  legend('rP','rV','rQin','rQout')
  title(sprintf('rPm= %f, rV= %f (%f), rQ= %f %f',max(PPm/PPm(1)),max(V/V(1)),max(Qin/Qin(1))^alpha,max(Qin/Qin(1)),max(Qout/Qout(1))))
end;

