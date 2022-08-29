function [xx,y1,y2]=linAmp1(x,t,hrf,ts,data,tbias)
% Usage ... [xnew,yest]=linAmp1(x,t,hrf,ts,data,tbias_or_ww)
%
% Shifts y1 by xs and scales each shift by x 
% Ex. y_est=linAmp1([],t,y1,[0:1:3],yy);
%     y_est=linAmp1([1 1 1 1],t,y1),[0:1:3]);

if isempty(t), t=[1:length(hrf)]; t=t(:); end;
if nargin<6, tbias=[t(1) t(end)]; end;
for mm=1:length(tbias), ibias(mm)=find(t>=tbias(mm),1); end;

if prod(size(hrf))==length(hrf), hrf=hrf(:); end;

dt=mean(diff(t));
xs=round(ts/dt);
tmpstr=['  shifts: '];
for mm=1:length(xs), tmpstr=sprintf('%s t[%.2f]=%d ',tmpstr,ts(mm),xs(mm)); end;
disp(tmpstr);

x0=ones(1,length(xs)*size(hrf,2));

% find scaling factors if x is empty
if isempty(x),
  xopt=optimset('lsqnonlin');
  xopt.TolxFun=1e-10;
  xopt.TolX=1e-8;

  xlb=-1e4*ones(1,length(xs)*size(hrf,2));
  xub=+1e4*ones(1,length(xs)*size(hrf,2));

  if nargin>4,
    xx=lsqnonlin(@linAmp1_wrap,x0,xlb,xub,xopt,hrf,xs,data,ibias);
  else,
    xx=x0;
  end;
else,
  xx=x;
end;

y0=linAmp1_wrap(x0,hrf,xs);
y1=linAmp1_wrap(xx,hrf,xs);

if size(hrf,2)>1,
  y2=zeros(size(hrf));
  for nn=1:size(hrf,2),
    for mm=1:length(xs),
      y2(:,nn)=y2(:,nn)+xx(mm+(nn-1)*length(xs))*xshift(hrf(:,nn),xs(mm),1);
    end;
  end;
  xx=reshape(xx,[length(xs) size(hrf,2)]);
else,
  y2=[];
end;

if nargout==0,
  clf,
  if ~exist('data','var'),
    plot(t,y0,t,y1)
    axis tight, grid on, legend('est0','est-new'),
  else,
    plot(t,data,t,y0,t,y1)
    axis tight, grid on, legend('data','est0','est-new'),
  end;
  ylabel('Amplitude'), xlabel('Time'),
  set(gca,'FontSize',12), dofontsize(15);
end;


% sub-function defitions
function y=linAmp1_wrap(x,hrf,xs,data,ibias)
  yest=zeros(length(hrf),1);
  for nn=1:size(hrf,2),
    for mm=1:length(xs),
      yest=yest+x(mm+(nn-1)*length(xs))*xshift(hrf(:,nn),xs(mm),1);
    end;
  end;
  y=yest;
  if nargin>3,
    y=yest(:)-data(:);
    if length(ibias)==2, 
      ibias=[ibias(1):ibias(2)]; 
    elseif length(ibias)==length(data),
      ibias=find(ibias);
    end;
    y=y(ibias);
  end;
return

