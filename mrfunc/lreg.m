function [m,b,s,t,l]=lreg(xvec,yvec)
% Usage ... [m,b,s,t,l]=lreg(xvec,yvec)
% T assumes NULL hypothesis test

xvec=xvec(:);
yvec=yvec(:);
 
[xr,xc]=size(xvec);
[yr,yc]=size(yvec);
 
if (xr~=yr), error('Vectors must be of same length!'); end;
 
sumx=sum(xvec);
sumy=sum(yvec);
sumxy=sum(xvec.*yvec);
sumx2=sum(xvec.*xvec);
meanx=mean(xvec);
meany=mean(yvec);
 
m= (xr*sumxy - sumx*sumy)/(xr*sumx2 - sumx*sumx);
b= meany - m*meanx;
[r,pval]= corrcoef(xvec,yvec);

l= xvec*m + b;
s= sqrt( sum((l-yvec).*(l-yvec))/(xr-2) );
 
t= m*sqrt(sumx2-(1/xr)*sumx*sumx)/s;
%t= r(1,2)*sqrt(xr-2)/sqrt(1-r(1,2)*r(1,2));	% same as above

ve=1-var(l-yvec)/var(yvec);

if nargout==0,
  plot(xvec,yvec,'bx',xvec,l,'k-');
  title(sprintf('m= %.3f, b= %.3f, r= %.3f, t= %.3f, p= %.3f',m,b,r(1,2),t,pval(1,2)));
  disp(sprintf('  m= %f  b= %f  s= %f  r= %f  t= %f  ve= %f',m,b,s,r(1,2),t,ve));
end;

if nargout==1,
  mmm=m;
  clear m
  m.m=mmm;
  m.b=b;
  m.yerr=yvec-l;
  m.t=t;
  m.r=r(1,2);
  m.p=pval(1,2);
  m.s=s;
  m.yvar=var(yvec);
  m.yhat=l;
  m.rvar=var(yvec-l);
  m.varexp=1-m.rvar/m.yvar;
end;

