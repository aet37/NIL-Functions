close all
clearvars


% get screen pixels for plots
screen=get(0,'ScreenSize') ;
w0=screen(1);
h0=screen(2);
w =screen(3);
h =screen(4);
h0=h0+0.03*h;

% generate sample data and circular mask
[X,Y]=meshgrid(-499.5:1:499.5);
mask=sqrt(X.^2+Y.^2)>450;
angle=atan(Y./X);
angle(X<0)=angle(X<0)+pi;
angle(angle<0)=angle(angle<0)+2*pi;

figure('position',[w0+w/10,h0+h/4,w/3,h/2])
imagesc_mask(angle,twilight,[0 2*pi],0,[],mask)
set(gca,'ydir','normal')
labels={'0','\pi/2','\pi','3\pi/2','2\pi'};
colorbar('xtick',[0 0.5 1 1.5 2]*pi,'xticklabel',labels)
title('"twilight"')

figure('position',[w0+w*(5/10),h0+h/4,w/3,h/2])
imagesc_mask(angle,twilight_shifted,[0 2*pi],0,[],mask)
set(gca,'ydir','normal')
labels={'0','\pi/2','\pi','3\pi/2','2\pi'};
colorbar('xtick',[0 0.5 1 1.5 2]*pi,'xticklabel',labels)
title('"twilight shifted"')

