
% Demonstrates the use of buxton3 matlab function...

clear
cd ~/matlab/models

flow_tau=2.0;
flow_amp=0.7;

flow_broad_width=0.0;	% if < step size broad=delta function with no delay
flow_broad_del=0.0;

transit_time=2.0;
extraction_basal=0.4;
alpha=0.4;
tauv=0.0;
beta=0.1;
gamma=0.004;
eta=0.04;
zeta=0.0;

% decreasing beta makes the undershoot longer
% decreasing gamma makes the undershoot and early dip bigger
% increasing eta also makes the undershoot bigger

vol_fraction=1.0;

k1=2.8;
k2=2.0;
k3=0.6;

parm=[flow_tau flow_broad_width flow_amp flow_broad_del ...
	transit_time extraction_basal ...
	alpha tauv beta gamma eta zeta ...
	vol_fraction ...
	k1 k2 k3];

t=[0:.1:70];
u=rect(t,4,12.0);
%u=rect(t,4,12)+rect(t,4,42);

y=buxton3(t,u,[1 1 1],parm);

%eaparms=[0.15 2.0 1e14 3e15 8e12 2e13 -0.25 15];
eaparms=[0.15 2.0 1e14 3e15 8e12 1e13 -0.25 15];
[Qin,Qout,VV,MTT]=elecan2f(t,u,eaparms);
parm2=[t(2)-t(1) 1 VV(1,3) 0.4 1e-10];
parm2a=[t(2)-t(1) parm(5:6) parm(13:end)];
[y2,QQ,EE]=fvtods(Qin(:,3),Qout(:,3),VV(:,3),parm2);
y2a=fvtods_bux3(Qin(:,3),Qout(:,3),VV(:,3),1,parm2a);


subplot(211)
plot(t,y(:,1),t,y2(:,1),t,y2a(:,1))
grid
ylabel('Signal Amplitude')
xlabel('Time')
title('Signal Temporal Course')
subplot(223)
plot(t,y(:,4),'-',t,u,'--')
grid
xlabel('Time')
title('Flow-in and Input Waveforms')
subplot(224)
plot(y(:,5),y(:,6),Qin(:,3),VV(:,3))
grid,
xlabel('Flow In'), ylabel('Volume'),
%subplot(222)
%plot(t,y(:,2),'-',t,y(:,3),'--')
%grid
%xlabel('Time')
%title('Deoxy and Blood Volume Temporal Courses')
%subplot(224)
%plot(y(:,3),y(:,5))
%grid
%xlabel('Volume')
%ylabel('Flow')
%title('Blood Volume vs. Flow-out')

