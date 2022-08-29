function [ff,u]=blockfit2(x,t,bdur,nblocks,y)
% Usage ... f=blockfit(x,t,blocklags,y)

%opt2=optimset('lsqnonlin');
%xxC=lsqnonlin(@blockfit,[8 0.5 1],[0.1 0 -1000],[100 1000 1000],opt2,t,u1,4,atcC);
%fitC=blockfit(xxC,t,u1,4);
%plot(t(1:20),aatcC/xxC(3),t(1:20),mean(matclip(fitC',4))/xxC(3)) 

tau=x(1);
amp=x(2);
baseline=x(3);
blocklag=x(4);
if (length(x)>4),tmp=x(5); end;

ti=[t(1):(t(2)-t(1))/100:t(end)]'; 
if (nargin>4), yi=interp1(t,y,ti); end;

blags=nblocks+([1:length(nblocks)]*2*bdur)-bdur/2+blocklag,
u=rect(t,bdur,blags);
ui=rect(ti,bdur,blags);
f=baseline+amp*mysol(1/tau,[1 1/tau],u,t);
fi=baseline+amp*mysol(1/tau,[1 1/tau],ui,ti);

if (nargin>4),
  ff=fi-yi;
else,
  ff=interp1(ti,fi,t);
end;

if (nargout==0),
  if (nargin>4),
    tb=t(1:end/length(nblocks)); 
    uu=mean(matclip(u',length(nblocks)));
    %plot(tb,yb,tb,af)%,tb,uu)
    f2=interp1(ti,fi,t);
    plot(tb,mean(matclip(y',length(nblocks))),tb,mean(matclip(f2,length(nblocks))))
    %plot(t,y,t,f2)
  else
    plot(ti,fi)
  end;
  clear ff
end;

