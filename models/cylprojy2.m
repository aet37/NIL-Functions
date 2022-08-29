function y=cylprojy2(xx,xg,parms2fit,x,data,penalty_flag)
% Usage ... y=cylproj2(xx,xg,parms2fit,xdata,data,penalty_flag)
%
% xg = [rad r0 amp bb mm filtw rad2 amp12]

donorm=1;

xg_orig=xg;

if (~isempty(xx)),
  xg(parms2fit)=xx;
end;

rr=xg(1);
r0=xg(2);
aa=xg(3);
bb=xg(4);
mm=xg(5);
rfw=xg(6);
rr2=xg(7);
aa2=xg(8);

x=x-r0;

%y = 2*(1/rr)*(1/2)*( x.*sqrt(rr*rr - x.*x) + rr*rr*asin(x/rr) );
y1 = 2*sqrt(1 - (x.*x)/(rr*rr));
y2 = 2*sqrt(1 - (x.*x)/(rr2*rr2));

y1(find(abs(x)>rr))=0;
y2(find(abs(x)>rr2))=0;

if rfw<=0,
  y12 = y1 + aa2*y2;
  y12f = y12;
else,
  %y12f = (1-exp(-y12/rfw));
  y12 = y1 + aa2*y2;
  y12f = (1-exp(-y1*rfw)) + aa2*(1-exp(-y2*rfw));
end;
if (donorm),
  y12f = y12f - min(y12f);
  y12f = y12f/max(y12f);
end;

y = aa*y12f + mm*x + bb;

if (nargin>4),
  if (nargin<6), penalty_flag=[]; end;
  %penalty_flag,
  if isempty(penalty_flag),
    err=y-data;
    penalty2=0;
    ybkup=y;
    y=err;
  elseif penalty_flag==0,
    err=y-data;
    penalty2=0;
    ybkup=y;
    y=err;
  else,
    alpha=10*penalty_flag;
    cont=[0 1 0 0 4 100 100 100];
    iii=find(xg_orig==0);
    if (~isempty(iii)),
      iii2=find(xg_orig~=0);
      penalty=(xg(iii2)./xg_orig(iii2)-1).*cont(iii2);
    else,
      penalty=(xg./xg_orig-1).*cont;
    end;
    penalty2=alpha*sum(abs(penalty));
    err=y-data;
    ybkup=y;
    y=err.*err+penalty2;
  end;
  %[xx mean(y.*y)]
  %[mean(err) penalty2],
  if nargout==0,
    figure(1)
    subplot(311)
    plot(x,y1,x,y2,x,y12)
    subplot(312)
    plot(x,y12f)
    subplot(313)
    plot(x,ybkup,x,data)
  end;
elseif (nargout==0),
  subplot(311)
  plot(x,y1,x,y2,x,y12)
  subplot(312)
  plot(x,y12f)
  subplot(313)
  plot(x,y)
end;

%keyboard,
