function [dd,di]=mygdist2(im1,im2)
% Usage ... d=mygdist(im1,im2)

show(im1)
drawnow,
disp('  click position in image 1 ...');
a=ginput(1);

show(im2)
drawnow,
disp('  click position in image 2 ...');
b=ginput(1);

dd=sqrt((a(1)-b(1))^2 + (a(2)-b(2))^2);
di=(a(1)-a(2))+i*(b(1)-b(2));

disp(sprintf('\n  d= %.1f',dd));

