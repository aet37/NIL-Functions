function y=calcDiam1(im,loc,rad,rot,subSz,invflag,nkeep)
% Usage ... y=calcDiam1(im,loc,rad,rot,subSize,invflag,nkeep)
%
% Mesaure vessel diameter by fitting an ellipse to an image
% im is the image or stack, loc is [r0,c0] center location
% subSz is the FOV-span in pixels or fraction
% invflag is whether the vessel is dark (1) or bright (0)
% nkeep is the components to keep if extracting many

do_figure=1;
fit_type=1;

if isempty(rot), rot=0; end;
if isempty(subSz), subSz=0.2; end;
if ~exist('invflag','var'), invflag=[]; end;
if ~exist('nkeep','var'), nkeep=0; end;

im=squeeze(im);
imsz=size(im);

do_many=0;
if length(imsz)>=3, do_many=1; end;

if subSz<1,
  subSz1=ceil(imsz*subSz);
else,
  subSz1=subSz;
end;
loc0=round(subSz1/2);
r0=0.1*subSz1(1);
w0=1;
sc0=1;
rot0=0;
amp0=1;
b0=0;

if ischar(loc), if strcmp(loc,'select'),
  if do_many,
    imS=mean(im,3);
  else,
    imS=im;
  end;
  tmpok=0;
  while(~tmpok),
    figure(1), clf,
    show(imS), xlabel('click on desired vessel'), drawnow,
    tmploc=ginput(1);
    tmploc2=round(tmploc(1)); tmploc1=round(tmploc(2));
    tmpmask=zeros(size(imS));
    tmpmask(tmploc1,tmploc2)=1;
    im_overlay4(imS,tmpmask);
    tmpin=input('  location ok? [0=no, 1/enter=yes]: ');
    if isempty(tmpin), tmpok=1; end;
    if tmpin>0, tmpok=1; end;
  end;
  loc=[tmploc1 tmploc2];
  clear imS
end; end;

tmpi1=floor([0:subSz1(1)-1]-subSz1(1)/2)+loc(1);
tmpi2=floor([0:subSz1(2)-1]-subSz1(2)/2)+loc(2);
tmpi1=tmpi1(find((tmpi1>=1)&(tmpi1<=imsz(1))));
tmpi2=tmpi2(find((tmpi2>=1)&(tmpi2<=imsz(2))));


parms=[loc0 r0 w0 sc0 rot0 amp0 b0];
parms2fit=[1 2 3 4 5 6 7 8];
%parms2fit=[1 2 3 4 7 8];
% first figure out the center
% then fit everything else

x0=parms;
xlb=[1 1 0.1 0.1 1 -179 1e-2 0];
xub=[subSz1(1) subSz1(2) subSz1(1)/2 0.2*subSz1(1) 4 180 1e6 1e6];

if fit_type>=2,
  xopt=optimset('fminsearch');
  xopt.TolxFun=1e-10;
  xopt.TolX=1e-8;
else,
  xopt=optimset('lsqnonlin');
  xopt.TolxFun=1e-10;
  xopt.TolX=1e-8;
end;


if do_many,
  im_avg=mean(im,3);
  im1=double(im_avg(tmpi1,tmpi2));
  im1c=circlefit1([],x0,[],subSz1,invflag);

  if do_figure,
    figure(1), clf,
    subplot(221), show(im),
    subplot(222), show(im1),
    subplot(224), show(im1c),
    disp('  press enter to continue...');
    pause;
  end;
 
  if fit_type>=2,
    xx=fminsearch(@circlefit1,x0,xopt,parms,parms2fit,subSz1,invflag,im1);
  else,
    xx=lsqnonlin(@circlefit1,x0(parms2fit),xlb(parms2fit),xub(parms2fit),xopt,parms,parms2fit,subSz1,invflag,im1);
  end;

  im1f=circlefit1(xx,parms,parms2fit,subSz1,invflag);
  rr=corr(im1(:),im1f(:));

  if do_figure,
    figure(1), clf,
    subplot(221), show(im1),
    subplot(222), show(im1f),
    subplot(223), plot([1:subSz1(1)],[im1(:,round(xx(2)))  im1f(:,round(xx(2)))]), axis tight, grid on,
    subplot(224), plot([1:subSz1(2)],[im1(round(xx(1)),:)' im1f(round(xx(1)),:)']), axis tight, grid on,
    disp('  press enter to continue to fit all...');
    pause;
 end;

  % filter and fit data
  if nkeep,
    im2=pcaimdenoise(double(im(tmpi1,tmpi2,:)),60,0,1);
  else,
    im2=double(im(tmpi1,tmpi2,:));
  end;
  % can also do radon transform
  % and simplify parameter space based on average result
  for nn=1:size(im2,3),
    im2_1=im2(:,:,nn);
    if fit_type>=2,
      xx2(nn,:)=fminsearch(@circlefit1,x0,xopt,parms,parms2fit,subSz1,invflag,im2_1);
    else,
      xx2(nn,:)=lsqnonlin(@circlefit1,x0(parms2fit),xlb(parms2fit),xub(parms2fit),xopt,parms,parms2fit,subSz1,invflag,im2_1);
    end;
    im2f=circlefit1(xx2(nn,:),parms,parms2fit,subSz1,invflag);
    rr2(nn)=corr(im2_1(:),im2f(:));
  end;
  clear im2
  
else,   
  im1=double(im(tmpi1,tmpi2));
  im1c=circlefit1([],x0,[],subSz1,invflag);

  if do_figure,
    figure(1), clf,
    subplot(221), show(im),
    subplot(222), show(im1),
    subplot(224), show(im1c),
    disp('  press enter to continue...');
    pause;
  end;
 
  if fit_type>=2,
    xx=fminsearch(@circlefit1,x0,xopt,parms,parms2fit,subSz1,invflag,im1);
  else,
    xx=lsqnonlin(@circlefit1,x0(parms2fit),xlb(parms2fit),xub(parms2fit),xopt,parms,parms2fit,subSz1,invflag,im1);
  end;

  im1f=circlefit1(xx,parms,parms2fit,subSz1,invflag);
  rr=corr(im1(:),im1f(:));

  if do_figure,
    figure(1), clf,
    subplot(221), show(im1),
    subplot(222), show(im1f),
    subplot(223), plot([1:subSz1(1)],[im1(:,round(xx(2)))  im1f(:,round(xx(2)))]), axis tight, grid on,
    subplot(224), plot([1:subSz1(2)],[im1(round(xx(1)),:)' im1f(round(xx(1)),:)']), axis tight, grid on,
  end;
  
end;


y.x0=x0;
y.invflag=invflag;
y.xlb=xlb;
y.xub=xub;
y.ii1=tmpi1;
y.jj1=tmpi2;
y.im1=im1;
y.im1c=im1c;
y.im1f=im1f;
y.xx=xx;
y.rr=rr;
if do_many,
  y.xx1=y.xx;
  y.xx=xx2;
  y.rr1=y.rr;
  y.rr=rr2;
  y.nkeep=nkeep;
end;

end

%% internal functions
%
function [x,im1]=circlefit1(x,parms,parms2fit,datasz,invflag,data)
  do_fig=0;
  if isempty(invflag), invflag=0; end;
  if ~isempty(parms2fit),
    parms(parms2fit)=x;
  end;
  loc1(1)=parms(1);
  loc1(2)=parms(2);
  rad1=parms(3);
  wid1=parms(4);
  sc1=parms(5);
  rot1=parms(6);
  amp1=parms(7);
  bas1=parms(8);
  
  %datasz, loc1, [rad1 wid1, 1, sc1, rot1]
  im1=double(fermi2d_obj(datasz,loc1,rad1,wid1,1,sc1,rot1));
  if invflag, im1=bas1-amp1*im1; else, im1=bas1+amp1*im1; end;
  
  if nargin>5,
    x=data(:)-im1(:);
    x_mse=sqrt(mean(x(:).^2));
    disp(sprintf('  mse=%.3e: loc=[%.2f,%.2f], r=%.2f, w=%.2f,sc=%.2f,rot=%.2f,amp=%.3f,bb=%.2f',...
        x_mse,loc1(1),loc1(2),rad1,wid1,sc1,rot1,amp1,bas1));
    if do_fig,
      subplot(221), show(data),
      subplot(222), show(im1)
      subplot(223), plot([data(round(loc1(1)),:)' im1(round(loc1(1)),:)']), axis tight, grid on,
      subplot(224), plot([data(:,round(loc1(2)))  im1(:,round(loc1(2)))]), axis tight, grid on,
      drawnow,
    end;
  else,
    x=im1;
  end;
end
