function xdot = models(t,x)
% This is the file that goes with parest to define the derivatives of 
% the model.
% It was started in Nov 1993 by J. Newell, and is based on PAREST2 of Rideout.

global  c1 c2 c3 c4 l k11 k22  dk11 dk22


% This is the actual model that the parameter estimator is trying to find.
xdot(1) = -c1*x(1)   +   c2*x(2) + l*x(1)^2. + x(13);
xdot(2) = c3*x(1) - c4*x(2);

% This is the center point or the present estimate
xdot(3) = -k11*x(3) + c2*x(4)  + l*x(3)^2  + x(13);
xdot(4) = c3*x(3) - k22*x(4);

% Estimate with lower k11 
xdot(5) = -(k11-dk11)*x(5) + c2*x(6) + l*x(5)^2. + x(13);
xdot(6) = c3*x(5) - k22*x(6);

% Estimate with higher k11
xdot(7) = -(k11+dk11)*x(7) + c2*x(8) + l*x(7)^2 + x(13);
xdot(8) = c3*x(7) - k22*x(8);

% Estimate with lower k22
xdot(9) = -k11*x(9)  +  c2*x(10) + l*x(9)^2. + x(13);
xdot(10) = c3*x(9) - (k22-dk22)*x(10);

% Estimate with higher k22
xdot(11) = -k11*x(11)  +  c2*x(12) + l*x(11)^2 + x(13);
xdot(12) = c3*x(11) - (k22+dk22)*x(12);

% This is the input function:
xdot(13) = -.5 * x(13);

% These are the error terms associated with the center and each of the four
% alternative models: 
xdot(14) = (x(1) - x(3) )^2 + (x(2) - x(4) )^2;
xdot(15) = (x(1) - x(5) )^2 + (x(2) - x(6) )^2;
xdot(16) = (x(1) - x(7) )^2 + (x(2) - x(8) )^2;
xdot(17) = (x(1) - x(9) )^2 + (x(2) - x(10))^2;
xdot(18) = (x(1) - x(11))^2 + (x(2) - x(12))^2;
