%%%%%%%%%%%%%%%%%%%%%%%%%%%%% half_sinb.m %%%%%%%%%%%%%%%%%%%%%%
%
%       Plot Fourier series for half-sine wave
%               Alberto L. Vazquez 11 Oct 93
%  
%----------------------------------------------------------------
j=sqrt(-1); command = 'y';
while command == 'y',
 clear cn i coeff0 coeff time vt T0
 nterms = input('enter number of Fourier terms [>=1]:  ');
 alpha = input('enter alpha value: ');
 T0=1;
 for n=1:nterms,
  if n == 1/(2*alpha)
    coeff(1/(2*alpha))= -alpha*0.5*j;
  else  
    coeff(n) = -alpha/pi*( exp(-j*2*pi*n*alpha) + 1) / (4*n^2*alpha^2 - 1);
  end
end
coeff0 = alpha*2/pi;

cn = [coeff0 coeff];
index = [0 1:nterms];
disp('Fourier coeffs are:')
disp(cn)
disp('*****>')
pause

%-------------- calculate power
Pn = coeff0*coeff0 + 2*coeff*coeff';
disp('signal power = ')
disp(Pn)
disp('*****>')
pause

%------- construct approximation in time domain for 2 periods
npts = 201;
del_t = 1/npts;
time = [0:del_t:1];
imax = length(time);
for i = 1:imax,
	sum = coeff0; 
	for n = 1:nterms,
		pos =  coeff(n)*exp(j*2*pi*n*time(i));
		sum = sum + pos + conj(pos);
	end     
	vt(i) = sum;
end            

%-------------- plot the time-domain approximation
plot(time,vt);grid
title('Fourier series approximation to input half-sine curve')
xlabel('Fourier Terms:       alpha:');
pause;print;clg

%------------- plot the Fourier coefficients
plot(index,cn,'*');grid
title('Fourier coefficients for input half-sine curve')
xlabel('Fourier Terms:       alpha:');
pause;print;clg

plot(index,abs(cn),'*');grid
title('Fourier coefficients (magnitude)');
xlabel('Fourier Terms:        alpha:');
pause;print;clg
%------- allow user to run again
command = input('Would you like to rerun (y,n)? ','s');
end       
save halfsin.dat nterms coeff0 coeff
clear
disp('results saved in file half_sin.dat')


