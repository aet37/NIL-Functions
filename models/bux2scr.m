
%clear all

t=[0:.1:70];
u=rect(t,4,10);

%t=[1:135]/3;
%u=rect(t,4,11/3+2);

flow_tau=2.0;
flow_amp=+0.7;

flow_broad_width=2.0;	% if < step size broad=delta function with no delay
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

y=buxton3(t,u,[1 1 1],parm);

%eaparms=[Iamp Itau Cart Ccap Cven Cvbas Cvamp Cvtau]
%eaparms=[0.15 2.0 1e14 3e15 8e12 2e13 -0.25 15 25e-6];
eaparms=[+0.05 2.0 1e14 3e15 8e12 2e14 -0.25 15 28e-6];
[Qin,Qout,VV,MTT]=elecan2f(t,u,eaparms);
parm2=[t(2)-t(1) 1 VV(1,3) 0.4 1e-10];
[y2,QQ,EE]=fvtods(Qin(:,3),Qout(:,3),VV(:,3),parm2);
parm2a=[t(2)-t(1) parm(5:6) parm(13:end)];
y2a=fvtods_bux3(Qin(:,3),Qout(:,3),VV(:,3),1,parm2a);

eaparms3=[+0.05 1.0 1e14 3e15 8e12 2e14 -0.25 15 28e-6];
[Qin3,Qout3,VV3,MTT3]=elecan2f(t,u,eaparms3);
parm23=[t(2)-t(1) 1 VV3(1,3) 0.4 1e-10];
[y23,QQ3,EE3]=fvtods(Qin3(:,3),Qout3(:,3),VV3(:,3),parm23);

%subplot(211)
plot(t,y2(:,1),t,y23(:,1))
grid
ylabel('Signal Amplitude')
legend('y2','y23')
%legend('Buxton','Me','Me/Bux')
%xlabel('Time')
%title('Signal Temporal Course')
%subplot(223)
%plot(t,y(:,4),'-',t,u,'--')
%grid
%xlabel('Time')
%title('Flow-in and Input Waveforms')
%subplot(212)
%plot(y(:,5)/y(1,5),y(:,4)/y(1,4),Qin(:,3)/Qin(1,3),VV(:,3)/VV(1,3))
%xlabel('Flow'), ylabel('Volume'), axis tight,
%grid,
%xlabel('Flow In'), ylabel('Volume'),
%%subplot(222)
%%plot(t,y(:,2),'-',t,y(:,3),'--')
%%grid
%%xlabel('Time')
%%title('Deoxy and Blood Volume Temporal Courses')
%%subplot(224)
%%plot(y(:,3),y(:,5))
%%grid
%%xlabel('Volume')
%%ylabel('Flow')
%%title('Blood Volume vs. Flow-out')

%load cohenData
%plot(tt,prehypercapnia,tt,hypercapnia,tt,prehypocapnia,tt,hypocapnia)
%legend('pre-hyper','hyper','pre-hypo','hypo')

% form=0 in buxton3.m
subplot(221)
plot(t-7.9,y(:,5:6))
axis([-5 40 1 1.6])
grid
ylabel('rCBF','FontSize',14)
xlabel('Time (s)','FontSize',14)
legend('Qin','Qout')
subplot(222)
plot(t-7.9,y(:,4))
axis([-5 40 1 1.25])
grid
ylabel('rCBV','FontSize',14)
xlabel('Time (s)','FontSize',14)
subplot(223)
plot(t-7.9,y(:,3))
ylabel('E','FontSize',14)
xlabel('Time (s)','FontSize',14)
grid
axis([-5 40 0.25 0.45])
subplot(224)
plot(t-7.9,y(:,1)*10)
axis([-5 40 -2 7])
grid
ylabel('BOLD (%)','FontSize',14)
xlabel('Time (s)','FontSize',14)

