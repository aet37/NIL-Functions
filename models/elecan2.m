
% the compliance of a vein is ~ 24x that of its corresponding
% artery because its ~ 8x more distensible and has ~ 3x the volume

clear all

mmHg2Pa=133.32;
Pa2mmHg=1/133.32;

mu=0.004;		% Pa s

%       mmHg		 m		  m
Pa0=100;
Paend1=95;	ra1=1e-2;	la1=4e-1;
Paend2=84;	ra2=2e-3;	la2=1e-1;
Paend3=40;	ra3=25e-6;	la3=2e-3;
Pendcap=15;	rcap=5e-6;	lcap=200e-6;
Pvend3=6;	rv3=35e-6;	lv3=2e-3;
Pvend2=3;	rv2=3e-3;	lv2=2e-2;
Pvend1=1;	rv1=1e-2;	lv1=4e-1;

% Heart
Qdottotal=5e-3/60;		% m^3/s
Ptotal=(Pa0-Pvend1)*mmHg2Pa;	% N/m^2
Rtotal=Ptotal/Qdottotal;	% Ns/m^5

dt=1e-1;
t=[0:dt:100];
tlen=length(t);
u=rect(t,10,20);
Y(1)=0; Yamp=0.15; Ytau=2;
for m=1:tlen,
  % first-order dynamics
  if (m>1), 
    Y(m) = Y(m-1) + dt*( (1/Ytau)*u(m-1) - (1/Ytau)*Y(m-1) );
  end;
  YY(m)=1+Yamp*Y(m);

  % Arteriole
  dvddp_a3=1e15;
  if (m==1), 
    Pa3(1)=(Paend2(1)-Paend3(1))*mmHg2Pa; 
    Ra3=8*mu*la3/(pi*ra3*ra3*ra3*ra3);
  end;
  ra3a(m)=ra3*YY(m);
  Ra3a(m)=8*mu*la3/(pi*ra3a(m)*ra3a(m)*ra3a(m)*ra3a(m));
  Qa3i(m)=Pa3(1)/Ra3a(m);
  Qa3o(m)=Pa3(m)/Ra3;
  if (m<tlen),
    Pa3(m+1)=Pa3(m)+dt*dvddp_a3*(Qa3i(m)-Qa3o(m));
    Paend2(m+1)=Paend2(1)+Pa3(m)*Pa2mmHg;
    Paend3(m+1)=Paend3(m);
  end;
  Va3(m) = (1/dvddp_a3)*Pa3(m) + pi*ra3*ra3*la3;

  % Capillaries
  dvddp_cap=2e15;
  if (m==1),
    Pcap(m)=(Paend3(m)-Pendcap(m))*mmHg2Pa;
    Rcap=8*mu*lcap/(pi*rcap*rcap*rcap*rcap);
    Qcap=Pcap/Rcap;
    ncaps=ceil(Qa3o(m)/Qcap);
    Qpercapi=Qa3o/ncaps;
    %Rpercap=8*mu*lcap/(pi*rcap*rcap*rcap*rcap);
    Rpercap=Pcap/Qpercapi;
    rcap2=(8*mu*lcap/(pi*Rpercap))^(1/4);
  end;
  Qpercapi(m)=Qa3o(m)/ncaps;
  Qpercapo(m)=Pcap(m)/Rpercap;
  %Qpercapo(m)=Pcap(m)/Rpercap; eQpercap(m)=Qpercapi(m)-Qpercapo(m);	% problematic?
  if (m<tlen),
    Pcap(m+1)=Pcap(m)+dt*dvddp_cap*(Qpercapi(m)-Qpercapo(m));
    Paend3(m+1)=Paend3(1)+Pcap(m)*Pa2mmHg;
    Pendcap(m+1)=Pendcap(m);    
  end;
  Vcap(m) = (1/dvddp_cap)*Pcap(m) + pi*rcap2*rcap2*lcap*ncaps;

  % Venuole
  dvddp_v3=4e12;
  if (m==1),
    Pv3(m)=(Pendcap(m)-Pvend3(m))*mmHg2Pa;
    Rv3=8*mu*lv3/(pi*rv3*rv3*rv3*rv3);
    Qv3=Pv3/Rv3;
    nv3=floor((Qpercapo(m)*ncaps)/Qv3);
    Qperv3i=Qpercapo(m)*ncaps/nv3;
    %Rperv3=8*mu*lv3/(pi*rv3*rv3*rv3*rv3);
    Rperv3=Pv3/Qperv3i;
    rperv3=(8*mu*lv3/(pi*Rperv3))^(1/4);
  end;
  Qperv3i(m)=Qpercapo(m)*ncaps/nv3;
  Qperv3o(m)=Pv3(m)/Rperv3;
  if (m<tlen),
    Pv3(m+1)=Pv3(m)+dt*dvddp_v3*(Qperv3i(m)-Qperv3o(m));
    Pendcap(m+1)=Pendcap(1)+Pv3(m)*Pa2mmHg;
    Pvend3(m+1)=Pvend3(m);
  end;
  Vv3(m) = (1/dvddp_v3)*Pv3(m) + pi*rperv3*rperv3*lv3*nv3;

end;

% mean transit-time calculation of the segments
mtta3=(0.5*Qa3i+0.5*Qa3o)./Va3;
mttcap=(0.5*Qpercapi-0.5*Qpercapo)./Vcap;
mttv3=(0.5*Qperv3i-0.5*Qperv3o)./Vv3;

v=Vv3;
fin=Qperv3i;
fout=Qperv3o;

E0=0.4;
v0=v(1);

Nav=6.022e23;
Hct=0.4;
cHb=(1/65000)*50e-12/(Hct*v(1));
q0=v(1)*cHb*E0;

k1=v0*cHb*E0;
k2=k1;

Y2(1)=0; Y2amp=0.4; Y2tau1=0.5; Y2tau2=0.8;
for m=1:tlen,
  % first-order dynamics
  if (m>1),
    Y2(m) = Y2(m-1) + dt*( (1/Y2tau1)*u(m-1) - (1/Y2tau2)*Y2(m-1) );
  end;
  YY2(m)=1-Y2amp*Y2(m);
end;

oxlim=1;
if (oxlim),
  ke1=1;
  %ke1=1.19;
  ke=ke1*fin(1)./fin-(ke1-1);
  %ke=YY2;
  E=1-((1-E0).^(ke));
else,
  E=ones(size(fin));
end;

q(1)=q0;
for m=1:length(fin)-1,
 q(m+1) = q(m) + dt*( (q0/v0)*(E(m)/E0)*fin(m) - (q(m)/v(m))*fout(m) );
end;
rqin=(q0/v0)*(E/E0).*fin;
rqout=(q./v).*fout;

TE=1;
ks=1;
nq=q./q(1);
s=1-ks*nq*TE;



% output data
figure(1)
subplot(411)
plot(t,Paend2,t,Paend3,t,Pa3*Pa2mmHg)
ylabel('Pressure'), xlabel('Time'),
subplot(412)
plot(t,Qa3i,t,Qa3o)
ylabel('Flow'), xlabel('Time'),
subplot(413)
plot(t,Ra3a)
ylabel('Resistance'), xlabel('Time'),
subplot(414)
plot(t,Va3)
ylabel('Volume'), xlabel('Time'),
figure(2)
subplot(311)
plot(t,Paend3,t,Pendcap,t,Pcap*Pa2mmHg)
ylabel('Pressure'), xlabel('Time'),
subplot(312)
plot(t,Qpercapi,t,Qpercapo)
ylabel('Flow'), xlabel('Time'),
subplot(313)
plot(t,Vcap)
ylabel('Volume'), xlabel('Time'),
figure(3)
subplot(311)
plot(t,Pendcap,t,Pvend3,t,Pv3*Pa2mmHg)
ylabel('Pressure'), xlabel('Time')
subplot(312)
plot(t,Qperv3i,t,Qperv3o)
ylabel('Flow'), xlabel('Time'),
subplot(313)
plot(t,Vv3)
ylabel('Volume'), xlabel('Time'),
figure(4)
subplot(311)
plot(t,E)
ylabel('Extraction Fraction'), xlabel('Time'),
subplot(312)
plot(t,q)
ylabel('Tracer Amount'), xlabel('Time'),
subplot(313)
plot(t,s)
ylabel('% MR Signal'), xlabel('Time'),

