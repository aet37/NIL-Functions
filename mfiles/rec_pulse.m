%%%%%%%%%%%%%%%%%%%%%%%%%%%% half_sin.m %%%%%%%%%%%%%%%%%%%%%%
%
%	Plot Fourier series for half-wave rectifier
%		Alberto L. Vazquez 11 Oct 93
%  
%----------------------------------------------------------------
j=sqrt(-1); command = 'y';
while command == 'y',
%----- begin main loop
clear cn i coeff0 coeff1 coeff time vt T0
nterms = input('enter number of Fourier terms [>=1]:  ');
alpha = input('enter alpha value: ');
T0=1;
for n=1:nterms,
     coeff(n) = (-1)*alpha*T0*( exp((-1)*j*2*pi*n) + 1) / (T0*pi*( 4*n^2 - 1 ));
end
coeff0 = 2*alpha*T0/(pi*T0);
%---coeff1 = (alpha/2)*(-1)*j*exp( -1*j*2*pi );
cn = [coeff0 coeff];
index = [0 1:nterms];
disp('Fourier coeffs are:')
disp(cn)
disp('*****>')
pause
%-------------- calculate power
Pn = coeff0^2 + 2*coeff*coeff';
disp('signal power = ')
disp(Pn)
disp('*****>')
pause
%------- construct approximation in time domain for 2 periods
npts = 201;
del_t = 1/npts;
time = [0:del_t:2];
imax = length(time);
for i = 1:imax,
	sum = coeff0;	%% start with DC term
	for n = 1:nterms,
		pos =  coeff(n)*exp(j*2*pi*n*time(i));
		sum = sum + pos + conj(pos);
	end	% of summation over Fourier index n
	vt(i) = sum;
end		% of time points
%-------------- plot the time-domain approximation
nterms_str = num2str(nterms);
plot(time,vt);grid
title('Fourier series approximation to input half-sine curve')
text(0.7,0.3,[nterms_str '  Fourier terms'],'sc')
pause;clf      % allow user to print, then clear plot
%------------- plot the Fourier coefficients
plot(index,cn,'*');grid
title('Fourier coefficients for input half-sine curve')
text(0.7,0.3,[nterms_str '  Fourier terms'],'sc')
pause;clf
%------- allow user to run again
command = input('Would you like to rerun (y,n)? ','s');
end       %% of the 'while command = y' loop
%save half_sin.dat ratio nterms coeff0 coeff
clear
disp('results saved in file half_sin.dat')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

