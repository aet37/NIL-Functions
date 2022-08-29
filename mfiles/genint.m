function   yint = genint(N)
%GENINT   generate interference for TONE GENERATOR mystery signal
%------
%   Usage:    Y = genint(N)
%
%       N : signal length of the interference
%       Y : output signal which has a continuously
%              changing freq plus noise

%---------------------------------------------------------------
% copyright 1994, by C.S. Burrus, J.H. McClellan, A.V. Oppenheim,
% T.W. Parks, R.W. Schafer, & H.W. Schussler.  For use with the book
% "Computer-Based Exercises for Signal Processing Using MATLAB"
% (Prentice-Hall, 1994).
%---------------------------------------------------------------

nnn = [1:N]';
other = [1 .06; N/5 .12; 2*N/5 .15; 3*N/5 .19; 4*N/5 .23; N .27];
f2 = table1( other, nnn);
%-----------
tau = 0.99;
[ttt,f2i] = filter(1-tau,[1 -tau],f2(1)*ones(99,1));   %set init conds.
f2 = filter(1-tau,[1 -tau], f2, 0.9*f2i);
%------------
if2 = diff(f2.*nnn);
Nm1 = N-1;
plot([ f2(1:Nm1) if2(1:Nm1)])
axis([0 N 0 1]), pause
title('FREQUENCY vs. TIME'), xlabel('TIME INDEX  (N)')
%------------
randn('seed', 31414977);    %<--- VERSION 4 CHANGE
yint = (10+0.01*randn(nnn)).*sin(2*pi*f2.*nnn)+0.3*randn(nnn);
