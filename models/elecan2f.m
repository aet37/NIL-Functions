function [Qin,Qout,V,MTT]=elecan2f(t,u,parms)
% Usage ... [Qin,Qout,V,MTT]=elecan2f(t,u,parms)
%
% parms = [Ramp Rtau dvddp_art dvddp_cap dvddp_ven]
%

% the compliance of a vein is ~ 24x that of its corresponding
% artery because its ~ 8x more distensible and has ~ 3x the volume

% also, recall that the volumes of the arterial, capillary and
% venous sides have been designed from values in the literature
% and these will affect the transit time, so this means that the
% transit time is a design parameter as well

% input parameters: [Yamp Ytau]
Yamp=parms(1);			% 0.15
Ytau=parms(2);			% 2.00
dvddp_a3=parms(3);		% 1e15
dvddp_cap=parms(4);		% 2e15
dvddp_v3=parms(5);		% 4e12
Y2bas=parms(6);
Y2amp=parms(7);
Y2tau=parms(8);

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

if (length(parms)==9), ra3=parms(9); end;


% Heart
Qdottotal=5e-3/60;		% m^3/s
Ptotal=(Pa0-Pvend1)*mmHg2Pa;	% N/m^2
Rtotal=Ptotal/Qdottotal;	% Ns/m^5

dt=t(2)-t(1);
tlen=length(t);
Y(1)=0; 
Y2(1)=0;
for m=1:tlen,
  % first-order dynamics
  if (m>1), 
    Y(m) = Y(m-1) + dt*( (1/Ytau)*u(m-1) - (1/Ytau)*Y(m-1) );
    Y2(m) = Y2(m-1) + dt*( (1/Y2tau)*u2(m-1) - (1/Y2tau)*Y2(m-1) );
  end;
  YY(m)=1+Yamp*Y(m);
  YY2(m)=1+Y2amp*Y2(m);

  % Arteriole
  %dvddp_a3=1e15;
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
  %dvddp_cap=2e15;
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
  if (dvddp_cap==0),
    Vcap(m) = pi*rcap2*rcap2*lcap*ncaps;
  else,
    Vcap(m) = (1/dvddp_cap)*Pcap(m) + pi*rcap2*rcap2*lcap*ncaps;
  end;
  Vpercap(m)=Vcap(m)/ncaps;

  % Venuole
  %dvddp_v3(m)=4e12;
  if (m==1),
    Pv3(m)=(Pendcap(m)-Pvend3(m))*mmHg2Pa;
    Rv3=8*mu*lv3/(pi*rv3*rv3*rv3*rv3);
    Qv3=Pv3/Rv3;
    nv3=floor((Qpercapo(m)*ncaps)/Qv3);
    Qperv3i=Qpercapo(m)*ncaps/nv3;
    %Rperv3=8*mu*lv3/(pi*rv3*rv3*rv3*rv3);
    Rperv3=Pv3/Qperv3i;
    rperv3=(8*mu*lv3/(pi*Rperv3))^(1/4);
    Qperv3oRECALC(m)=Qperv3i(m);
  end;
  u2(m)=(Pv3(m)-Pv3(1))/Pv3(1);
  %u2(m)=u(m);
  dvddp_v3(m)=Y2bas*(1+Y2amp*Y2(m));
  Qperv3i(m)=Qpercapo(m)*ncaps/nv3;
  Qperv3o(m)=Pv3(m)/Rperv3;
  if (m<tlen),
    %Pv3(m+1)=Pv3(m)+dt*dvddp_v3*(Qperv3i(m)-Qperv3o(m));
    Pv3(m+1)=Pv3(m)+dt*dvddp_v3(m)*(Qperv3i(m)-Qperv3o(m));
    Pendcap(m+1)=Pendcap(1)+Pv3(m)*Pa2mmHg;
    Pvend3(m+1)=Pvend3(m);
  end;
  %Vv3(m) = (1/dvddp_v3)*Pv3(m) + pi*rperv3*rperv3*lv3*nv3;
  Vv3(m) = (1/dvddp_v3(m))*Pv3(m) + pi*rperv3*rperv3*lv3*nv3;
  if (m>1), Qperv3oRECALC(m)=Qperv3i(m)-((Vv3(m)-Vv3(m-1))/dt); end;
  Vperv3(m)=Vv3(m)/nv3;

end;

% mean transit-time calculation of the segments
mtta3=Va3./(0.5*Qa3i+0.5*Qa3o);
mttcap=Vpercap./(0.5*Qpercapi+0.5*Qpercapo);
mttv3=Vperv3./(0.5*Qperv3i+0.5*Qperv3o);

Qin=[Qa3i;Qpercapi*ncaps;Qperv3i*nv3]';
Qout=[Qa3o;Qpercapo*ncaps;Qperv3o*nv3]';
V=[Va3;Vcap;Vv3]';
MTT=[mtta3;mttcap;mttv3]';

%subplot(311)
%plot(t,Qperv3i,t,Qperv3o,t,Qperv3oRECALC)
%subplot(312)
%plot(t,Vv3)
%subplot(313)
%plot(t,Qperv3o-Qperv3oRECALC)

%plot(t,dvddp_v3)
%keyboard,
