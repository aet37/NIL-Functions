
clear all

dx=5e-5;
L=1e-2;
x=[0:dx:L]';

r0=200e-6;
r1=30e-6;

mmHg2Pa=133.322; Pa2mmHg=1/133.322;
p0=60*mmHg2Pa;
mu=0.0001;
v0=1e-3;
q0=1.1*pi*r0*r0*v0;

dt=2e-1;
T=50e0;
t=[0:dt:T]';

u=rect(t,8,9);
Y1(1)=0; Y2(1)=0;
Y1tau=2; Y2tau=10;
Y1amp=0.5; Y1amp2=0.25; Y2amp=2.0;
for m=1:length(t),
  if (m<length(t)),
    Y1(m+1)= Y1(m) + dt*( (1/Y1tau)*u(m) - (1/Y1tau)*Y1(m) );
    Y2(m+1)= Y2(m) + dt*( (1/Y2tau)*u(m) - (1/Y2tau)*Y2(m) );
  end;
end;
q=q0*(1+Y1amp*Y1');
pin=p0*(1+Y1amp2*Y1');
rt=r1*(1+Y2amp*Y2');
re=1e-3*(1-0.3*Y2');
pmaxi=find(pin==max(pin));

for n=1:length(t),
  r(:,n)=r0+rt(n)*diffexp(x,2e-3,re(n));
  v(n)=sum(pi*r(:,n).*r(:,n));
  for m=1:length(x),
    inta=0;
    for k=1:m,
      inta=inta+(1/(r(k,n)^4));
    end;
    term1=8*mu*q(n)*inta/pi;
    p(m,n)=pin(n)-term1;
  end;
end;

figure(1)
subplot(311)
plot(x,r(:,1),x,r(:,pmaxi))
subplot(312)
plot(x,p(:,1)*Pa2mmHg,x,p(:,pmaxi)*Pa2mmHg)
subplot(313)
plot(v./v(1),pin./pin(1))

