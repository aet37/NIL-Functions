
clear all

mmHg2Pa=133.322; Pa2mmHg=1/133.322;

mu=0.004;
a0=100e-6;
h0=0.15*a0;
E0=2e5;

Q0=1e-10;
p0=70*mmHg2Pa;

dx=20e-6; L=1e-2;
x=[0:dx:L];

alpha=1e-8;

p(1)=p0;
a(1)=a0+(alpha/2)*p(1);
for m=1:length(x)-1,
  vv(m)=pi*a(m)*a(m)*dx;
  term1=-8*mu*Q0/pi;
  term2=(alpha/2);
  term3=5*(m*dx);
  [a(1) term1*term2*term3],
  a(m+1)=(a(1)^5+term1*term2*term3)^(1/5);
  p(m+1)=(2/alpha)*(a(m+1)-a0);
end;
vv(m+1)=pi*a(m+1)*a(m+1)*dx;
v=sum(vv);

plot(x,a)

