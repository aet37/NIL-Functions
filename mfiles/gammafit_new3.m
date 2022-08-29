function y=gammafit_new3(xx0,parms2fit,tt,uu,otherparms,yy,ibias)
% Usage ... y=gammafit_new3(x0,parms2fit,uu,fit_parms,t,data,ibias))
%
% Estimates the best fit of data using a gamma function. Options include
% random or standard guess initialization, fit type, 

if ~exist('uu','var'), uu=[]; end;
if ~exist('tt','var'), tt=[]; end;
if ~exist('parms2fit','var'), parms2fit=[]; end;

if isempty(parms2fit), parms2fit=[1:length(xx0)]; end;
if isempty(tt), tt=[0:length(uu)-1]; end;

% single gamma function
t0=1.2; a=2.5; b=0.8; amp=1;

if isempty(xx0), 
    xx0=[1.2 2.5 0.8 1]; 
    %xx0=[1.2 2.5 0.8 1 0 5 0.4 -0.3 0 8 0.4 +0.1]; 
end;
ngg=floor(length(xx0)/4);

if ~exist('otherparms','var'), otherparms=[]; end;
if isempty(otherparms), otherparms=[1 1 1]; end;

fit_type=otherparms(1);
init_type=otherparms(2);
fun_type=otherparms(3);

niter=20;

tt=tt(:);

y0=this_gamma(xx0,tt,[],x2);
%y0=y0+xx0(4)*0.05*randn(size(y0));


if 1,
parms2fit=[1 2 3 4 6 7 8]; 
parms2notfit=i2i(1:8,'notin',parms2fit);
clear x2gg*

for oo=1:niter,
    % lets try several things
    % 1- single fit routine with random initial guess (did not work)
    % 2- adjusted single fit routine with guided initial guess (did not work either)
    % 3- random initial guess then fit single gamma model, then fit the full model
    %     this one worked
    
    %x2g=x2+0.1*randn(1,8);
    %%x2g([1 5])=x2g([1 5])*2;
    %x2g([2 6])=x2g([2 6])+randn(1,2)*0.2;
    %%x2g([3 7])=x2g([3 7])*2;
    %x2g([4 8])=x2g([4 8])+randn(1,2)*0.1;

    x2g=abs(randn(1,8));
    %x2g([2 6])=x2g([2 6])*1;
    %x2g([3 7])=x2g([3 7])/3;
    
    if ~isempty(parms2notfit), x2g(parms2notfit)=x2(parms2notfit); end; 
    y2g=this_gamma([],tt,[],x2g);
    x2gg(oo,:)=x2g;
    y2gg(:,oo)=y2g;
    
    %plot(tt,y2,tt,y2g,'LineWidth',1.5),
    %axis tight, grid on, set(gca,'FontSize',12);
    %drawnow, %pause(0.2),

    % two tier fit- use single gamma first
    x2fit1=this_gamma_fit(x2g(1:4),[1:4],x2g(1:4),tt,y2,fit_type);
    y2fit1=this_gamma(x2fit1,tt,[1:4],x2);
    
    % adjuse initial guess using this result and set constraint for second gamma
    x2g(1:4)=x2fit1;
    x2g(5:8)=x2g(5:8)+x2fit1;
    x2g(5)=0; if x2g(7)<0.1, x2g(7)=0.1; elseif x2g(7)>x2g(3), x2g(7)=x2g(3)/2; end;
    
    % fit the full model
    x2fit=this_gamma_fit(x2g(parms2fit),parms2fit,x2g,tt,y2,fit_type);
    y2fit=this_gamma(x2fit,tt,parms2fit,x2g);
    x2fit2=x2g; x2fit2(parms2fit)=x2fit;
    x2gg_fit(oo,:)=x2fit2;
    y2gg_fit(:,oo)=y2fit;
    
    %this_gamma([],tt,[],x2fit,y2), drawnow, 
    %[x2g(parms2fit); x2(parms2fit); x2fit],
    %pause(0.2),
    
    plot(tt,y2,tt,y2fit,tt,y2fit1), axis tight, grid on, drawnow, pause(0.2),

end

e2gg_fit=sqrt(sum((y2*ones(1,niter)-y2gg_fit).^2,1))/std(y2);
e2xg_fit=sqrt(sum((x2gg_fit(:,parms2fit)'-(x2(parms2fit)'*ones(1,niter))).^2,1));

figure(3), clf,
subplot(211), plot(tt,y2,tt,y2gg_fit), axis tight, grid on, 
subplot(212), plot(e2gg_fit,e2xg_fit,'x'), drawnow,
xlabel('Fit MSE'), ylabel('Model MSE (%)'),
%pause,

x2gg_fit,

end








%% function definitions
%

function [xx,yy]=this_gamma_fit(parms,parms2fit,allparms,t,data,fit_type)

  % fitting routine
  if fit_type==2,
    xopt=optimset('fminsearch');
    xopt.TolxFun=1e-10;
    xopt.TolX=1e-8;

    xx=fminsearch(@this_gamma,parms,xopt,t,parms2fit,allparms,data,fit_type);
    y2=this_gamma([],t,[],xx);
    pp=polyfit(y2,data,1);
    xx(4)=xx(4)*pp(1);
    yy=this_gamma([],t,[],xx);
  
  else,
    xopt=optimset('lsqnonlin');
    xopt.TolFun=1e-10;
    xopt.TolX=1e-8;
    %xopt.Algorithm='levenberg-marquardt';
    %xopt.Jacobian='true';

    xlb=[0  1e-3 1e-3 1e-4];
    xub=[3  10   10   +1];
    if length(allparms)>4,
        xlb=xlb'*ones(1,floor(length(allparms))/4); xlb=xlb(:)';
        xub=xub'*ones(1,floor(length(allparms))/4); xub=xub(:)';
        xub(8:4:end)=1;
    end
    
    xx=lsqnonlin(@this_gamma,parms,xlb(parms2fit),xub(parms2fit),xopt,t,parms2fit,allparms,data,fit_type);
    %xx=lsqnonlin(@this_gamma,parms,xlb,xub,xopt,t,parms2fit,allparms,data,fit_type);
    yy=this_gamma([],t,[],xx);

  end
  
end


function [y,jb]=this_gamma(parms,t,parms2fit,allparms,data,fit_type)
  fun_type=1;
  do_jacobian=0;
  
  if nargin<6, fit_type=1; end;
  allparms_orig=allparms;
  if ~isempty(parms2fit), allparms(parms2fit)=parms; end;
  y=zeros(size(t));
  tmpy=y;
  
  % a must be >1 and b small is good
  for mm=1:floor(length(allparms)/4),
    t0=allparms((mm-1)*4 + 1); 
    a=allparms((mm-1)*4 + 2); 
    b=allparms((mm-1)*4 + 3); 
    amp=allparms((mm-1)*4 + 4);
    if mm>1,
      t0=t0+allparms(1);
      amp=amp*allparms(4);
      amp=amp*((-1)^(mm-1));
    end
    ii=find(t>=t0);
    if fun_type==2,
      a=a-1;
      tmpaa=8*log(2)*a*a/(b*b);
      tmpbb=b*b/(8*log(2)*a);
      tmpy(ii)=(t(ii)-t0)/a;
      tmpy(ii)=(t(ii)-t0).^(tmpaa/a);
      tmpy(ii)=tmpy(ii).*exp(-(t(ii)-t0-tmpaa)/tmpbb);
      tmpy=amp*tmpy/max(tmpy);
    else
      tmpy(ii)=(t(ii)-t0).^(a-1);
      tmpy(ii)=tmpy(ii)*(b^(a));
      tmpy(ii)=tmpy(ii).*exp(-b*(t(ii)-t0));
      tmpy=amp*tmpy/max(tmpy);
      
      %tmpjb(ii,(mm-1)*4+1)=
      %tmpjb(ii,(mm-1)*4+2)=
      %tmpjb(ii,(mm-1)*4+3)=
      %tmpjb(ii,(mm-1)*4+4)=
    end
    
    y = y + tmpy;
  end
  %keyboard,
  
  if nargin>4,
    y_orig=y;
    do_figure=0;
    if fit_type==2, 
        y = 1 - corr(y_orig, data).^2; 
    else
        y = y_orig - data;
        y = y/std(y_orig);
    end;
    disp(sprintf('[%.3f (%.3f)]',sqrt(sum(y.^2)),std(y_orig)));
    if nargout==0, do_figure=1; end;
    
    if do_figure,
      %allparms,
      plot(t,y_orig,t,data,t,y,'LineWidth',1), axis tight, grid on, 
      set(gca,'FontSize',12);
      legend('fit','data',sprintf('error (r2=%.3f)',corr(y_orig,data))), drawnow,
      %legend('data','fit',sprintf('error (r2=%.3f)',y-1)), drawnow,
      clear y
      %pause,
    end
  end
  
end


