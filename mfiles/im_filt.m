function y=im_filt(im,win)
% Usage ... y=im_filt(im,win,norm)
%
% the window/filter is designed in the FOURIER domain
% AND centered about 0 where in a 64 image is [-32:31]
% (sample 33, dim/2+1)

y=ifft2(fftshift(win).*fft2(im));

