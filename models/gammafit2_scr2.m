function [xx,y1,yh1]=gammafit2_scr2(data,t,uparms,parms,parms2fit,tbias,fit_type,struc_flag)
% Usage ... [xx,yy,yh]=gammafit2_scr2(data,t,uparms,parms,parms2fit,tbias,fit_type,struc_flag)
%
% Fit multi-input U convolved with multi-gamma function model to data 
% based on parameters parms (x0)
% parms(x0)=[del1 mtt1 wid1 amp1 del2/1 mtt2 wid2 amp2 ...]
%
% Ex. gammafit2_scr2(data,[t(:)-t(1) u1(:) u2(:)],[2 2],[0 1 1 0.3 0 2.5 1 -0.15],[1:8])
%     gammafit2_scr2(data,[t(:)-t(1) u1(:) u2(:)],[2 2],[0 1 1 0.3 0 2.5 1 -0.15],[2 3 4 6 7 8])

do_struc=1;
if ~exist('struc_flag','var'), struc_flag=[]; end;
if ~isempty(struc_flag), do_struc=struc_flag; end;

do_method=1;
if ~exist('fit_type','var'), fit_type=[]; end;
if ~isempty(fit_type), fit_type=do_method; end;

if prod(size(t))==length(t), t=t(:); end;
if length(uparms)==1, uparms(2)=0; end;

if ~exist('tbias','var'), 
  ibias=ones(size(data));
  tbias=[t(1,1) t(end,1)];
else, 
  ibias=zeros(size(data));
  ibias(find((t(:,1)>=tbias(1))&(t(:,1)<=tbias(2))))=1;
  tmpii=find(ibias>0.5);
  ibias=[tmpii(1) tmpii(end)];
  %plot(t(:,1),ibias), drawnow, pause,
end;
if ~exist('parms','var'),
  parms=[0 1 1 0.3];  
  if uparms(1)>1, for mm=2:uparms(1), parms=[parms 0 2.5 1 -0.15]; end; end;
  parms=[parms 0 1 1 3];
  if uparms(2)>1, for mm=2:uparms(2), parms=[parms 0 2.5 1 -0.15]; end; end; 
  parms,
  %size(parms),
end;
if ~exist('parms2fit','var'),
  parms2fit=[1:length(parms)];
  parms2fit=[[2:4:length(parms)] [3:4:length(parms)] [4:4:length(parms)]];
end;

xopt=optimset('lsqnonlin');
xopt.TolxFun=1e-10;
xopt.TolX=1e-8;

xlb=[ 0 1e-6 1e-6 -1e+6];
xub=[10 1e+2 1e+2 +1e+6];
if uparms(1)>1, xlb=[xlb 0  1e-6 1e-6 -1e+6]; xub=[xub 10 1e+2 1e+2 +1e+4]; end;
if uparms(1)>2, xlb=[xlb 0  1e-6 1e-6 -1e+6]; xub=[xub 10 1e+2 1e+2 +1e+4]; end;
xlb=[xlb  0 1e-6 1e-6 -1e+6];
xub=[xub 10 1e+2 1e+2 +1e+6];
if uparms(2)>1, xlb=[xlb 0  1e-6 1e-6 -1e+6]; xub=[xub 10 1e+2 1e+2 +1e+4]; end;
if uparms(2)>2, xlb=[xlb 0  1e-6 1e-6 -1e+6]; xub=[xub 10 1e+2 1e+2 +1e+4]; end;


x0=parms(parms2fit);
xlb=xlb(parms2fit);
xub=xub(parms2fit);

%gammafit2([0 1 1 0.3 0 2.5 1 -0.15],[],[1:8],tmptt1,tmpyy1)
[y0,yh0]=gammafit2_here(x0,uparms,parms,parms2fit,t);

if nargout==0,
  clf,
  plot(t(:,1),data,t(:,1),y0)
  axis('tight'), grid('on'), fatlines(1.5),
  tmpax=axis; axis([tbias tmpax(3:4)]);
  parms2fit,
  disp('  press enter to continue...')
  pause,
end;

if do_method==2,
  xx=fminunc(@gammafit2_here,x0,xlb,xub,xopt,uparms,parms,parms2fit,t,data,ibias,do_method);
else,
  %xx=lsqnonlin(@gammafit2_here,x0,xlb,xub,xopt,parms,parms2fit,t,data,ibias);
  xx=lsqnonlin(@gammafit2_here,x0,xlb,xub,xopt,uparms,parms,parms2fit,t,data,ibias,do_method);
end;
[y1,yh1]=gammafit2_here(xx,uparms,parms,parms2fit,t);
%size(y1), size(yh1),
rr=corr(data,y1);

if nargout==0,
  clf,
  subplot(211), plot(t(:,1),yh1), axis tight, grid on, fatlines(1.5);
  subplot(212), plot(t(:,1),data,t(:,1),y1), axis tight, grid on, fatlines(1.5),
  legend('data',sprintf('fit (r=%.3f',rr(1)))
  tmpax=axis; axis([tbias tmpax(3:4)]);
end;

if do_struc,
  xs.xx=xx;
  xs.x0=parms;
  xs.xlb=xlb;
  xs.xub=xub;
  xs.parms2fit=parms2fit;
  xs.tt=t;
  xs.tbias=tbias;
  if size(t,2)>1, xs.uu=t(:,2:end); end;
  xs.yh=yh1;
  xs.yf=y1;
  xs.yy=data;
  xs.r=rr;
  clear xx
  xx=xs;
  clear xs
end;

return




% Function declarations
%
function [yy,yyh]=gammafit2_here(x,uparms,parms,parms2fit,tt,data,ibias,method_type)

do_verbosefig=0;
%do_verbosefig=(nargout==0);

if nargin<8, method_type=1; end;

if nargin<7,
  ibias=[1 length(tt)];
end;
if length(ibias)==2, ibias=[ibias(1):ibias(2)]; else, ibias=find(ibias>0.5); end;

if (prod(size(tt))==length(tt)), tt=tt(:); end;

if (~isempty(x)),
  parms(parms2fit)=x;
end;

yy=zeros(length(tt(:,1)),length(uparms));
for mm=1:length(uparms),
  if mm==1, ui=0; ua=1; else, ui=(mm-1)*sum(uparms(1:mm-1))*4; ua=parms(ui+4); end;
  for nn=1:uparms(mm),
    %[ui+(nn-1)*4+[1 2 3 4]],
    t0=parms( ui+(nn-1)*4+ 1);
    tau=parms(ui+(nn-1)*4+ 2);
    b=parms(  ui+(nn-1)*4+ 3);
    a=parms(  ui+(nn-1)*4+ 4);
    
    %size(gammafun(tt(:,1),t0,tau,b))
    yy(:,mm)=yy(:,mm)+a*ua*gammafun(tt(:,1),t0,tau,b);
    %yy(:,mm)=yy(:,mm)+a*gammafun(tt(:,1),t0,tau,b);
    clear t0 tau b a
  end;
end;


if (size(tt,2)>1), 
  yyh=yy;
  yy=zeros(size(tt(:,1)));
  for nn=1:length(uparms),
    if (size(tt,2)>2),
      % pair input to gamma
      %[nn nn],
      uu=tt(:,nn+1);
      yy=yy+myconv(uu,yyh(:,nn)); 
    else,
      % one input several gamma
      %[1 nn],
      uu=tt(:,2);
      yy=yy+myconv(uu,yyh(:,nn));
    end;
    %size(yy),
    %clf, plot(yy), xlabel(sprintf('%d',nn)), drawnow,
  end;
else,
  yyh=zeros(size(tt(:,1)));
end;
%keyboard,

if (nargin>5),
  if method_type==2,
    ee=yy(:)/std(yy(:))-data(:)/std(data(:));
  else,
    ee=yy(:)-data(:);
  end;
  disp(sprintf('  mse=%.3e, t0=%.3f, tau=%.3f, b=%.3f, a=%.3f, bias=[%d %d]',mean(ee.^2),parms(1),parms(2),parms(3),parms(4),ibias(1),ibias(end)));
  if do_verbosefig,
    plot(tt(:,1),yy,tt(:,1),data)
    clear yy
  end;
  %keyboard,
  yy=ee(ibias);
else,
  if do_verbosefig,
    plot(tt(:,1),yy)
    clear yy
  end;
end;

return
