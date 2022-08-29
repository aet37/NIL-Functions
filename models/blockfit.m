function ff=blockfit(x,t,u,nblocks,y)
% Usage ... f=blockfit(x,t,nblocks,y)

%opt2=optimset('lsqnonlin');
%xxC=lsqnonlin(@blockfit,[8 0.5 1],[0.1 0 -1000],[100 1000 1000],opt2,t,u1,4,atcC);
%fitC=blockfit(xxC,t,u1,4);
%plot(t(1:20),aatcC/xxC(3),t(1:20),mean(matclip(fitC',4))/xxC(3)) 

tau=x(1);
amp=x(2);
baseline=x(3);

f=baseline+amp*mysol(1/tau,[1 1/tau],u,t);
af=mean(matclip(f',nblocks))';

if (nargin>4),
  yb=mean(matclip(y',nblocks))';
  ff=af-yb;
else,
  ff=f;
end;

if (nargout==0),
  if (nargin>4),
    tb=t(1:end/nblocks);
    plot(tb,yb,tb,af)
  else
    plot(t,f)
  end;
  clear ff
end;

