
clear all
close all

% Load the data in the mat-file
% The variable tcA is a structure containing the average time series over
% the active region, which in this case is whisker. The stimulus consisted
% of whisker puffs delivered to the contralateral whisker pad (40psi puffs, 
% for 50ms every 200ms (5Hz) for 6-seconds repeated every 36-seconds (12 
% times total).
% Imaging consisted of LED1=450-490nm, LED2=521-541nm, LED3=613-627nm lit
% sequentially at 30Hz for an effective fps of 10Hz per LED.

load forAdam

y530=tcA.atc_an(:,2);
y620=tcA.atc_an(:,3);

ydHb=myOISdecomp([y530 y620],[531 620],[20 20]);

ydHbO_uM=ydHb.yHb(:,2);
ydHbR_uM=ydHb.yHb(:,1);
ydHbT_uM=ydHb.yHbT;


figure(1), clf,
subplot(211), plot(tt,[y530 y620],'LineWidth',1.5), legend('572nm','620nm','Location','southeast')
axis tight, grid on, set(gca,'FontSize',12),
xlabel('Time (s)','FontSize',16), ylabel('OIS S/S_0','FontSize',18), 
subplot(212), plot(tt,[ydHbO_uM ydHbR_uM ydHbT_uM]*1e6,'LineWidth',1.5), legend('HbO','HbR','HbT'),
axis tight, grid on, set(gca,'FontSize',12),
xlabel('Time (s)','FontSize',16), ylabel('\DeltaC (\muM)','FontSize',18), 
