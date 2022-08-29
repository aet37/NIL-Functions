function f=peak2(x,center,width,order,amplitude)
% Usage ... f=peak2(x,center,width,order,amplitude)
% 
% Uses polynomials to generate symmetric peaks

if nargin<4, order=2; end;
if nargin<5, amplitude=1; end;

start_flag=0;
for m=1:length(x),
  if (x(m)<(center-width))|(x(m)>(center+width)),
    f(m)=0;
  elseif (x(m)>=(center-width))&(x(m)<=center),
    f(m)=(x(m)-center+width)^order;
  elseif (x(m)>center)&(x(m)<=(center+width)),
    f(m)=(-1)^order*(x(m)-center-width)^order;
  else,
    disp('weird...');
  end;
end;

f=(amplitude/max(f))*f(:);

if ~nargout,
  plot(x,f)
end;
