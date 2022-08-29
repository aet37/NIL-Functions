
clear all

mmHg2Pa=133.322;
Pa2mmHg=1/133.322;

visc=0.004;

r1=100e-6;
L1=1e-2;
v1=5e-2;
R1=8*visc*L1/(pi*r1*r1*r1*r1);
Q1=pi*r1*r1*v1;
P1=60*mmHg2Pa;

dt=1e-2;
t=[0:dt:100];
tlen=length(t);
u=rect(t,5,10);

Y1tau=2;
Y2tau=2;
Y1(1)=0;
Y2(1)=0;
for m=2:length(t),
  Y1(m) = Y1(m-1) + dt*( (1/Y1tau)*u(m-1) - (1/Y1tau)*Y1(m-1) );
  Y2(m) = Y2(m-1) + dt*( (1/Y2tau)*u(m-1) - (1/Y2tau)*Y2(m-1) );
end;

pp=[1.0 1.10 1.20 1.30 1.40 1.60];
vv=[1.0 1.15 1.24 1.28 1.29 1.30];  
pcoeff=polyfit(pp,vv,5);

ncomp=2;

R(1)=R1;
Q(1)=Q1;
P(1)=P1;
p(:,1)=1+0.50*Y1';
q(:,1)=1+0.50*Y1';
for n=1:ncomp,
  pc(:,n)=p(:,n)-q(:,n)*Q(n)*R(n)/P(n);
  v(:,n)=polyval(pcoeff,pc(:,n)./pc(1,n));
  for m=2:tlen,
    q(m,n+1)=q(m-1,n)-(1/dt)*(v(m,n)-v(m-1,n));
  end;
  q(1,n+1)=q(2,n+1);
  Q(n+1)=Q(n);
  P(n+1)=P(n);
  R(n+1)=R(n);
  p(:,n+1)=pc(:,n)-q(:,n+1)*R(n+1)*Q(n+1)/P(n+1);
end;

