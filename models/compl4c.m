function dpm_dt=compl4c(t,pm)
% use: [t,pm]=ode23('compl4b',0,100,40*133.32,1e-6);
% pm must be in Pa, t must be in sec

mu=0.004;
mmpa=133.32;
pamm=1/133.32;

c01=2;
c02=2;
c03=2;
ctype=1;

pi=60*mmpa;
po=10*mmpa;
pm10=40*mmpa;
pm20=25*mmpa;
pm30=15*mmpa;

r01=.1e-4;
l01=1e-2;
v01=pi*r01*r01*l01;
vf1=0.25;
rr=8*mu*l01/(pi*r01*r01*r01*r01);

r02=.1e-4;
l02=1e-2;
v02=pi*r02*r02*l02;
vf2=0.10;
n2=ceil((v01/v02)*(vf2/vf1));

r03=.1e-4;
l03=1e-2;
v03=pi*r03*r03*l03;
vf3=0.65;
n3=ceil((v02/v03)*(vf3/vf2));

k=40;
fp=0.3;
vp=((fp+1)^0.4)-1;
k1=(rr/rr)*(fp+1)/(exp(k*vp)-1);

us=4;
ud=10;
ut=2;
ua=-0.5;
if (t<us),
  u=0;
elseif ((t>=us)&(t<(us+ud))),
  u=1-exp(-(t-us)/ut);
elseif (t>=(us+ud)),
  u=(1-exp(-(us+ud)/ut))*exp(-(t-(us+ud))/ut);
end;
r1=rr*(1+ua*u);
r2=rr*(pm10-pm20)/(pi-pm10);
r3=rr*(pm20-pm30)/(pi-pm10);
r4=rr*(pm30-po)/(pi-pm10);

r0t1=((8*mu*l01)./(pi*r1)).^(1/4);
%v0t1=0.5*pi*r0t1.*r0t1*l01+0.5*v01;
v0t1=v01;
v0t2=v02;
v0t3=v03;

c1=(1/c01)*(v0t1/pm10);
v1=v0t1+(v0t1/c01)*(pm(1)/pm10-1);

c2=(1/c02)*(v0t2/pm20);
v2=v0t2+(v0t2/c02)*(pm(2)/pm20-1);

if (ctype==1),
  c3=(v0t3/k)*(1/(pm(3)-pm30+k1*pm30));
  v3=v0t3+(v0t3/k)*log((1/k1)*(pm(3)/pm30-1)+1);
else,
  c3=(1/c03)*(v0t3/pm30);
  v3=v0t3+(v0t3/c03)*(pm(3)/pm30-1);
end;
%r2=r2*(v01/v1);
%r3=r3*(v02/v2);
%r4=r4*(v03/v3);

dpm_dt(1) = (1/c1)*( ((pi-pm(1))/r1) - ((pm(1)-pm(2))/r2) );
dpm_dt(2) = (1/c2)*( ((pm(1)-pm(2))/r2) - ((pm(2)-pm(3))/r3) );
dpm_dt(3) = (1/c3)*( ((pm(2)-pm(3))/r3) - ((pm(3)-po)/r4) );

