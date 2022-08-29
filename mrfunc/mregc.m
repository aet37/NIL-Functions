function [x,xf,t,f]=mreg(xmat,y,cont,meanflag,filter)
% Usage ... [x,xf,t,df]=mreg(xmat,y,contrasts,meanflag,filter)
%
% Multiple regression of the columns of the xmat
% with y. Filter (contrast) subtracts the regression from the
% columns in xmat (use the indeces).

if nargin<5, filter=ones(1,size(xmat,2)); end;
if nargin<4, meanflag=1; end;

if length(filter)==1, if filter==1, filter=ones(size(xmat,1),1); end; end;

if (meanflag),
  A=[ones([size(xmat,1) 1]) xmat]';
  filter=[1 filter];
else,
  A=xmat';
end;

invAAp=inv(A*A');

for n=1:size(y,2),
  %disp('Vector ...');
  %disp('Calculating coefficients ...');
  x(:,n)=invAAp*(A*y(:,n));

  %yhat(:,n)=x(1,n)*ones(size(A(1,:)'));
  %for m=2:size(x,1),
  %  yhat(:,n)=yhat(:,n)+x(m,n)*(A(m,:)');
  %end;
  yhat(:,n)=A'*(x(:,n).*filter(:));

  SSE(n)=sum((y(:,n)-yhat(:,n)).^2);
  SST(n)=sum((y(:,n)-mean(y(:,n))).^2);
  SSTx=sum((A-mean(A,2)*ones(1,size(A,2),1)).^2,2);
  R2(n)=1-SSE(n)/SST(n);
  S2(n)=SSE(n)/(size(y,1)-size(x,1));
  VV(n)=var(y(:,n));
  VR(n)=var(y(:,n)-yhat(:,n));
  t(:,n)=x(:,n)*sqrt(SSE(n)/(length(y)-2))./sqrt(SSTx);
  
  f(n)=(R2(n)/size(x,1))/((1-R2(n))/(size(y,1)-size(x,1)));

  % Filter data set through regressors
  %sub=x(filter(1)+1,n)*xmat(:,filter(1));
  %if length(filter)>1,
  %  for m=2:length(filter),
  %    sub=sub+x(filter(m)+1,n)*xmat(:,filter(m));
  %  end;
  %end;
  xf(:,n)=y(:,n)-yhat(:,n);
  
  if (meanflag), xf(:,n)=xf(:,n)+mean(yhat(:,n)); end;
  
end;

% contrast calculation
varest=(y-A'*x)'*(y-A'*x)/(size(A,2)-size(A,1));
for mm=1:size(cont,1),
  vc(mm)=cont(mm,:)*invAAp*varest*invAAp*cont(mm,;)';
  tc(mm)=x'*cont(mm,:)'./sqrt(vc(mm));
end;


if nargout==0,
  plot(xmat,y,'x',xmat,yhat,'-'),
  %tmp=corrcoef(xmat,y);
  %msg=sprintf('r=%f (%f,%f) SSE=%f',tmp(1,2),x(1),x(2),SSE);
  %title(msg);
end;

if nargout==1,
  xx=x;
  clear x
  x.b=xx;
  x.cont=filter;
  x.yhat=yhat;
  x.yf=xf;
  x.yvar=VV;
  x.sse=SSE;
  x.sst=SST;
  x.varexp=1-VR./VV;
  x.tval=t;
end;

