
clear all

mu=.004;
mmpa=133.32;
pamm=1/133.32;

pin=60*mmpa;
po=10*mmpa;
pm10=40*mmpa;
pm20=25*mmpa;
pm30=15*mmpa;
px1=+39.9*mmpa;
px2=0*mmpa;
px3=0*mmpa;

q0=1;

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

%[t,pm]=ode23a('compl4d',0,70,[pm10;pm20;pm30;q0],1e-6,0,1,[pm10;pm20;pm30;q0]);
[t,pm]=ode23_v5('compl4e',0,100,[pm10-px1;pm20-px2;pm30-px3;q0],1e-6);
pm=pm+ones([length(t) 1])*[px1 px2 px3 0];

us=3;
ud=13;
ut=5;
ua=-0.95;
for m=1:length(t),
  if (t(m)<us),
    u(m)=0;
  elseif ((t(m)>=us)&(t(m)<(us+ud))),
    u(m)=1-exp(-(t(m)-us)/ut);
  elseif (t(m)>=(us+ud)),
    u(m)=(1-exp(-(us+ud)/ut))*exp(-(t(m)-(us+ud))/ut);
  end;
end; u=u(:);
r1=rr*(1+ua*u);
r2=rr.*(pm10-pm20)./(pin-pm10);
r3=rr.*(pm20-pm30)./(pin-pm10);
r4=rr.*(pm30-po)./(pin-pm10);

r0t1=((8*mu*l01)./(pi*r1)).^(1/4);
%v0t1=0.5*pi*r0t1.*r0t1*l01+0.5*v01;
v0t1=v01;
v0t2=v02;
v0t3=v03;

c1=(1/c01)*(v0t1/(pm10-px1));
v1=v0t1+(v0t1/c01).*(pm(:,1)/pm10-1);

c2=(1/c02)*(v0t2/(pm20-px2));
v2=v0t2+(v0t2/c02).*(pm(:,2)/pm20-1);

if (ctype==1),
  c3=(v0t3/k).*(1./(pm(:,3)-pm30+k1*pm30));
  v3=v0t3+(v0t3/k).*log((1/k1)*(pm(:,3)/pm30-1)+1);
elseif (ctype==2),
  c3=(v0t3/k).*(1./(pm(:,3)-pm30+k1*pm30));
  c3=c3+(1/c03)*(v0t3/pm30);
  v3=(v0t3/k).*log((1/k1)*(pm(:,3)/pm30-1)+1);
  v3=v0t3+(v0t3/c03).*(pm(:,3)/pm30-1);
elseif (ctype==3),
  kc1=1e-6;
  c3=(v0t3/k).*(1./(pm(:,3)-pm30+k1*pm30));
  c3=c3+kc1*diff([pm(:,3);pm(end-1:end,3)])./diff([dt;dt(end-1:end)]);
  v3=v0t3+(v0t3/k).*log((1/k1)*(pm(:,3)/pm30-1)+1);
  v3=v3+kc1*(diff([pm(:,3);pm(end-1:end,3)])./diff([dt;dt(end-1:end)])).*(pm(:,3)-pm30);
else,
  c3=(1/c03)*(v0t3/pm30);
  v3=v0t3+(v0t3/c03).*(pm(:,3)/pm30-1);
end;
%r2=r2.*((v01./v1).^2);
%r3=r3.*(v02./v2).*(v02./v2);
%r4=r4.*(v03./v3).*(v03./v3);

qi=((pin-pm(:,1))./r1);
q1o=((pm(:,1)-pm(:,2))./r2);
q2i=((pm(:,1)-pm(:,2))./r2)*(1/n2);
q2o=((pm(:,2)-pm(:,3))./r3)*(1/n2);
q3i=((pm(:,2)-pm(:,3))./r3)*(1/n3);
qo=((pm(:,3)-po)./r4)*(1/n3);

e0=0.4;
deff=( 0.5*((pm10-pm20)/r2 + (pm20-pm30)/r3)/v02)*log(1/(1-e0));
e=1-exp(-deff*v2./(0.5*( (pm(:,1)-pm(:,2))./r2 + (pm(:,2)-pm(:,3))./r3 )));

q0=1;
q=pm(:,4);

ks=1;
ka=1;
TE=1;
nq=q/q0;
s=ka*(1-ks*nq*TE);

sumv=sum([v1 v2*n2 v3]'); (max(sumv)/sumv(1))^2.5,
subplot(231)
plot(t,[qi q2i*n2 q3i]/qi(1),t,sumv/sumv(1))
ylabel('Norm')
axis('tight')
subplot(232)
plot(t,[v1/v1(1) v2/v2(1) v3/v3(1)])
ylabel('rCBV')
subplot(233)
mtt=2*[v1 v2*n2 v3]./[qi+q1o (q2i+q2o)*n2 q3i+qo];
plot(t,mtt)
axis('tight')
subplot(234)
plot(t,[qi q2i*n2 q3i])
axis('tight')
ylabel('Flow')
subplot(235)
cmro2=0.5*(q2i/q2i(1) + q2o/q2o(1)).*(e/e0);
plot(t,cmro2)
ylabel('CMRO2')
axis('tight')
subplot(236)
plot(t,s)
ylabel('MR Sig')
axis('tight')

