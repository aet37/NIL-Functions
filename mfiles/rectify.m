function y = rectify(x,alpha)
% y = rectify(x,alpha)
%
% Piecewise rectification of signal x.
%
% For x >=0, y = x.^alpha
% For x <0,  y = -(-x).^alpha
%

y = x.^alpha;
y(find(x<0)) = -(-x(find(x<0))).^alpha;
