
clear all

mmHg2Pa=133.322;
Pa2mmHg=1/133.322;

dx=2e-5;
L=1e-4;
x=[0:dx:L];

mu=0.004;
Q0=1e-10;
p0=70*mmHg2Pa;
a0=100e-6;
alpha=1e-10;

p(1)=p0;
a(1)=a0+(alpha/2)*p(1);
for m=1:length(x)-1,
  %[a(m)^5 20*mu*Q0*alpha*m*dx/pi],
  a(m+1)=( a(1)^5 - 20*mu*Q0*alpha*(m*dx)/pi )^(1/5);
  p(m+1)=(2/alpha)*(a(m+1)-a0);
end;

clf
subplot(211)
plot(x,a)
xlabel('Position'), ylabel('Radius')
subplot(212)
plot(x,p*Pa2mmHg)
xlabel('Position'), ylabel('Pressure')

