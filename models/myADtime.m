
clear all
close all

xx=[0:0.02:1];

yy(:,1)=1.02./(1+exp(-12*(xx-0.35)))-0.02;
yy(:,2)=1.03./(1+exp(-11*(xx-0.40)))-0.03;
yy(:,3)=1.15./((1+exp(-10*(xx-0.59))).^0.5)-0.14;
yy(:,4)=1.18./((1+exp(-10*(xx-0.75))).^0.4)-0.14;
yy(:,5)=1.25./(1+exp(-7*(xx-0.75)))-0.06;
yy(:,6)=1.45./(1+exp(-10*(xx-0.9)))-0.05;

%y2(:,1)=1.09./(1+exp(-14*(xx-0.18)))-0.09;
y2(:,1)=1.03./(1+exp(-12*(xx-0.28)))-0.032;
%y2(:,1)=1.02./(1+exp(-12*(xx-0.38)))-0.02;

plot(xx,yy)
axis([0 1 0 1])

fatlines(2);
setlinecolor([0.5 0 0.5; 0.8 0 0; 0.4 0.6 1;0 0 0.7;0 0.5 0;0 0.5 0])

legend('CSF A\beta','Amyloid PET','CSF tau','MRI + FDG-PET','MCI (high risk)','MCI (low risk)',2)

hold('on'),
plot(xx,y2,'k--')
hold('off')
fatlines(2);
legend('CSF A\beta','Amyloid PET','CSF tau','MRI + FDG-PET','MCI (high risk)','MCI (low risk)','fcMRI-DMN',2)

set(gca,'XTickLabel',[]),
set(gca,'YTickLabel',[]),
set(gca,'XTick',[]),
set(gca,'YTick',[]),
setpapersize([8 5]),

