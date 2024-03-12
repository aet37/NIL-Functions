% Demo of "iridescent" and YlOrBr, developed by Paul Tol
% see https://personal.sron.nl/~pault/data/colourschemes.pdf for more info
%
% For Demo of "Magma", "Inferno", "Plasma", and "Viridis", see "demo1.m"
% in "python_uniform_sequential_colormaps"
close all
clearvars

% get screen pixels for plots
screen=get(0,'ScreenSize') ;
w0=screen(1);
h0=screen(2);
w =screen(3);
h =screen(4);
h0=h0+0.03*h;

% load sample data
load flujet
X=X.';
img=X;
clear X

%% Demonstrates two sequential colormaps with default colormap length

figure('position',[w0,h0+h/2,w/2,0.8*h/2])
imagesc(img)
colormap(YlOrBr)
axis image
colorbar
title('"YlOrBr" default length')

figure('position',[w0+w/2,h0+h/2,w/2,0.8*h/2])
imagesc(img)
colormap(iridescent)
axis image
colorbar
title('"iridescent" default length')


%% Demonstrates same colormaps with length 15

figure('position',[w0,h0,w/2,0.8*h/2])
imagesc(img)
colormap(YlOrBr(15))
axis image
colorbar
title('"YlOrBr" N=15')

figure('position',[w0+w/2,h0,w/2,0.8*h/2])
imagesc(img)
colormap(iridescent(15))
axis image
colorbar
title('"iridescent" N=15')
