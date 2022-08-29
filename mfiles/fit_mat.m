function out=fit_mat(Data,lam)
%DATDEMO Nonlinear data fitting demonstration.
echo on;  clc
%       This example demonstrates fitting a nonlinear function to a
%	set of data.  It is used to demonstrate many of the different
%       methods which can be used in the OPTIMIZATION TOOLBOX.

%	Consider the following data:

pause	% Strike any key to continue.

disp('Data = ...');

Data

%	Let's plot this data.

pause	% Strike any key for plot.
t = Data(:,1);
y = Data(:,2);
clf
plot(t,y,'o'), title('Input data'), pause
clc
%	We would like to fit the function
%
%	  y =  c(1)*exp(-lam(1)*t) + c(2)*exp(-lam(2)*t)
%
%	to the data.  This function has 2 linear parameters
%	and 2 nonlinear parameters.

echo off
disp('Please Wait - Compiling Optimization Routines')

% test_long is a variable used for auto testing of this routine
if ~exist('test_long')  test_long = 0; end
if exist('method')~=1 method = 8; end
if ~length(method) method = 8; end
%l = 2; 
l=length(lam);

while 1
	%lam = [1 0]'; 
	if ~test_long
		clc
		disp(' ')
		disp('   Choose any of the following methods to perform the data fit')
		disp('')        
		disp('        UNCONSTRAINED:    1) Broyden-Fletcher-Golfarb-Shanno')
		disp('                          2) Davidon-Fletcher-Powell')
		disp('                          3) Steepest Descent')
		disp('                          4) Simplex Search')
		disp('         LEAST SQUARES:   5) Gauss-Newton  ')
		disp('                          6) Levenberg-Marquardt ')
		disp('         MINIMAX          7) Seq. Quadratic Progr.')
		disp('')
		disp('                          0) Quit')
		disp('')
		disp('Note: Options 1:6 perform a least squares fit')
		disp('      Option 7 minimizes the worst case error')
		disp('      Gauss-Newton is the fastest method')
	end

	
	if test_long 
		if l>=2 
		    method=method-1;
		    l = 0;
		end
	else 
		method=-1; 
	end
	while (method<0 | method>7)
		method = [];
		while ~length(method)
		    method = input('Select a method number: ');
		end
	end
	if (method == 0) 
		return
	end
	OPTIONS=0;
	if method==2, OPTIONS(6)=1;
	elseif method==3, OPTIONS(6)=2;
	elseif method==4, OPTIONS(5)=1;
	elseif method==5, OPTIONS(5)=1;
	end
	if test_long
		l = l + 1;  
	else 
		l = [];
	end
	if method~=4&method~=7
		disp('')
		disp('    Choose any of the following line search methods')
		disp('')
		disp('           1) Mixed Polynomial Interpolation')
		disp('           2) Cubic Interpolation')
		disp('')

		while ~length(l)
		    l = input('Select a line search number: ');
		end
		if l==2, OPTIONS(7)=1; end
	end

	disp('')
	OPTIONS(2)=1e-3;
	t0=clock;
	if method==5|method==6
		disp('[lam,OPTIONS]=leastsq(''fitfun2'', lam,OPTIONS,[],Data);')
		[lam,OPTIONS]=leastsq('fitfun2', lam,OPTIONS,[],Data);
	elseif method==4
		disp('[lam,OPTIONS]=fmins(''norm(fitfun2(x,P1))'',lam, OPTIONS,[],Data); ')
		[lam,OPTIONS]=fmins('norm(fitfun2(x,P1))',lam, OPTIONS,[],Data); 
	elseif method~=7;
		disp('[lam,OPTIONS]=fminu(''norm(fitfun2(x,P1))'',lam,OPTIONS,[],Data);')
		[lam,OPTIONS]=fminu('norm(fitfun2(x,P1))',lam,OPTIONS,[],Data);
	else
		OPTIONS(15)=length(t);
		disp('[lam,OPTIONS]=minimax(''f=fitfun2(x,P1); g=[];'', lam, OPTIONSR,[],[],[],Data);')
		[lam,OPTIONS]=minimax('f=fitfun2(x,P1); g=[];', lam, OPTIONS,[],[],[],Data);
	end
	if test_long
		if (method<=4) OPTIONS(8) = OPTIONS(8).^2; end
		if OPTIONS(8)-0.03*(method==7)-(method==3) > 0.15, error('Optimization Toolbox in datdemo'), end
	end
	execution_time=etime(clock, t0)
	disp('Strike any key for menu')
	pause
end

out=lam;
