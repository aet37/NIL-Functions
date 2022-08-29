function vieworth(im1,im2,im3)
% Usage ... vieworth(im1,im2,im3)

clf
subplot(221)
imagesc(im1)
axis('image')
axis('vis3d')
axis('off')
title(sprintf('[%f %f]',min(min(im1)),max(max(im1))));
colormap(gray(256))
subplot(222)
imagesc(im2)
axis('image')
axis('vis3d')
axis('off')
title(sprintf('[%f %f]',min(min(im2)),max(max(im2))));
colormap(gray(256))
subplot(223)
imagesc(im3)
axis('image')
axis('vis3d')
axis('off')
title(sprintf('[%f %f]',min(min(im3)),max(max(im3))));
colormap(gray(256))

