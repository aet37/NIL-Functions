function [k,I0,a,y]=calcExpRec(ttime,yvals,guess,optvar)
% Usage ... [k,I0,a,y]=calcExpRec(ttime,yvals,guess,optvar)

if nargin<4,
  optvar=optimset('lsqnonlin');
  optvar.TolFun=1e-10;
  optvar.TolX=1e-10;
  optvar.MaxIter=600;
  %optvar.Display='iter';
end;

xmin=[];
xmax=[];

for mm=1:size(yvals,2),

  x1=lsqnonlin('expRecov',guess,xmin,xmax,optvar,ttime,yvals(:,mm));
  y=expRecov(x1,ttime);
  %keyboard,

  if nargout==0,
    plot(ttime,yvals(:,mm),ttime,y)
    title(sprintf('I0= %f au, k= %f, alpha= %f',x1(1),x1(2),x1(3)))
    xlabel('Time')
    ylabel('Intensity')
    drawnow,
  else,
    I0(mm)=x1(1);
    k(mm)=x1(2);
    a(mm)=x1(3);
  end;

end;

