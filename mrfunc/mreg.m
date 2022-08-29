function [x,xf,t,f]=mreg(xmat,y,meanflag,filter,ii_in)
% Usage ... [x,xf,t,df]=mreg(xmat,y,meanflag,filter,ii_in)
%
% Multiple regression of the columns of the xmat
% with y. Filter (contrast) subtracts the regression from the
% columns in xmat (use the indeces). meanflag adds a columns
% of ones to the first column in xmat
% ii_in indicates data indices to be used in coefficient computation

if nargin<5, ii_in=[]; end;
if nargin<4, filter=[]; end;
if nargin<3, meanflag=[]; end;

if isempty(meanflag), meanflag=1; end;
if isempty(filter), filter=1; end;
if isempty(ii_in), ii_in=[1:size(xmat,1)]'; end;

if length(filter)==1, if filter==1, filter=ones(1,size(xmat,2)); end; end;

if (meanflag),
  A=[ones(size(xmat,1),1) xmat]';
  filter=[1 filter];
else,
  A=xmat';
end;

invAAp=inv(A(:,ii_in)*A(:,ii_in)');

for n=1:size(y,2),
  %disp('Vector ...');
  %disp('Calculating coefficients ...');
  x(:,n)=invAAp*(A(:,ii_in)*y(ii_in,n));

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


if nargout==0,
  subplot(221), plot(xmat,y,'x',xmat,yhat,'-'),
  subplot(222), plot([y(:) yhat(:)]),
  subplot(223), plot(xmat),
  subplot(224), plot([xf(:)]),
  %plot([y(:) yhat(:)])
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

