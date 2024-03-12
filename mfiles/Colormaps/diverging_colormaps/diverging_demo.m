% Demonstration of three diverging colormaps developed by Paul Tol
% see https://personal.sron.nl/~pault/data/colourschemes.pdf for more info

close all
clearvars

% get screen pixels for plots
screen=get(0,'ScreenSize') ;
w0=screen(1);
h0=screen(2);
w =screen(3);
h =screen(4);
h0=h0+0.03*h;

img=peaks(500); % generate sample data

%% Demonstrates three diverging colormaps with default colormap length

figure('position',[w0,h0+h/2,w/3,0.8*h/2])
imagesc(img)
colormap(sunset)
axis image
colorbar
set_clims(img,[0 100],1);
title('"Sunset" default length')

figure('position',[w0+w/3,h0+h/2,w/3,0.8*h/2])
imagesc(img)
colormap(BuRd)
axis image
colorbar
set_clims(img,[0 100],1);
title('"BuRd" default length')

figure('position',[w0+2*w/3,h0+h/2,w/3,0.8*h/2])
imagesc(img)
colormap(PrGn)
axis image
colorbar
set_clims(img,[0 100],1);
title('"PrGn" default length')

%% Demonstrates same colormaps with length 15

figure('position',[w0,h0,w/3,0.8*h/2])
imagesc(img)
colormap(sunset(15))
axis image
colorbar
set_clims(img,[0 100],1);
title('"Sunset" N=15')

figure('position',[w0+w/3,h0,w/3,0.8*h/2])
imagesc(img)
colormap(BuRd(15))
axis image
colorbar
set_clims(img,[0 100],1);
title('"BuRd" N=15')

figure('position',[w0+2*w/3,h0,w/3,0.8*h/2])
imagesc(img)
colormap(PrGn(15))
axis image
colorbar
set_clims(img,[0 100],1);
title('"PrGn" N=15')