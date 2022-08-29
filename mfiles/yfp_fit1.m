function [y1,y1w]=yfp_fit1(x0g,extra_parms,parms2fit,data)
% Usage ... [y,yw]=yfp_fit1(x,extra_parms,parms2fit,data)
%
% extra-parms = [xdim ydim wrap_factor x0approx y0approx]
% fit parameters x = [x0 y0 ang ww amp xscale yscale]
%
% ex. yfp_fit1([0 0 -5 40 5 1 1.5],[size(im1) 4 120 140],[1 2 4],im1*100)

fit_type=2;

if fit_type==2,
  xopt=optimset('fminsearch');
  xopt.TolFun=1e-10;
  xopt.TolX=1e-8;
else,
  xopt=optimset('lsqnonlin');
  xopt.TolFun=1e-10;
  xopt.TolX=1e-8;
  %xopt.Algorithm='levenberg-marquardt';
  %xopt.Jacobian='true';
end;

x0= [ 0  0   0  10   5.5 1   1];
xlb=[-5 -5 -90  1e-3  0  0.2 0.2];
xub=[+5 +5 +90  3e+2  20 10  10];

[y0w,y0]=yfpArtifact1([],extra_parms,x0g);

if nargin==2,
    y=y0;
else,
    figure(1), clf,
    subplot(321), show(data),
    subplot(322), show(y0w),
    subplot(323), show(data-y0w),
    subplot(324), show(y0),
    subplot(313), plot([data(x0g(1)+extra_parms(4),:)' data(:,x0g(2)+extra_parms(5)) ...
                        y0w(x0g(1)+extra_parms(4),:)' y0w(:,x0g(2)+extra_parms(5))]),
    
    pause,
    
    %yfpArtifact1(x0g(parms2fit),extra_parms,x0g,parms2fit);
    %pause,
    if fit_type==2,
      xx1=fminsearch(@yfpArtifact1,x0g(parms2fit),xopt,extra_parms,x0g,parms2fit,data);        
    else,
      xx1=lsqnonlin(@yfpArtifact1,x0g(parms2fit),xlb(parms2fit),xub(parms2fit),xopt,extra_parms,x0g,parms2fit,data);
    end
    
    xx1,
    x1=x0g; x1(parms2fit)=xx1;
    [y1w,y1]=yfpArtifact1(xx1,extra_parms,x0g,parms2fit);

    
    figure(2), clf,
    subplot(221), show(data),
    subplot(222), show(y1w),
    subplot(223), show(data-y1w),
    subplot(224), show(y1),    
    subplot(313), plot([data(x1(1)+extra_parms(4),:)' data(:,x1(2)+extra_parms(5)) ...
                        y1(x1(1)+extra_parms(4),:)' y1(:,x1(2)+extra_parms(4))]),
                    
end

