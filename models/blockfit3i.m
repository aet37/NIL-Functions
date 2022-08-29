function [ff,u]=blockfit2(x,t,bdur,nblocks,y)
% Usage ... f=blockfit(x,t,nblocks,y)

%opt2=optimset('lsqnonlin');
%xxC=lsqnonlin(@blockfit,[8 0.5 1],[0.1 0 -1000],[100 1000 1000],opt2,t,u1,4,atcC);
%fitC=blockfit(xxC,t,u1,4);
%plot(t(1:20),aatcC/xxC(3),t(1:20),mean(matclip(fitC',4))/xxC(3)) 

tau=x(1);
amp=x(2);
baseline=x(3);
blocklag=x(4);
tau2=x(5);
amp2=x(6);

ti=[t(1):(t(2)-t(1))/100:t(end)]'; 
if (nargin>4), yi=interp1(t,y,ti); end;

blags=([1:nblocks]*2*bdur)-bdur/2+blocklag,
u=rect(t,bdur,blags);
ui=rect(ti,bdur,blags);
f=baseline+amp*mysol(1/tau,[1 1/tau],u,t);
f=f+amp2*mysol(1/tau2,[1 1/tau2],u,t);
fi=baseline+amp*mysol(1/tau,[1 1/tau],ui,ti);
fi=fi+amp2*mysol(1/tau2,[1 1/tau2],ui,ti);

if (nargin>4),
  ff=fi-yi;
else,
  ff=interp1(ti,fi,t);
end;

if (nargout==0),
  if (nargin>4),
    tb=t(1:end/nblocks);
    uu=mean(matclip(u',nblocks));
    %plot(tb,yb,tb,af)%,tb,uu)
    f2=interp1(ti,fi,t);
    plot(tb,mean(matclip(y,nblocks)),tb,mean(matclip(f2,nblocks)))
    %plot(t,y,t,f2)
  else
    plot(ti,fi)
  end;
  clear ff
end;

