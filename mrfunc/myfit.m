function out=myfit(y,x,xi,avgrange,noskp,avgstrt,strt,outpt)
%
% Usage ... out=myfit(y,x,xi,avgrange,noskp,avgstrt,strt,outpt)
%
%
%

if (avgstrt), yt(1)=mean(y(1:avgstrt)); else yt(1)=y(1); end;
xt(1)=x(1);
[maxval,maxind]=max(y);

if ( length(noskp)==1 ),
 for n=1:floor(length(x)/noskp),
  if ( n*noskp+avgrange > length(x) ),
    adjust=1;
    break;
  end;
  yt(n+1)=mean(y(n*noskp-avgrange:n*noskp+avgrange));
  if ( (maxind>=n*noskp-avgrange/1.5)&(maxind<=n*noskp+avgrange/1.5) ),
    yt(n+1)=yt(n+1)+0.682*std(y(n*noskp-avgrange:n*noskp+avgrange));
  end;
  xt(n+1)=x(n*noskp);
 end;
else,
 for n=1:length(noskp),
  yt(n+1)=mean(noskp(n)-avgrange:noskp(n)+avgrange);
  if ( noskp(n)==maxind ),
    yt(n+1)=yt(n+1)+0.68*std(noskp(n)-avgrange:noskp(n)+avgrange); end;
 end;
end;

xtsample=xt(length(xt))-xt(length(xt)-1);
if ( adjust ), if ( xtsample+xt(length(xt)) < x(length(x)) ),
  xtfinavg=x(length(x))-(xtsample+xt(length(xt)));
  pos=length(xt)+1;
  xt(pos)=xt(pos-1)+xtsample;
  yt(pos)=mean(y(xt(pos)-xtfinavg:xt(pos)+xtfinavg));
end; end;

xt(length(xt)+1)=x(length(x));
yt(length(yt)+1)=mean(y(length(y)-avgstrt:length(y)));

ynew=spline(xt,yt,xi);

out=ynew;

if ( outpt ),
  figure(1);
  plot(x,y,':',xi,ynew,'-',xt,yt,'o');
  title('Spline Interpolation of Data thru Knot calculation by averaging');
  xlabel('Time units');
end;
if ( outpt==2 ), mprint; end;
