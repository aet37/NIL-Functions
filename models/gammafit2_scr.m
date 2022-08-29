function [xx,y1,yh1]=gammafit2_scr(data,t,parms,parms2fit,tbias,fit_type,struc_flag)
% Usage ... [xx,yy,yh]=gammafit2_scr(data,t,parms,parms2fit,tbias,fit_type,struc_flag)
%
% Fit gamma function model to data based on parameters parms (x0)
% parms(x0)=[del1 mtt1 wid1 amp1 del2/1 mtt2 wid2 amp2 ...]
%
% Ex. gammafit2_scr(data,[t(:)-t(1) u(:)],[0 1 1 0.3 0 2.5 1 -0.15],[1:8])
%     gammafit2_scr(data,[t(:)-t(1) u(:)],[0 1 1 0.3 0 2.5 1 -0.15],[2 3 4 6 7 8])
%     y36=gammafit2_scr(tcVV.atc_n(:,6)-1,[tt-tt(1) tcVV.atc_n(:,3)-1],[0 1 1 0.3],[1:4],[],[],1);

do_struc=0;
if ~exist('struc_flag','var'), struc_flag=[]; end;
if ~isempty(struc_flag), do_struc=struc_flag; end;

do_method=1;
if ~exist('fit_type','var'), fit_type=[]; end;
if isempty(fit_type), fit_type=do_method; end;

if prod(size(t))==length(t), t=t(:); end;

if ~exist('tbias','var'), tbias=[]; end;
if isempty(tbias),
  ibias=ones(size(data));
  tbias=[t(1,1) t(end,1)];
else, 
  ibias=zeros(size(data));
  ibias(find((t(:,1)>=tbias(1))&(t(:,1)<=tbias(2))))=1;
  tmpii=find(ibias>0.5);
  ibias=[tmpii(1) tmpii(end)];
  %plot(t(:,1),ibias), drawnow, pause,
end;
if ~exist('parms2fit','var'), parms2fit=[1:8]; end;
if ~exist('parms','var'), parms=[0.5 0.5 1.0 0 1 0.5 0.4 0.8]; end;

xlb=[0  1e-6 1e-6 1e-10 0  1e-6 1e-6 -1e+4 0  1e-6 1e-6 1e-6];
xub=[10 1e+2 1e+2 1e+10 10 1e+2 1e+2 -1e-6 0  5e+0 1e+0 1e+1];

if length(parms)<5, xlb=xlb(1:4); xub=xub(1:4); end;

x0=parms(parms2fit);
xlb=xlb(parms2fit);
xub=xub(parms2fit);

%gammafit2([0 1 1 0.3 0 2.5 1 -0.15],[],[1:8],tmptt1,tmpyy1)
[y0,yh0]=gammafit2(x0,parms,parms2fit,t);

if nargout==0,
  clf,
  plot(t(:,1),data,t(:,1),y0)
  axis('tight'), grid('on'), fatlines(1.5),
  tmpax=axis; axis([tbias tmpax(3:4)]);
  parms2fit,
  disp('  press enter to continue...')
  pause,
end;

if fit_type>=3,
  xopt=optimset('fminsearch');
  xopt.TolxFun=1e-10;
  xopt.TolX=1e-8;
  xx=fminsearch(@gammafit2,x0,xopt,parms,parms2fit,t,data,ibias,fit_type);
else,
  xopt=optimset('lsqnonlin');
  xopt.TolxFun=1e-10;
  xopt.TolX=1e-8;
  %xx=lsqnonlin(@gammafit2,x0,xlb,xub,xopt,parms,parms2fit,t,data,ibias);
  xx=lsqnonlin(@gammafit2,x0,xlb,xub,xopt,parms,parms2fit,t,data,ibias,fit_type);
end;
[y1,yh1]=gammafit2(xx,parms,parms2fit,t);
rr=corr(data,y1);

if nargout==0,
  clf,
  if size(t,2)>1,
    subplot(311), plot(t(:,1),t(:,2)), axis('tight'), grid('on'), fatlines(1.5),
    subplot(312), plot(t(:,1),yh1), axis tight, grid on, fatlines(1.5),
    subplot(313), plot(t(:,1),data,t(:,1),y1), axis tight, grid on, fatlines(1.5),
    legend('data',sprintf('fit (r=%.3f)',rr(1)))
    tmpax=axis; axis([tbias tmpax(3:4)]);
  else,
    subplot(211), plot(t(:,1),yh1), axis tight, grid on, fatlines(1.5),
    subplot(212), plot(t(:,1),data,t(:,1),y1), axis('tight'), grid('on'), fatlines(1.5),
    legend('data',sprintf('fit (r=%.3f)',rr(1)))
    tmpax=axis; axis([tbias tmpax(3:4)]);
  end;
end;

if do_struc,
  xs.xx=xx;
  xs.x0=parms;
  xs.y0=y0;
  xs.parms2fit=parms2fit;
  xs.tt=t;
  xs.tbias=tbias;
  xs.yh=yh1;
  xs.yf=y1;
  xs.yy=data;
  xs.ee=data-y1;
  xs.r=rr;
  clear xx
  xx=xs;
  clear xs
end;
