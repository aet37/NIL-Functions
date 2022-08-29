function [ff,u]=blockfit2(x,t,bdur,nblocks,y)
% Usage ... f=blockfit(x,t,bdur,nblocks,y)

%opt2=optimset('lsqnonlin');
%xxC=lsqnonlin(@blockfit,[8 0.5 1],[0.1 0 -1000],[100 1000 1000],opt2,t,u1,4,atcC);
%fitC=blockfit(xxC,t,u1,4);
%plot(t(1:20),aatcC/xxC(3),t(1:20),mean(matclip(fitC',4))/xxC(3)) 

tau=x(1);
amp=x(2);
baseline=x(3);
blocklag=x(4);

blags=([1:nblocks]*2*bdur)-bdur/2+blocklag;
u=rect(t,bdur,blags);
f=baseline+amp*mysol(1/tau,[1 1/tau],u,t);

%af=mean(matclip(f',nblocks))';

if (nargin>4),
  %yb=mean(matclip(y',nblocks))';
  %ff=af-yb;
  ff=f-y;
else,
  ff=f;
end;

if (nargout==0),
  if (nargin>4),
    tb=t(1:end/nblocks);
    %uu=mean(matclip(u',nblocks));
    plot(t,y,t,f)%,tb,uu)
  else
    plot(t,f)
  end;
  clear ff
end;

