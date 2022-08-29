
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

% Artery to the head
Pa1=(Pa0-Paend1)*mmHg2Pa;		% N/m^2
Ra1=8*mu*la1/(pi*ra1*ra1*ra1*ra1);	% N/m^2 * s * m / m^4 = Ns/m^5
Qa1=Pa1/Ra1;				% m^3/s

% Smaller artery in the head (sink-in)
Pa2=(Paend1-Paend2)*mmHg2Pa;
Ra2=8*mu*la2/(pi*ra2*ra2*ra2*ra2);
Qa2=Pa2/Ra2;
 
  % Parallel branch to handle the excess flow
  Qa2res1=Qa1-Qa2;
  Ra2res1=(Paend1-Pvend2)/Qa2res1;

% Entering microvasculature
dt=1e-1;
t=[0:dt:100];
u=rect(t,10,20);
Y(1)=0; Yamp=0.15; Ytau=2;
for m=1:length(t),

  % first-order dynamics
  if (m>1), 
    Y(m) = Y(m-1) + dt*( (1/Ytau)*u(m-1) - (1/Ytau)*Y(m-1) );
  end;
  YY(m)=1+Yamp*Y(m);

  % arteriole
  Pa3=(Paend2-Paend3)*mmHg2Pa;
  ra3a(m)=ra3*YY(m);
  Ra3(m)=8*mu*la3/(pi*ra3a(m)*ra3a(m)*ra3a(m)*ra3a(m));
  Qa3(m)=Pa3/Ra3(m);

    Qa3res2(m)=Qa2-Qa3(m);
    Ra3res2(m)=(Paend2-Pvend3)/Qa3res2(m);

  % capillaries
  Pcap=(Paend3-Pendcap)*mmHg2Pa;
  Rcap=8*mu*lcap/(pi*rcap*rcap*rcap*rcap);
  Qcap=Pcap/Rcap;

    if (m==1), ncaps=ceil(Qa3(m)/Qcap); end;
    Qpercap(m)=Qa3(m)/ncaps;
    Rpercap(m)=Pcap/Qpercap(m);
    rcap2(m)=(8*mu*lcap/(pi*Rpercap(m)))^(1/4);

  % venuole
  Pv3=(Pendcap-Pvend3)*mmHg2Pa;
  Rv3=8*mu*lv3/(pi*rv3*rv3*rv3*rv3);
  Qv3=Pv3/Rv3;

    if (m==1), nv3=floor((Qpercap(m)*ncaps)/Qv3); end;
    Qperv3(m)=Qpercap(m)*ncaps/nv3;
    Rperv3(m)=Pv3/Qperv3(m);
    rperv3(m)=(8*mu*lv3/(pi*Rperv3(m)))^(1/4);

  % vein    
  Pv2=(Pvend3-Pvend2)*mmHg2Pa;
  Qv2(m)=Qperv3(m)*nv3+Qa3res2(m);
  Rv2(m)=Pv2/Qv2(m);
  rv2a(m)=(8*mu*lv2/(pi*Rv2(m)))^(1/4);
  Rv2c=8*mu*lv2/(pi*rv2*rv2*rv2*rv2);

  % large vein
  Pv1=(Pvend2-Pvend1)*mmHg2Pa;
  Qv1(m)=Qv2(m)+Qa2res1;
  Rv1(m)=Pv1/Qv1(m);
  rv1a(m)=(8*mu*lv1/(pi*Rv1(m)))^(1/4);
  Rv1c=8*mu*lv1/(pi*rv1*rv1*rv1*rv1);

end;

% output data
disp(sprintf('Total:'));
disp(sprintf('  dP  = %f (mmHg)',Ptotal*Pa2mmHg));
disp(sprintf('  Qdot= %e (L/min)',Qdottotal*60/1e-3));
disp(sprintf('  R   = %e (Ns/m^5)',Rtotal));
disp(sprintf('Large Arteries:'));
disp(sprintf('  dP  = %f (mmHg)',Pa1*Pa2mmHg));
disp(sprintf('  Qdot= %e (L/min)',Qa1*60/1e-3));
disp(sprintf('  R   = %e (Ns/m^5) (r=%fm,L=%fm)',Ra1,ra1,la1));
disp(sprintf('Arteries (head):'));
disp(sprintf('  dP  = %f (mmHg)',Pa2*Pa2mmHg));
disp(sprintf('  Qdot= %e res=%f (L/min)',Qa2*60/1e-3,Qa2res1*60/1e-3));
disp(sprintf('  R   = %e res=%f (Ns/m^5)',Ra2,Ra2res1));
disp(sprintf('Arterioles (microvascular): see figure'));
disp(sprintf('Capillaries (microvascular): see figure'));
disp(sprintf('  n = %d ',ncaps));
disp(sprintf('Venuoles (microvascular): see figure'));
disp(sprintf('  n = %d ',nv3));
disp(sprintf('Veins: see figure'));
disp(sprintf('Large Veins: see figure'));

figure(1)
subplot(311)
plot(t,ra3a)
grid('on'), ylabel('Radius (m)')
title(sprintf('Arteriolar Level: dP = %2f',Pa3*Pa2mmHg));
subplot(312)
plot(t,Ra3,t,Ra3res2)
grid('on'), ylabel('Resistance (Ns/m^5)')
subplot(313)
plot(t,Qa3*60/1e-3,t,Qa3res2*60/1e-3)
grid('on'), xlabel('Time'), ylabel('Flow (L/min)')

figure(2)
subplot(311)
plot(t,rcap2)
grid('on'), ylabel('Radius (m)')
title(sprintf('Capillaries (no recr.): dP = %2f mmHg (vs. r= %e m)',Pcap*Pa2mmHg,rcap));
subplot(312)
plot(t,Rpercap)
grid('on'), ylabel('Resistance (Ns/m^5)')
title(sprintf('Req?= %e for ncaps= %d',Rcap,ncaps));
subplot(313)
plot(t,Qpercap*60/1e-3)
grid('on'), xlabel('Time'), ylabel('Flow (L/min)')
title('Flow in a SINGLE capillary') 

figure(3)
subplot(311)
plot(t,rperv3)
grid('on'), ylabel('Radius (m)')
title(sprintf('Venuoles: dP = %2f mmHg (vs. r= %e m)',Pv3*Pa2mmHg,rv3));
subplot(312)
plot(t,Rperv3)
grid('on'), ylabel('Resistance (Ns/m^5)')
title(sprintf('Req?= %e for nvenl= %d',Rv3,nv3));
subplot(313)
plot(t,Qperv3*60/1e-3)
grid('on'), xlabel('Time'), ylabel('Flow (L/min)')
title('Flow in a SINGLE venuole')

figure(4)
subplot(321)
plot(t,rv2a)
grid('on'), ylabel('Radius (m)')
title(sprintf('Vein: dP = %2f mmHg (vs. rvein= %e m)',Pv2*Pa2mmHg,rv2));
subplot(323)
plot(t,Rv2)
grid('on'), ylabel('Resistance (Ns/m^5)')
title(sprintf('(vs. Rvein= %e )',Rv2c));
subplot(325)
plot(t,Qv3*60/1e-3)
grid('on'), xlabel('Time'), ylabel('Flow (L/min)')
subplot(322)
plot(t,rv1a)
grid('on'), ylabel('Radius (m)')
title(sprintf('Vein: dP = %2f mmHg (vs. rvein= %e m)',Pv1*Pa2mmHg,rv1));
subplot(324)
plot(t,Rv1)
grid('on'), ylabel('Resistance (Ns/m^5)')
title(sprintf('(vs. R= %e )',Rv1c));
subplot(326)
plot(t,Qv1*60/1e-3)
grid('on'), xlabel('Time'), ylabel('Flow (L/min)')

