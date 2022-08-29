
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
%u=rect(t,5,15);
u=rect(t,5,15)+rect(t,5,30);

y=buxton3(t,u,[1 1 1],parm);

subplot(211)
plot(t,y(:,1))
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
plot(y(:,4),y(:,5))
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

