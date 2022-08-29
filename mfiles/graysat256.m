
graysat256_color=[[0:255]' [0:255]' [0:255]']/255;
graysat256_color(1,:)=[1 0 0];
graysat256_color(end,:)=[0 0 1];

colormap(graysat256_color)
disp('  gray saturation scale, if no red or blue appear, use adjust min/max of image...');

clear graysat256_color

