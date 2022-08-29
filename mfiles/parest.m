% This program estimates the parameters of a two-compartment system.
% It drives the system with an exponential input, derived as x(13). 
% The parameters to be estimated are k11 and k22.  The correct values
% of these coefficients are hard-wired 
% as c1 = 3.15 (k11) and c4 = 1.07 (k22).
% There is provision for a non-linear (squared) term, with coefficient l.
% l is now set to zero.
% The program runs for tf (=10) sec, and evaluates least squares errors at
% the center (k11 and k22) and at four alternatives (+- dk11,+- dk22).  It then chooses a
% new center by moving k by dk in the correct direction.  If no such
% movement improves the error, dk is divided by two, and the next 
% iteration is made.
% The background for this program is in Rideout, as PAREST2.  Several
% changes have been made in translating to Matlab by J. Newell Nov. 1993
global c1 c2 c3 c4 l  k11 k22 dk11 dk22  

c1 = 5.0;
c2 = 0.5;
c3 = 0.5;
c4 = 1.0;
l = 0.1;


% set up the integrator:
t0 = 0.;
tf = 10.;

% initial conditions are all zero except for the input
x0 = [ 0 0 0 0 0 0 0 0 0 0 0 0 5 0 0 0 0 0 ];

% starting guesses for k and dk
dk11 = .2;
dk22 = .4;
k11 = 4.0;
k22 = 2.0;

% maximum number of iterations
am = 20;

for a=1:am

t = [0.:.1:10.];

[t,x] = ode23( 'models', t0,tf,x0);

% make a record of what happens to k and dk
K11(a) = k11;
DK11(a) = dk11;
K22(a) = k22;
DK22(a) = dk22;

% test for a change in the '11' axis:
if     (( x(tf,15) > x(tf,16)) & (x(tf,14) > x(tf,16)))  k11 = k11 + dk11;
elseif (( x(tf,16) > x(tf,15)) & (x(tf,14) > x(tf,15)))  k11 = k11 - dk11;
else end

% test for a change in the '22' axis:
if     (( x(tf,17) > x(tf,18)) & (x(tf,14) > x(tf,18)))  k22 = k22 + dk22;
elseif (( x(tf,18) > x(tf,17)) & (x(tf,14) > x(tf,17)))  k22 = k22 - dk22;
else end

% test if dk11 too big:
if     (( x(tf,14) < x(tf,15)) & (x(tf,14) < x(tf,16))) dk11 = dk11/2.;
else end
% test if dk22 too big:
if     (( x(tf,14) < x(tf,17)) & (x(tf,14) < x(tf,18))) dk22 = dk22/2.;
else end
end
 plot(K11)
%The command   plot(t,x(:,*))  is useful.  Substitute 1-18 for the *.


