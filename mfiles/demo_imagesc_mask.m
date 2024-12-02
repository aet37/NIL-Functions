close all
clearvars

% imagesc_mask may be used on a 2D image containing NaN values, to display
% the NaN pixels in gray (or specified mask color) OR can be used with an
% optional binary mask input defining which pixels should be gray (or
% specified mask color)

%% Example 1: NaN pixels in "my_img" input
my_img=peaks(512); % generate sample data
my_img(abs(my_img)<0.2)=NaN; % set values under a threshold to NaN
figure
imagesc_mask(my_img,sunset,[],1) % diverging colormap "sunset," zero-centered clims
title('Example with NaN pixels in "my_img" input','interpreter','none')

%% Example 2: NaN pixels in "my_img" input
my_img=peaks(512); % generate sample data
my_img(abs(my_img)<0.2)=NaN; % set values under a threshold to NaN
figure
imagesc_mask(my_img,[],[0 8]) % default colormap, specified clims [0 8]
title('default colormap, specified clim [0 8]')

%% Example 3: with binary mask input
my_img=peaks(512); % generate sample data
my_mask = imread('circlesBrightDark.png');
my_mask=(my_mask==0); % generate mask consisting of three circles
figure
imagesc_mask(my_img,sunset,[],1,my_mask) % diverging colormap "sunset," zero-centered clims, binary mask input "my_mask"
title('Example with separate binary mask')

%% Example 4: Grayscale image with specified mask color dark green
my_img=peaks(512); % generate sample data
my_mask = imread('circlesBrightDark.png');
my_mask=(my_mask==0); % generate mask consisting of three circles
figure
imagesc_mask(my_img,bone,[],[],my_mask,[0 0.5 0]) % colormap "bone," automatic clims, binary mask input "my_mask", specified mask color dark green
title('Binary mask with specified mask color [0 0.5 0]')

%% Example 5: binary mask input with specified x and y axis vectors
my_img=peaks(512); % generate sample data
my_mask = imread('circlesBrightDark.png');
my_mask=(my_mask==0); % generate mask consisting of three circles
figure
imagesc_mask(my_img,PrGn,[],1,my_mask,[],0:511,100.5:0.5:356) % Diverging colormap "PrGn," zero-centered clims, binary mask input "my_mask", specified x and y axis vectors
title('Binary mask with specified x and y position of pixels')

%% Qualitative data example (in development)
% qualitive data should consist of integers from 1 to size of colormap
% in this example 1 through 7
load flujet
X=X.';
qual_img=X;
qual_img=round(qual_img/10)+1;
clear X

figure
imagesc_mask(qual_img,colororder,[],0)
title('Qualitative dataset example')
%% Qualitative data example (in development)
% same as above, with circle mask
load flujet
X=X.';
qual_img=X;
qual_img=round(qual_img/10)+1;
clear X

figure
imagesc_mask(qual_img,colororder,[],0,my_mask(213:end,113:end))
title('Qualitative dataset example with mask')