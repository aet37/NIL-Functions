%% start clean
%
clear all
close all

fit_type=1;
fun_type=1;

parms2fit=[1 2 3 4];

% single gamma function
t0=1.2;
a=2.5;
b=0.8;
amp=1;


tt=[-5:0.1:32];
tt=tt(:);

% simple single gamma function
x1=[t0 a b amp];
y1=this_gamma([],tt,[],x1);
y1=y1+0.05*randn(size(y1));


%% test shapes
%
if 0,

if fun_type==1,
  x0_orig=[t0 a b amp];
  tmpa=[1.5:0.5:3.5];
  tmpb=[0.4:0.2:1.2];
  tmpt0=[0:0.5:3.0];
  tmpm=[0.5:0.2:1.1];
else,
  x0_orig=[1.2 2.5 5.5 1];
  tmpa=[1.5:0.5:3.5];
  tmpb=[1.0:1.5:7.0];
  tmpt0=[0:0.5:3.0];
  tmpm=[0.5:0.2:1.1];
end
x0=x0_orig;

for oo=1:length(tmpa),
    x0(2)=tmpa(oo);
    y0a(:,oo)=this_gamma([],tt,[],x0);
end
x0=x0_orig;
for oo=1:length(tmpb),
    x0(3)=tmpb(oo);
    y0b(:,oo)=this_gamma([],tt,[],x0);
end
x0=x0_orig;
for oo=1:length(tmpt0),
    x0(1)=tmpt0(oo);
    y0t(:,oo)=this_gamma([],tt,[],x0);
end
x0=x0_orig;
for oo=1:length(tmpm),
    x0(4)=tmpm(oo);
    y0m(:,oo)=this_gamma([],tt,[],x0);
end
x0=x0_orig;
for oo=1:length(tmpb),
    x0(2)=tmpa(oo); x0(3)=tmpb(oo);
    y0ab(:,oo)=this_gamma([],tt,[],x0);
end
x0=x0_orig;
for oo=1:length(tmpb),
    x0(2)=tmpa(oo); x0(3)=tmpb(length(tmpb)-oo+1);
    y0ba(:,oo)=this_gamma([],tt,[],x0);
end

figure(1), clf,
subplot(231), plot(tt,y0a), axis tight, grid on, fatlines(1);
xlabel('Time (s)'), ylabel('Amplitude'), title('alpha'),
subplot(232), plot(tt,y0b), axis tight, grid on, fatlines(1);
xlabel('Time (s)'), ylabel('Amplitude'), title('beta'),
subplot(233), plot(tt,y0t), axis tight, grid on, fatlines(1);
xlabel('Time (s)'), ylabel('Amplitude'), title('delay'),
subplot(234), plot(tt,y0m), axis tight, grid on, fatlines(1);
xlabel('Time (s)'), ylabel('Amplitude'), title('amplitude'),
subplot(235), plot(tt,y0ab), axis tight, grid on, fatlines(1);
xlabel('Time (s)'), ylabel('Amplitude'), title('a b increasing'),
subplot(236), plot(tt,y0ba), axis tight, grid on, fatlines(1);
xlabel('Time (s)'), ylabel('Amplitude'), title('a incr b decr'),


spm_hrf=this_gamma([],tt,[],[0 5 0.8 1])-0.2*this_gamma([],tt,[],[0 5 0.4 1]);
spm_hrf=spm_hrf/sqrt(sum(spm_hrf.^2));
spm_hrf_d=[diff(spm_hrf); 0];
spm_hrf_d2=[diff(spm_hrf_d); 0];

figure(2), clf,
subplot(211),
%plot(tt,this_gamma([],tt,[],[0 7.0 1.2 1]),tt,this_gamma([],tt,[],[0 7.0 0.6 1]),tt,this_gamma([],tt,[],[0 7.0 1.8 1]))
plot(tt,spm_hrf), axis tight, grid on, fatlines(1), 
ylabel('Amplitude (au; \DeltaS/S_0)'), xlabel('Time (s)'), set(gca,'FontSize',12), dofontsize(16);
subplot(212),
plot(tt,[spm_hrf/max(spm_hrf) spm_hrf_d/max(spm_hrf_d) spm_hrf_d2/max(spm_hrf_d2)]), axis tight, grid on, fatlines(1), 
legend('HRF','Derivative','Dispersion'),
ylabel('Amplitude (au; \DeltaS/S_0)'), xlabel('Time (s)'), set(gca,'FontSize',12), dofontsize(16);

pause, 
%return,

end

%% test optimization for single gamma function
%
if 0,
    
niter=20;

for oo=1:niter,
    x1g=abs(randn(1,4));
    y1g=this_gamma([],tt,[],x1g);
    x1gg(oo,:)=x1g;
    y1gg(:,oo)=y1g;

    %plot(tt,y1,tt,y1g,'LineWidth',1.5),
    %axis tight, grid on, set(gca,'FontSize',12);
    %drawnow, pause(0.1),

    x1fit=this_gamma_fit(x1,parms2fit,x1,tt,y1,fit_type);
    y1fit=this_gamma(x1fit,tt,parms2fit,x1);  
    x1gg_fit(oo,:)=x1fit;
    y1gg_fit(:,oo)=y1fit;
    
    %this_gamma([],tt,[],x1fit,y1), drawnow, 
    %[x1g; x1; x1fit],
    %pause(0.1),
end

e1gg_fit=sqrt(sum((y1*ones(1,niter)-y1gg_fit).^2,1))/std(y1);
e1xg_fit=sqrt(sum((x1gg_fit'./(x1(parms2fit)'*ones(1,niter))).^2,1));

figure(2), clf,
subplot(211), plot(tt,y1,tt,y1gg_fit), axis tight, grid on, 
subplot(212), plot(e1gg_fit,e1xg_fit,'x'), drawnow,
xlabel('Fit MSE'), ylabel('Model MSE'), 

pause,

end


%% test optimization for double gamma function
%

x2=[1.2 2.5 0.8 1 0 5 0.4 0.3];
y2=this_gamma([],tt,[],x2);
y2=y2+0.05*randn(size(y2));


if 1,
niter=20;
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
      tmpy1=tmpy;
      tmpy=amp*tmpy/max(tmpy);
      
      %tmpjb(ii,(mm-1)*4+1)=
      %tmpjb(ii,(mm-1)*4+2)=
      %tmpjb(ii,(mm-1)*4+3)=
      %tmpjb(ii,(mm-1)*4+4)=tmpy1;
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


