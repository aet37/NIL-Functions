function dpm_dt=compl4c(t,pm)
% use: [t,pm]=ode23_v5('compl4b',0,100,40*133.32,1e-6);
% pm must be in Pa, t must be in sec
% then use: 

if (nargin<4), tp=t-1; end;
if (nargin<3), pmp=pm; end;

mu=0.004;
mmpa=133.32;
pamm=1/133.32;

pin=60*mmpa;
po=10*mmpa;
pm10=40*mmpa;
pm20=25*mmpa;
pm30=15*mmpa;
pic=0;
px1=pic*mmpa;
px2=pic*mmpa;
px3=pic*mmpa;

r01=45e-6;
l01=5e-3;
v01=pi*r01*r01*l01;
vf1=0.25;
rr=8*mu*l01/(pi*r01*r01*r01*r01);

r02=5e-6;
l02=5e-4;
v02=pi*r02*r02*l02;
vf2=0.10;
n2=ceil((v01/v02)*(vf2/vf1));

r03=1e-4;
l03=2e-3;
v03=pi*r03*r03*l03;
vf3=0.65;
n3=ceil((v02/v03)*(vf3/vf2));

c01=1;
c02=2;
c03=.1;
ctype=1;

k=+35;
fp=+0.5;
vp=((abs(fp)+1)^0.4)-1;
k1=(rr/rr)*(abs(fp)+1)/(exp(abs(k)*vp)-1);
if k<0, k1=-k1; end;

us=3;
ud=13;
ut=5;
ua=-0.95;
if (t<us),
  u=0;
elseif ((t>=us)&(t<(us+ud))),
  u=1-exp(-(t-us)/ut);
elseif (t>=(us+ud)),
  u=(1-exp(-(us+ud)/ut))*exp(-(t-(us+ud))/ut);
end;
r1=rr*(1+ua*u);
r2=rr*(pm10-pm20)/(pin-pm10);
r3=rr*(pm20-pm30)/(pin-pm10);
r4=rr*(pm30-po)/(pin-pm10);

r0t1=((8*mu*l01)./(pi*r1)).^(1/4);
%v0t1=0.5*pi*r0t1.*r0t1*l01+0.5*v01;
v0t1=v01;
v0t2=v02;
v0t3=v03;

c1=(1/c01)*(v0t1/(pm10-px1));
v1=v0t1+(v0t1/c01)*(pm(1)/pm10-1);

c2=(1/c02)*(v0t2/(pm20-px2));
v2=v0t2+(v0t2/c02)*(pm(2)/pm20-1);

if (ctype==1),
  c3=(v0t3/k)*(1/(pm(3)-pm30+k1*pm30));
  v3=v0t3+(v0t3/k)*log((1/k1)*(pm(3)/pm30-1)+1);
elseif (ctype==2),
  c3=(v0t3/k)*(1/(pm(3)-pm30+k1*pm30));
  c3=c3+(1/c03)*(v0t3/pm30);
  v3=(v0t3/k)*log((1/k1)*(pm(3)/pm30-1)+1);
  v3=v0t3+(v0t3/c03)*(pm(3)/pm30-1);
elseif (ctype==3),
  kc1=1e-6;
  c3=(v0t3/k)*(1/(pm(3)-pm30+k1*pm30));
  c3=c3+kc1*(pm(3)-pmp(3))/(t-tp);
  v3=v0t3+(v0t3/k)*log((1/k1)*(pm(3)/pm30-1)+1);
  v3=v3+kc1*((pm(3)-pmp(3))/(t-tp))*(pm(3)-pm30);
else,
  c3=(1/c03)*(v0t3/pm30);
  v3=v0t3+(v0t3/c03)*(pm(3)/pm30-1);
end;
%r2=r2*((v01/v1)^(2));
%r3=r3*(v02/v2)*(v02/v2);
%r4=r4*(v03/v3)*(v03/v3);

dpm_dt(1) = (1/c1)*( ((pin-pm(1)-px1)/r1) - ((pm(1)+px1-pm(2))/r2) );
dpm_dt(2) = (1/c2)*(1/n2)*( ((pm(1)+px1-pm(2)-px2)/r2) - ((pm(2)+px2-pm(3))/r3) );
dpm_dt(3) = (1/c3)*(1/n3)*( ((pm(2)+px2-pm(3)-px3)/r3) - ((pm(3)+px3-po)/r4) );

e0=0.4;
deff=((0.5*((pm10-pm20)/r2 + (pm20-pm30)/r3 ))/v02)*log(1/(1-e0));
deff=deff*v2;
e=1-exp(-deff/(0.5*( (pm(1)+px1-pm(2)-px2)/r2 + (pm(2)+px2-pm(3)-px3)/r3 )));

q=pm(4);
q0=1;
dq_dt = (e/e0)*((pm(2)+px2-pm(3)-px3)/r3)/v03 - (q/q0)*((pm(3)+px3-po)/r4)/v3 ;
dpm_dt(4)=dq_dt;

ks=1;
ka=1;
TE=1;
nq=q/q0;
s=ka*(1-ks*nq*TE);

