function out=nfitsub(y,x,xi,avgrange,noskp,avgstrt,strt,taum,breakloc,bsln,outpt)
%
% Usage ... out=nfitsub(y,x,xi,avgrange,noskp,avgstrt,strt,taum,breakloc,bsln,outpt)
%
%

y=(y-bsln)/bsln;

if ( length(breakloc)==1 ),
  subexp=myfit2(y,taum,breakloc);
elseif ( length(breakloc)==2 ),
  subexp=myfit3(y,taum,breakloc);
end;

ytemp=y;
y=y-subexp;

if (avgstrt), yt(1)=mean(y(1:avgstrt)); else yt(1)=y(1); end;
xt(1)=x(1);
[maxval,maxind]=max(y);

for n=1:floor(length(x)/noskp),
  if ( n*noskp+avgrange > length(x) ),
    adjust=1;
    break;
  end;
  yt(n+1)=mean(y(n*noskp-avgrange:n*noskp+avgrange));
  if ( (maxind>=n*noskp-avgrange/1.5)&(maxind<=n*noskp+avgrange/1.5) ),
    yt(n+1)=yt(n+1)+0.68*std(y(n*noskp-avgrange:n*noskp+avgrange));
  end;
  xt(n+1)=x(n*noskp);
end;

if ( adjust ), if ( xtsample+xt(length(xt)) < x(length(x)) ),
  xtsample=xt(length(xt))-xt(length(xt)-1);
  xtfinavg=x(length(x))-(xtsample+xt(length(xt)));
  pos=length(xt)+1;
  xt(pos)=xt(pos-1)+xtsample;
  yt(pos)=mean(y(xt(pos)-xtfinavg:xt(pos)+xtfinavg));
end; end;

xt(length(xt)+1)=x(length(x));
yt(length(yt)+1)=mean(y(length(y)-avgstrt:length(y)));

ynew=spline(xt,yt,xi);
zeroln=zeros(length(ynew),1);

out=ynew;

if (outpt),
  figure(1);
  plot(x,ytemp,'-',x,subexp,'--');
  title('Exponential fit of trend data');
  xlabel('Index number');
  figure(2);
  plot(xt,yt,'o',xi,ynew,'-',xi,zeroln,'-');
  title('Spline interpolation of subtracted data');
  xlabel('Index number')
end;

