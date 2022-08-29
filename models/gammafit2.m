function [yy,yyh]=gammafit2(x,parms,parms2fit,tt,data,ibias,method_type)
% Usage ... yy=gammafit2(x,parms,parms2fit,tdata,data,bias,method_type)

do_verbosefig=0;
do_verbosefig=(nargout==0);

if nargin<7, method_type=1; end;

if nargin<6,
  ibias=[1 length(tt)];
end;
if length(ibias)==2, ibias=[ibias(1):ibias(2)]; else, ibias=find(ibias>0.5); end;

if (prod(size(tt))==length(tt)), tt=tt(:); end;

if (~isempty(x)),
  parms(parms2fit)=x;
end;

t0=parms(1);
tau=parms(2);
b=parms(3);
a=parms(4);
  
yy=gammafun(tt(:,1),t0,tau,b);

if length(parms)>4,
  t0_2=parms(5);
  tau_2=parms(6);
  b_2=parms(7);
  a_2=parms(8);
  yy = yy + a_2*gammafun(tt(:,1),t0+t0_2,tau_2,b_2);
end;
if length(parms)>8,
  t0_3=parms(9);
  tau_3=parms(10);
  b_3=parms(11);
  a_3=parms(12);
  yy = yy + a_3*gammafun(tt(:,1),t0+t0_3,tau_3,b_3);
end;


yy=a*yy(:);

if (size(tt,2)>1), 
  yyh=yy;
  uu=tt(:,2);
  yy=myconv(uu,yyh); 
else,
  yyh=zeros(size(tt));
end;

if (nargin>4),
  if method_type==2,
    ee=yy(:)/std(yy(:))-data(:)/std(data(:));
    yy=ee(ibias);
  elseif method_type==3,
    ee=1-corr(yy(ibias),data(ibias)).^2;
  else,
    ee=yy(:)-data(:);
    yy=ee(ibias);
  end;
  disp(sprintf('  mse=%.3e, t0=%.3f, tau=%.3f, b=%.3f, a=%.3f, bias=[%d %d]',mean(ee.^2),parms(1),parms(2),parms(3),parms(4),ibias(1),ibias(end)));
  if do_verbosefig,
    plot(tt(:,1),yy,tt(:,1),data)
    clear yy
  end;
  %keyboard,
else,
  if do_verbosefig,
    plot(tt(:,1),yy)
    clear yy
  end;
end;

