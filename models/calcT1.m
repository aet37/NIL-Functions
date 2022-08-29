function [T1,I0,al,irout]=calcT1(irtime,irvals,absflag,irguess,optvar)
% Usage ... [T1,I0,al]=calcT1(irtime,irvals,absflag,irguess,optvar)

if nargin<5,
  optvar=optimset('lsqnonlin');
  optvar.TolFun=1e-10;
  optvar.TolX=1e-10;
  optvar.MaxIter=600;
  %optvar.Display='iter';
end;
if nargin<4,
  irguess=[2000 2 1.0];
end;
if nargin<3, absflag=0; end;

if (ndims(irvals)>2), irvals=squeeze(irvals); end;
%if (absflag),
%  diffy=diff(irvals);
%  diffy(end+1)=1;
%  [maxd,maxdi]=max(diffy);
%  irf=zeros(size(irvals));
%  irf(1:maxdi-1)=-1; irf(maxdi:end)=1;
%  irvals=irvals.*irf;
%end;
%irvals2=irvals;

I0max=20000; I0min=0;
T1max=100;   T1min=0;
almax=1;     almin=0;

irmin=[I0min T1min almin];
irmax=[I0max T1max almax];

for mm=1:size(irvals,1),

  x1=lsqnonlin('irfit',irguess,irmin,irmax,optvar,irtime,irvals(mm,:),absflag);
  irout=irfit(x1,irtime);

  if nargout==0,
    plot(irtime,irvals(mm,:),irtime,irout)
    title(sprintf('I0= %f au, T1= %f ms, alpha= %f',x1(1),x1(2)*1000,x1(3)))
    xlabel('Time')
    ylabel('Intensity')
    drawnow,
  else,
    I0(mm)=x1(1);
    T1(mm)=x1(2);
    al(mm)=x1(3);
  end;

end;

