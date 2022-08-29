function y=cylprojy(xx,xg,parms2fit,x,data,penalty_flag)
% Usage ... y=cylproj(xx,xg,parms2fit,xdata,data,penalty_flag)
%
% xg=[rr r0 amp base slope]
% eg. yy=cylprojy([],[7 50 1 0 0],[],[1:100]);

xg_orig=xg;

if (~isempty(xx)),
  xg(parms2fit)=xx;
end;

rr=xg(1);
r0=xg(2);
aa=xg(3);
bb=xg(4);
mm=xg(5);

x=x-r0;

%y = 2*(1/rr)*(1/2)*( x.*sqrt(rr*rr - x.*x) + rr*rr*asin(x/rr) );
y = 2*sqrt(1 - (x.*x)/(rr*rr));

y(find(abs(x)>rr))=0;

y = aa*y + mm*x + bb;

if (nargin>4),
  if (nargout==0),
    plot(x,data,x,y)
  end;
  if (nargin<6), penalty_flag=[]; end;
  %penalty_flag,
  if isempty(penalty_flag),
    err=y-data;
    penalty2=0;
    y=err;
  else,
    alpha=10*penalty_flag;
    cont=[0 1 0 0 4];
    iii=find(xg_orig==0);
    if (~isempty(iii)),
      iii2=find(xg_orig~=0);
      penalty=(xg(iii2)./xg_orig(iii2)-1).*cont(iii2);
    else,
      penalty=(xg./xg_orig-1).*cont;
    end;
    penalty2=alpha*sum(abs(penalty));
    err=y-data;
    y=err.*err+penalty2;
  end;
  %[xx mean(y.*y)]
  %[mean(err) penalty2],
elseif (nargout==0),
  plot(x,y)
end;

