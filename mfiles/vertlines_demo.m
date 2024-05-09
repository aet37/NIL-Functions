close all
clearvars

x=0:0.01:5;
y=sin(2*pi*x);

figure('WindowState','maximized')

subplot(2,2,1)
plot(x,y,'.-')
ylim([-2 2])
xlim([0 5])
vertlines(0:5)
title('standard properties')

subplot(2,2,2)
plot(x,y,'.-')
ylim([-2 2])
xlim([0 5])
vertlines(0.25:1:4.25,'b--',1)
title('custom color and style using ''b--'' and ''linew''=1')

subplot(2,2,3)
plot(x,y,'.-')
ylim([-2 2])
xlim([0 5])
vertlines(0.75:1:4.75,'m-',2,[-1 0])
title('custom color and style using ''m-'', ''linew''=2, custom y-range')

subplot(2,2,4)
plot(x,y,'.-')
ylim([-2 2])
xlim([0 5])
vertlines(0.5:1:4.5,'k-',[],[],[0 0.6 0])
title('custom line color with ''color''=[0 0.6 0]')