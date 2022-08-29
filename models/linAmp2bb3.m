function [xx,y1,h1]=linAmp2bb3(x,t,sol_args,u,data,tbias)
% Usage ... [xnew,yest,h1]=linAmp2bb3(x,t,sol_args,u,data,tbias_or_ww)
%
% Similar to linAmp1 but different approach. This version uses HRF
% and determines a constrained input waveform to best fit the data
% It uses the myfoh function where the arguments for it go in foh_args
% cbeta is the roughness penalty
% foh_args={t_foh,i_est,i_fix,y_fix}
%
% Ex. tt=[-3:0.2:12]; tt_iv=find((tt>=0)&(tt<4)); tt_if=find((tt<0)|(tt>=4));
%     [x1,y1_est,u1]=linAmp2(ones(length(tt_iv)+1,1),t1,{tt,tt_iv,tt_if},y1);

if isempty(t), t=[1:length(u)]; t=t(:); end;
if nargin<6, tbias=[t(1) t(end)]; end;
for mm=1:length(tbias), ibias(mm)=find(t>=tbias(mm),1); end;

% sol parameters
nhrf=sol_args(1);
ntop=sol_args(2);
nbot=sol_args(3);

if length(u)==prod(size(u)), u=u(:); end;
for mm=1:size(u,2), uu(:,mm)=u(:,mm)/sum(u(:,mm)); end;

xopt=optimset('lsqnonlin');
xopt.TolxFun=1e-10;
xopt.TolX=1e-8;

% find scaling factors if x is empty
if isempty(x),
  x=[100 ones(1,nhrf) 2*rand(1,nhrf*ntop) rand(1,nhrf*nbot)+0.5];
end;

x0=x;
xlb=[ 0   -1e2*ones(1,nhrf) -1*ones(1,nhrf*ntop) +1e-6*zeros(1,nhrf*nbot)];
xub=[+1e4 +1e2*ones(1,nhrf) +1*ones(1,nhrf*ntop) +1*ones(1,nhrf*nbot)];

if nargin>4,
  xx=lsqnonlin(@linAmp2_wrap,x0,xlb,xub,xopt,t,sol_args,uu,data,ibias);
else,
  xx=x;
end;

[y0,h0]=linAmp2_wrap(x0,t,sol_args,uu);
[y1,h1]=linAmp2_wrap(xx,t,sol_args,uu);

if nargout==1,
  yout.x0=x0;
  yout.h0=h0;
  yout.y0=y0;
  yout.xlb=xlb;
  yout.xub=xub;
  yout.sol_args=sol_args;
  yout.tt=t;
  yout.u0=u;
  yout.xx=xx;
  yout.uu=uu;
  yout.hh=h1;
  yout.yf=y1;
  yout.yy=data;
  yout.tbias=tbias;
  yout.ee=mean((data-y1).^2);
  yout.r=corr(data,y1);

  xx=yout;
end;

if nargout==0,
  clf,
  if ~exist('data','var'),
    plot(t,y0,t,y1,t,uu,t,h1)
    axis tight, grid on, legend('est0','est-new'),
  else,
    plot(t,data,t,y0,t,y1,t,h0,t,h1)
    axis tight, grid on, legend('data','est0','est-new'),
  end;
  ylabel('Amplitude'), xlabel('Time'),
  set(gca,'FontSize',12), dofontsize(15);
end;


% sub-function defitions
function [y,hh]=linAmp2_wrap(x,t,sol_args,uu,data,ibias)
  n_hrf=sol_args(1);
  n_top=sol_args(2);
  n_bot=sol_args(3);
  n_uu=size(uu,2);
  
  yest=zeros(size(uu(:,1)));
  for mm=1:n_hrf,
    tmptop=1;
    if n_top>0,
      for nn=1:n_top, tmptop=conv(tmptop,[1 x(1+n_hrf+(mm-1)*n_top+nn)]); end;
    end;
    tmpbot=1;
    if n_bot>0,
      for nn=1:n_bot, tmpbot=conv(tmpbot,[1 x(1+n_hrf+n_top*n_hrf+(mm-1)*n_bot+nn)]); end;
    end;
    %if nargin<=4, n_hrf, n_top, n_bot, tmptop, tmpbot, end;

    u1=zeros(size(uu(:,1))); u1(1)=1;
    hh(:,mm)=mysol(tmptop,tmpbot,u1(:),t);
    % this might need to be x(mm+1) below
    if n_uu==1,
      yest=yest+x(mm+1)*myconv(uu(:),hh(:,mm));
    elseif (n_hrf==1)&(n_uu>1),
      for nn=2:n_uu, yest=yest+x(mm+1)*myconv(uu(:,nn),hh(:,1)); end;
    else,
      yest=yest+x(mm+1)*myconv(uu(:,mm),hh(:,mm));
    end; 
  end;
  yest=yest*x(1);
  y=yest;
    
  if nargin>4,
    y=yest-data;
    if length(ibias)==2, 
      ibias=[ibias(1):ibias(2)]; 
    elseif length(ibias)==length(data),
      ibias=find(ibias);
    end;
    y=y(ibias);
    disp(sprintf('  mse=%.3f, x=[%.2f %.2f %.2f %.2f %.2f]',mean(y.^2),x(1),x(2),x(3),x(4),x(5)));
  end;
return

