function [X] = dtft(x,n,w)
% Computes Dsicrete-time Fourier Transform
% [X] = dtft(x,n,w)
%
% X = DTFT values computed at w frequencies
% x = finite duration sequence over n
% n = sample position vector
% W = frequency location vector

k = -200:200; 
X = x * ( exp(-j*(w/k)) ) .^ (n'*k);


magX = abs(X); angX = angle(X);
realX = real(X); imagX = imag(X);
subplot(2,2,1); plot(w/pi,magX); 
 axis([-1 1 min(magX) max(magX)]); grid
 xlabel('frequency in pi units'); title('Magnitude Part'); 
 ylabel('Magnitude')
subplot(2,2,3); plot(w/pi,angX); 
 axis([-1 1 min(angX) max(angX)]); grid
 xlabel('frequency in pi units'); 
 title('Angle Part'); ylabel('Radians')
subplot(2,2,2); plot(w/pi,realX); 
 axis([-1 1 min(realX) max(realX)]); grid
 xlabel('frequency in pi units'); 
 title('Real Part'); ylabel('Real')
subplot(2,2,4); plot(w/pi,imagX);
 axis([-1 1 min(imagX) max(imagX)]); grid
 xlabel('frequency in pi units'); 
 title('Imaginary Part'); ylabel('Imaginary')
