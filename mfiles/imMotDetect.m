function [y,y2,mask,y3]=imMotDetect(im,refim,parms,mask,filterco,minmaxthr)
% Usage ... [x,yc]=imMotDetect(im,refim,parms,mask,filterco,minmaxthr)
%
% motion detection and correction function
% parms = [opt_method max_mot_frac norm_type smoothwid invert_flag]
% opt_method = 1:search, 2: LevMar
% max_mot_frac = maximum expected motion (or upsample scale factor for opt_method=4)
% norm_types = 0:no_norm, 1:min-max, 2:gradient
% ex. [xx_mc,stk_mc]=imMotDetect(stk,1,[4 20 0 1 0]);
%     [xx_mc,stk_mc]=imMotDetect(stk,1,[3 0.3 1 0.4 0]);


% 2D motion detection in 2 directions, but
%   warping not implemented yet
%   todo: thresholding, initial_guess option
%         invert image, smooth, high-pass filter, homocorOIS

if isstr(im), do_load=1; else, do_load=0; end;
if ~exist('mask','var'), mask=[]; end;
if ~exist('parms','var'), parms=[]; end;
if ~exist('filterco','var'), filterco=[]; end;
if ~exist('minmaxthr','var'), minmaxthr=[]; end;

im=squeeze(im);

do_output=0;
if nargout>1, do_output=1; end;

do_excludeEdge=3;

if isempty(parms),
  % default: search, 33% max, minmax intensity norm
  %parms=[1 0.33 1 0];
  %parms=[4 20 0 1 0]
  parms=[0 0 2 2 0];
end;
if length(parms)==3,
  parms(4)=2; parms(5)=0;
end;

if isempty(filterco),
  do_filter=0;
else,
  do_filter=1;
end;

if isempty(minmaxthr),
  do_thr=0;
else,
  if strcmp(minmaxthr,'select'),
    do_thr=2;
  else,
    do_thr=1;
  end;
end;

optmethod=parms(1);
area_fraction=parms(2);
norm_type=parms(3);
smooth_wid=parms(4);
invert_flag=parms(5);

if optmethod==2,
  xopt=optimset('lsqnonlin');
elseif optmethod==3,
  xopt=optimset('fminbnd');
else,
  xopt=optimset('fminsearch');
end;
xopt.TolX=1e-8;
xopt.TolFun=1e-8;

if do_load,
  tmpim=readOIS3(im,2);
  tmpref=readOIS3(im,refim(1));
  imdim=size(im);
  if length(refim)==2,
    imdim(3)=refim(2);
    tmptmp=refim(1);
    refim=tmptmp;
  else,
    imdim(3)=1e6;
  end;
  refim=tmpref;
else,
  imdim=size(im);
end;
if length(imdim)==2, imdim(3)=1; end;

x0=[0 0];
xlb=-imdim(1:2)*area_fraction;
xub=+imdim(1:2)*area_fraction;

do_refdiff=0;
if length(refim)==1,
  if refim==-1, do_refdiff=1; refim=1; end;
  refim=double(im(:,:,refim));
end;

if isempty(mask),
  mask=ones(imdim(1:2));
else,
  if strcmp(mask,'select'),
    found=0;
    while(~found),
      clf, show(refim),
      disp('  select mask...');
      mask=roipoly;
      show(im_super(refim,mask,0.3)),
      found=input('  selection ok? [0:no, 1:yes]: ');
    end; 
  elseif length(mask)==4,
    tmpmask=zeros(size(refim));
    tmpmask(mask(1):mask(2),mask(3):mask(4))=1;
    clear mask
    mask=tmpmask;
  end;
end;
if (optmethod==0)|(optmethod==4),
  [mski,mskj]=find(mask);
  cropii=[min(mski) max(mski) min(mskj) max(mskj)];
  if (do_excludeEdge>0.1),
    exc_ii=do_excludeEdge;
    mask(1:exc_ii,:)=0; mask(:,1:exc_ii)=0;
    mask(end-exc_ii-1:end,:)=0; mask(:,end-exc_ii-1:end)=0;
    [mski,mskj]=find(mask);
    cropii=[min(mski) max(mski) min(mskj) max(mskj)];  
  end;
  mask=zeros(size(mask));
  mask(cropii(1):cropii(2),cropii(3):cropii(4))=1;
  disp(sprintf('  mask area= %d %d %d %d',cropii(1),cropii(2),cropii(3),cropii(4)));
end;
maski=find(mask);

im1=double(refim);
cm1=imCenterMass(im1,mask);
y2=zeros(size(im));
for mm=1:imdim(3),
  if do_load,
    im2=readOIS3(im,mm);
    if isempty(im2), imdim(3)=mm-1; break; end;
  else,
    im2=double(im(:,:,mm));
  end;
  if mm==1, im1orig=im1; end;
  im2orig=im2;
  if (do_refdiff&(mm>1)),
    im1=double(yc1); im1orig=im1;
    cm1=imCenterMass(im1,mask);
  end;
  if invert_flag,
    if mm==1,
      tmpmax=2^ceil(log2(max(max(im1))));
      im1=tmpmax-im1;
    end;
    im2=tmpmax-im2;
  end;
  if do_filter,
    if mm==1, im1=myfilter2(im1,filterco); end;
    im2=myfilter2(im2,filterco);
  end;
  if norm_type==1,
    if mm==1,
      im1=im1-min(im1(maski)); im1=im1/max(im1(maski));
    end;
    im2=im2-min(im2(maski)); im2=im2/max(im2(maski));
  elseif norm_type==2,
    if mm==1,
      im1=im1-min(im1(maski)); im1=im1/max(im1(maski));
      [im1x,im1y]=gradient(im1); im1=sqrt(im1x.^2+im1y.^2); 
    end;
    im2=im2-min(im2(maski)); im2=im2/max(im2(maski));
    [im2x,im2y]=gradient(im2); im2=sqrt(im2x.^2+im2y.^2); 
  end;
  
  if (do_thr==2)&(mm==1),
    found=0;
    while(~found),
      tmpim=im1;
      clf, subplot(221), show(im_super(tmpim,mask,0.3)),
      tmpim2=tmpim(maski); 
      [tmph2,tmph1]=myimhist(tmpim2,sqrt(length(tmpim2))); 
      subplot(223), plot(tmph1,tmph2), axis('tight'),
      tmpminmax=input('  select:  min_max thr (use [])= ');
      tmpim(find(tmpim<tmpminmax(1)))=tmpminmax(1);
      tmpim(find(tmpim>tmpminmax(2)))=tmpminmax(2);
      subplot(222), show(im1), subplot(224), show(tmpim),
      found=input('  selection ok? [0:no, 1:yes]: ');
    end;
    minmaxthr=tmpminmax;
  end;
  if do_thr,
    if mm==1,
      im1(find(im1<minmaxthr(1)))=minmaxthr(1);
      im1(find(im1>minmaxthr(2)))=minmaxthr(2);
    end;
    im2(find(im2<minmaxthr(1)))=minmaxthr(1);
    im2(find(im2>minmaxthr(2)))=minmaxthr(2);
  end;
  if smooth_wid>0,
    if mm==1, im1=im_smooth(im1,smooth_wid); end;
    im2=im_smooth(im2,smooth_wid);
  end;
  cm2=imCenterMass(im2,mask);
  x0=cm2-cm1; x0=[x0(2) -x0(1)];
  if optmethod==2,
    xx=lsqnonlin(@imTranslate,x0,xlb,xub,xopt,im2,im1,parms,mask);
    [ee,yc]=imTranslate(xx,im2,im1,parms,mask);
    [ee1,yc1]=imTranslate(xx,im2orig,refim,parms,mask);
    ee=sum(sum(ee.^2));
  elseif optmethod==1,
    xx=fminsearch(@imTranslate,x0,xopt,im2,im1,parms,mask);
    [ee,yc]=imTranslate(xx,im2,im1,parms,mask);
    [ee1,yc1]=imTranslate(xx,im2orig,refim,parms,mask);
  elseif optmethod==3,
    xlb(3)=-90*area_fraction/2;
    xub(3)=+90*area_fraction/2;
    xx(3)=0; x0(3)=0;
    xx=fminsearch(@imTranslateRot,xx,xopt,im2,im1,parms,mask);
    %xx=fminbnd(@imTranslateRot,xlb,xub,xopt,im2,im1,parms,mask);
    %xx=lsqnonlin(@imTranslateRot,x0,xlb,xub,xopt,im2,im1,parms,mask);
    [ee,yc]=imTranslateRot(xx,im2,im1,parms,mask);
    [ee1,yc1]=imTranslateRot(xx,im2orig,refim,parms,mask);
  elseif optmethod==4,
    upscalef=area_fraction;
    if mm==1, im1=im1(cropii(1):cropii(2),cropii(3):cropii(4)); end;
    im2=im2(cropii(1):cropii(2),cropii(3):cropii(4));
    [xx,yc]=mydftreg(im2,im1,[upscalef 0]);
    yc1n=imshift2(im2,xx(1),xx(2),1);
    ee=sum((im1(:)-yc1n(:)).^2);
    yc1=imshift2(im2orig,xx(1),xx(2),1);
  else,
    xx=findTranslate(im2,im1,1,mask);
    %[ee1,yc1]=imTranslate(xx,im2,refim,parms,mask);
    %yc=imshift2(im2,xx(1),xx(2),1);
    yc1n=imshift2(im2,-1*xx(1),-1*xx(2),1);
    ee=sum((im1(:)-yc1n(:)).^2);
    yc1=imshift2(im2orig,-1*xx(1),-1*xx(2),1);
  end;
  disp(sprintf('  %02d: [%.2f, %.2f] err= %.4f  [%.2f %.2f]',mm,xx(1),xx(2),ee,cm2(1)-cm1(1),cm2(2)-cm1(2)));
  y(mm,:)=xx;
  if do_output, y2(:,:,mm)=yc1; else, y2=[]; end;
  y3(mm,:)=cm2;
  %keyboard,
end;

% check how much motion
mot_thr=0.01;
if optmethod==4, mot_thr=2/parms(2); end;
tmpnn=sum(sum(abs(y(:,1:2))>mot_thr));
if (tmpnn/size(y,1))>0.02,
  disp(sprintf('  warning: not much motion found (%d of %d, thr=%f)',tmpnn,size(y,1),mot_thr));
end


function [ee,yy]=imTranslate(x,im,refim,parms,mask)
yy=imshift2(im,x(1),x(2),1);
maski=find(mask);
ee=yy(maski)-refim(maski);
if parms(1)==1,
  ee=sum(sum(ee.^2));
  disp(sprintf('  [%.2f %.2f] %.4f',x(1),x(2),ee));
else,
  disp(sprintf('  [%.2f %.2f] %.4f',x(1),x(2),sum(ee.^2)));
end;
return;

function [ee,yy]=imTranslateRot(x,im,refim,parms,mask)
yy=imshift2(im,x(1),x(2),1);
yy=rot2d_f(yy,x(3));
maski=find(mask);
ee=yy(maski)-refim(maski);
if parms(1)==3,
  ee=sum(ee(:).^2);
  %disp(sprintf('  [%.2f %.2f %.2f] %.4f',x(1),x(2),x(3),ee));
else,
  %disp(sprintf('  [%.2f %.2f %.2f] %.4f',x(1),x(2),x(3),sum(ee.^2)));
end;
return;

function xxy=findTranslate(im,refim,subpix_flag,mask)
[mski,mskj]=find(mask);
cropii=[min(mski) max(mski) min(mskj) max(mskj)];
im1=refim(cropii(1):cropii(2),cropii(3):cropii(4));
im2=im(cropii(1):cropii(2),cropii(3):cropii(4));
xc=fftshift(abs(ifft2(fft2(im1).*fft2(im2(end:-1:1,end:-1:1)))));
%xc=fftshift(abs(ifft2(fft2(im1).*conj(fft2(im2)))));
if subpix_flag,
  [maxi,maxj]=find(xc==max(max(xc)));
  f0=log(xc(maxi,maxj));
  f1=log(xc(maxi-1,maxj));
  f2=log(xc(maxi+1,maxj));
  maxi_sp=maxi+(f1-f2)./(2*f1-4*f0+2*f2);
  f0=log(xc(maxi,maxj));
  f1=log(xc(maxi,maxj-1));
  f2=log(xc(maxi,maxj+1));
  maxj_sp=maxj+(f1-f2)./(2*f1-4*f0+2*f2);
  maxi=maxi_sp;
  maxj=maxj_sp;
else,
  [maxi,maxj]=find(xc==max(max(xc)));
end;
xxy=[floor(size(im1,1)/2)-maxi floor(size(im1,2)/2)-maxj];
return;


