function yd=tcdetrend2(y,order,range,norm)
% Usage ... yd=tcdetrend2(y,order,range,norm)
%
% y must be in columns!

if size(y,1)==1,
  disp('warning: y should be in columns');
end;

if nargin<4, norm=0; end;
if nargin<3, range=[1 size(y,1)]; end;

x=[1:size(y,1)]';
for m=1:size(y,2),
  xtofit=x(range);
  ytofit=y(range,m);
  pcoef=polyfit(xtofit,ytofit,order);
  yb=polyval(pcoef,x);
  if (norm>0),
    yd(:,m)=(y(:,m)-yb)./yb;
  elseif (norm<0),
    yd(:,m)=y(:,m)-yb;
  elseif (norm==0),
    yd(:,m)=y(:,m)-yb+mean(yb);
  end;
  if nargout==0,
    disp(sprintf('  displaying #%d (norm=%d)',m,norm));
    subplot(211)
    plot(x,y(:,m),x,yb)
    subplot(212)
    plot(x,yd(:,m))
    pause,
  end;
end;

