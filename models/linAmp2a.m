function [xx,y1]=linAmp2a(x,t,u,hrf,data,tbias)
% Usage ... [xnew,yest,uu1]=linAmp2a(x,t,u,hrf,data,tbias_or_ww)
%
% Similar to linAmp2 but different approach. This version convolves u with HRF
% and determines the scale factors necessary to best fit the data
%
% Ex. [x1,y1_est]=linAmp2([1 1],t1,mua1,[hrf1(:) hrf2(:)],y1);

if isempty(t), t=[1:length(hrf)]; t=t(:); end;
if nargin<6, tbias=[t(1) t(end)]; end;
for mm=1:length(tbias), ibias(mm)=find(t>=tbias(mm),1); end;

xopt=optimset('lsqnonlin');
xopt.TolxFun=1e-10;
xopt.TolX=1e-8;


% find scaling factors if x is empty
if isempty(x),
  x0=ones(1,size(hrf,2));
else,
  x0=x;
end;

if length(u)==prod(size(u)), u=u(:); end;
if length(hrf)==prod(size(hrf)), hrf=hrf(:); end;

for mm=1:size(u,2), u(:,mm)=u(:,mm)/sum(u(:,mm)); end;
for mm=1:size(hrf,2), hrf(:,mm)=hrf(:,mm)/sum(hrf(:,mm)); end;

for mm=1:size(u,2),
  uu(:,mm)=myconv(u(:,mm),hrf(:,mm));
end;

xlb=-1e4*ones(1,size(hrf,2));
xub=+1e4*ones(1,size(hrf,2));

if nargin>4,
  xx=lsqnonlin(@linAmp2a_wrap,x0,xlb,xub,xopt,t,u,hrf,data,ibias);
else,
  xx=x;
end;

[y0,u0]=linAmp2a_wrap(x0,t,u,hrf);
[y1,u1]=linAmp2a_wrap(xx,t,u,hrf);

if nargout==0,
  clf,
  if ~exist('data','var'),
    plot(t,y0,t,y1)
    axis tight, grid on, legend('est0','est-new'),
  else,
    subplot(211), plot(t,u,t,uu), axis tight, grid on,
    subplot(212), plot(t,data,t,y0,t,y1), axis tight, grid on,
    axis tight, grid on, legend('data','est0','est-new'),
  end;
  ylabel('Amplitude'), xlabel('Time'),
  set(gca,'FontSize',12), dofontsize(15);
end;


% sub-function defitions
function [y,u,uu]=linAmp2a_wrap(x,t,u,hrf,data,ibias)
  yest=0;
  if size(u,2)==1,
    for nn=1:size(hrf,2),
      yest=yest+myconv(u(:,1),x(nn)*hrf(:,nn));
    end;
  else,
    for nn=1:size(hrf,2),
      yest=yest+myconv(u(:,nn),x(nn)*hrf(:,nn));
    end;
  end;
  y=yest;
    
  if nargin>4,
    y=yest-data;
    if length(ibias)==2, 
      ibias=[ibias(1):ibias(2)]; 
    elseif length(ibias)==length(data),
      ibias=find(ibias);
    end;
    y=y(ibias);
    disp(sprintf('  mse=%.3f, x=[%.2f]',mean(y.^2),x(1)));
  end;
return

