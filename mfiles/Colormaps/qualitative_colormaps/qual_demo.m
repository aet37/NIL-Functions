% Demo of two qualitative colormaps developed by Paul Tol
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

%% Demonstrates three qualitative colormaps with default colororder

figure('position',[w0,h0+h/2,w/3,0.8*h/2])
imagesc(1:6)
colormap(vibrant_qual)
axis image
title('"Vibrant" default order')

figure('position',[w0+w/3,h0+h/2,w/3,0.8*h/2])
imagesc(1:9)
colormap(muted_qual)
axis image
title('"Muted" default order')

figure('position',[w0+2*w/3,h0+h/2,w/3,0.8*h/2])
imagesc(1:8)
colormap(light_qual)
axis image
title('"Light" default order')


%% Demonstrates same colormaps with differing subsets of colors used

figure('position',[w0,h0,w/3,0.8*h/2])
imagesc(1:6)
colormap(vibrant_qual([2 3 6 1 5 4]))
axis image
title('"Vibrant" reordered (Inds = [2 3 6 1 5 4])')

figure('position',[w0+w/3,h0,w/3,0.8*h/2])
imagesc(1:4)
colormap(muted_qual([2 4 5 7]))
axis image
title('"Muted" subset (Inds = [2 4 5 7])')

figure('position',[w0+2*w/3,h0,w/3,0.8*h/2])
imagesc(1:5)
colormap(light_qual([8 7 3 2 4]))
axis image
title('"Light" subset and reordered (Inds = [8 7 3 2 4])')
