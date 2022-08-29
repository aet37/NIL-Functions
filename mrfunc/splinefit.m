function f=splinefit(y,parms,ref)
% Usage ... f=splinefit(y,parms,ref)
%
% fit a smooth spline to y using parameters parms and
% reference ref
% parms = [knot-interval MA-1side-length ]

if (nargin==1),
  parms(1)=round(0.05*length(y));
  parms(2)=2;
end;

ylen=length(y);
t=[1:ylen]';
knotint=parms(1);
ma1len=parms(2);

if (nargin<3), ref_flag=0; else, ref_flag=1; end;

if (ref_flag),
  diffthr=2.5*std(abs(diff(y)));

else,
  cnt1=1;
  ti(1)=t(1);
  yi(1)=y(1);
  for m=knotint:knotint:ylen,
    if ((m-ma1len)>=1)&((m+ma1len)<=ylen),
      cnt1=cnt1+1;
      ti(cnt1)=t(m);
      yi(cnt1)=mean(y(m-ma1len:m+ma1len));
    end;
  end;
  cnt1=cnt1+1;
  ti(cnt1)=t(end);
  yi(cnt1)=y(end);
end;
disp(sprintf(' knot-interval= %d   MA-1sided-length= %d',knotint,ma1len));
disp(sprintf(' total # knots = %d  reference= %d',cnt1,ref_flag));

f=interp1(ti,yi,t);

if (nargout==0),
  plot(t,y,t,f,ti,yi,'o')
end;

