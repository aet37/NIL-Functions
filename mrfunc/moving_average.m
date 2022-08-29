function [f,g]=moving_average(y,order)
% Usage ... [f,g]=moving_average(y,order)
%
% The input y must be a vector
% Order is the number of points to be averaged
% The average is calculated from each side

y=y(:);

side_order=floor(order/2);
for n=1:length(y),
  if n<=side_order,
    f(n)=mean(y(1:n+side_order));
    g(n)=std(y(1:n+side_order));
  elseif n>=length(y)-side_order,
    f(n)=mean(y(n-side_order:length(y)));
    g(n)=mean(y(n-side_order:length(y)));
  else,
   f(n)=mean(y(n-side_order:n+side_order));
   g(n)=mean(y(n-side_order:n+side_order));
  end;
end;

if nargout==0,
  plot([1:length(y)],y,[1:length(f)],f);
end;