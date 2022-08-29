function y=vesWallSignalCorr1(diam_norm,a)
% Usage y=vesWallSignalCorr1(diam_norm,a)
%
% Expected change in vessel cell wall thickness assuming constant length
% Normalized vessel diameter to 1 is expected and the fractional baseline
% wall thickness a (a>1).
% y is the change in vessel wall thickness
% if a=1, b=1. if R2=R1, a=b. if R2>R1, b<a.
%
% Therefore we need to divide by y, or
%   y_corr=y_signal./vesWallSignalCorr1(rr1_an,1.2);


if nargin==1, a=1.2; end;

if prod(size(diam_norm))>length(diam_norm),
  if length(a)==1, a=a*ones(size(diam_norm,2),1); end;
  for mm=1:size(diam_norm,2),
    b(:,mm)=1+(a(mm)^2-1)./(diam_norm(:,mm).^2);
    b(:,mm)=sqrt(b(:,mm))/a(mm);
  end;
else,
  b=1+(a^2-1)./(diam_norm.^2);
  b=sqrt(b)/a;
end;
y=b;

