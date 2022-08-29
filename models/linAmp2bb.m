function [xx,y1,u1]=linAmp2b(x,t,foh_args,hrf,data,cbeta,tbias)
% Usage ... [xnew,yest,uu1]=linAmp2b(x,t,foh_args,hrf,data,cbeta,tbias_or_ww)
%
% Similar to linAmp1 but different approach. This version uses HRF
% and determines a constrained input waveform to best fit the data
% It uses the myfoh function where the arguments for it go in foh_args
% cbeta is the roughness penalty
% foh_args={t_foh,i_est,i_fix,y_fix}
%
% Ex. tt=[-3:0.2:12]; tt_iv=find((tt>=0)&(tt<4)); tt_if=find((tt<0)|(tt>=4));
%     [x1,y1_est,u1]=linAmp2(ones(length(tt_iv)+1,1),t1,{tt,tt_iv,tt_if},y1);

if ~exist('cbeta','var'), cbeta=0; end;
if isempty(t), t=[1:length(hrf)]; t=t(:); end;
if nargin<7, tbias=[t(1) t(end)]; end;
for mm=1:length(tbias), ibias(mm)=find(t>=tbias(mm),1); end;

% foh parameters
ttfoh=foh_args{1};
ttfoh_iv=foh_args{2};
ttfoh_if=foh_args{3};

xopt=optimset('lsqnonlin');
xopt.TolxFun=1e-10;
xopt.TolX=1e-8;


% find scaling factors if x is empty
xlen1=length(ttfoh_iv);
if isempty(x),
  x=[1 2*rand(1,xlen1*size(hrf,2))];
end;

x0=ones(size(x));
xlb=[ 0    -1*ones(1,xlen1*size(hrf,2))];
xub=[+1e4  +1*ones(1,xlen1*size(hrf,2))];

if nargin>4,
  xx=lsqnonlin(@linAmp2_wrap,x0,xlb,xub,xopt,t,foh_args,hrf,data,cbeta,ibias);
else,
  xx=x;
end;

[y0,u0]=linAmp2_wrap(x0,t,foh_args,hrf);
[y1,u1]=linAmp2_wrap(xx,t,foh_args,hrf);

if nargout==0,
  clf,
  if ~exist('data','var'),
    plot(t,y0,t,y1,t,u0,t,u1)
    axis tight, grid on, legend('est0','est-new'),
  else,
    plot(t,data,t,y0,t,y1,t,u0,t,u1)
    axis tight, grid on, legend('data','est0','est-new'),
  end;
  ylabel('Amplitude'), xlabel('Time'),
  set(gca,'FontSize',12), dofontsize(15);
end;


% sub-function defitions
function [y,u,uu]=linAmp2_wrap(x,t,foh_args,hrf,data,cbeta,ibias)
  ttfoh=foh_args{1};
  ttfoh_iv=foh_args{2};
  ttfoh_if=foh_args{3};
  xlen1=length(ttfoh_iv);
  
  yest=zeros(size(hrf(:,1)));
  for mm=1:size(hrf,2),
    u(:,mm)=myfoh(ttfoh,ttfoh_iv,x(1+[1:xlen1]+(mm-1)*xlen1),ttfoh_if,0,t); 
    uu(:,mm)=u(:,mm)/sum(u(:,mm));
    yest=yest+x(1)*myconv(uu(:,mm),hrf(:,mm));
    y=yest;
  end;
  
  if nargin<6, cbeta=0; end;
  if abs(cbeta)>100*eps, do_penalty=1; else, do_penalty=0; end;
  
  if nargin>4,
    y=yest-data;
    if do_penalty,
      beta=cbeta;    % 2e-3
      cpen=0;
      for mm=1:size(hrf,2), cpen=cpen+abs(diff(x(1+[1:xlen1]+(mm-1)*xlen1))); end;      
      y=y.^2+beta*mean(cpen)*size(hrf,2);
    end;
    if length(ibias)==2, 
      ibias=[ibias(1):ibias(2)]; 
    elseif length(ibias)==length(data),
      ibias=find(ibias);
    end;
    y=y(ibias);
    disp(sprintf('  mse=%.3f, x=[%.2f %.2f %.2f %.2f %.2f %.2f]',mean(y.^2),x(1),x(2),x(3),x(4),x(5),x(6)));
  end;
return

