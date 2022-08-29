function [maskl_new,mask2l]=chkCellRing2b(im1,subim1sz,thrf,lmax,maskin)
% Usage ... msk=chkCellRing2b(im1,subim1sz,thrf,lmax)
%
% Segment cell based on radius from the center location 
% thrf=[int_thr N_thr]  default=[0.5 0.6]
% Has interactive mode, to exit click outside image

if ~exist('lmax','var'), lmax=[]; end;
if ~exist('subim1sz','var'), subim1sz=[]; end;
if ~exist('thrf','var'), thrf=[]; end;

if isempty(subim1sz), subim1sz=2*ceil(sqrt(size(im1,1))); end;
if isempty(thrf), thrf=[0.5 0.6]; end;

do_lmax=1;
if isstruct(im1),
  im1s=im1;
  clear im1
  if ~exist('lmax','var'), lmax=im1s.lmaxIm3; end;
  im1=im1s.im;
  if isempty(subim1sz), subim1sz=im1s.subIm1sz; end;
elseif isempty(lmax),
  do_lmax=0;
end;

im1sz=size(im1);
mask=zeros(im1sz);
mask2=zeros(im1sz);
maskl=mask; mask2l=mask2;
im1_orig=im1;

if length(subim1sz)==1, subim1sz=[1 1]*subim1sz; end;
if prod(subim1sz)<1, subim1sz=round(im1sz).*subim1sz; end;
if exist('maskin','var'), mask=maskin; mask2=maskin; end;

ang_range=[0:2:359];

fig_flag=0;
if nargout==0, fig_flag=1; end;
det_flag=1;

if length(thrf)==1, thrf(2)=floor(subim1sz(1)/2); end;
Nthr=thrf(2);
if Nthr<1, Nthr=floor(subim1sz(1)*Nthr); end;

nw=floor(subim1sz(1)/2);

disp(sprintf('  subSz= [%d %d], thrf= %.2f, Nthr= %d',subim1sz,thrf(1),Nthr));

if do_lmax,
  disp('  lmax provided');
  lmax=bwlabel(lmax>0);
  for mm=1:max(lmax(:)),
    [tmprc0x,tmprc0y]=find(lmax==mm);
    tmprc0=[tmprc0x(1) tmprc0y(1)];
    [im1,tmpix,tmpiy]=getImRegion(im1_orig,tmprc0,floor(subim1sz/2));
    tmpthr=mean(im1(:))+thrf(1)*std(im1(:));
    tmpmask=zeros(size(im1));
    mask2(tmpix,tmpiy)=mask2(tmpix,tmpiy)|(im_thr2(im1,tmpthr,[2 0.5*prod(subim1sz)])>0);

    for oo=1:length(ang_range);
      [tmpla,tmplb,tmplc]=getRectImGrid2(im1,[nw 1],1,floor(subim1sz/2),ang_range(oo),1);
      for nn=1:size(tmplc,1), im1ln(nn)=im1(tmplc(nn,1),tmplc(nn,2)); end; 

      im1lnx=[1:length(im1ln)];
      if det_flag,
        im1lnfit=polyval(polyfit([1 mean(im1lnx(floor(length(im1lnx)/2):end))],[im1ln(1) mean(im1ln(floor(length(im1lnx)/2):end))],1),im1lnx);
        im1ln=im1ln-im1lnfit+mean(im1lnfit);
      end;
      tmpringenv=1./(1+exp((im1lnx-subim1sz/4)/(subim1sz/8))) - 1./(1+exp((im1lnx-1)/2));
      im1ln=im1ln.*(tmpringenv/max(tmpringenv));
    
      tmplii=find(im1ln>tmpthr(1));
      tmplii=tmplii(find(tmplii<=Nthr)); 
      if ~isempty(tmplii),
        tmpldi=find(diff(tmplii)>1);
        if ~isempty(tmpldi), 
          tmpli2=tmplii(1:tmpldi(1));
        else,
          tmpli2=tmplii;
        end;
     
        for nn=1:length(tmpli2), tmpmask(tmplc(tmpli2(nn),1),tmplc(tmpli2(nn),2))=1; end;
      end;
      
      if fig_flag,
        figure(2), clf,
        subplot(221), im_overlay4(im1,tmplb),
        subplot(222), im_overlay4(im1,tmpmask), 
        subplot(212), plot([1:length(im1ln)],[im1ln(:) im1lnfit(:) ones(length(im1ln),1)*tmpthr(1)],tmplii,im1ln(tmplii),'o',tmpli2,im1ln(tmpli2),'x')
        drawnow,
      end;

      clear tmpla tmplb tmplc 
      clear im1ln
    end;

    mask(tmpix,tmpiy)=mask(tmpix,tmpiy)|tmpmask;
    
  end; 
else,
  tmpok=0; tmpcnt=0; tmpbut=1;
  while (~tmpok),
    clear tmprc0 tmp1x tmp1y tmplmin1 tmplmin1x tmplmin1y tmplii
    figure(1), clf,
    im_overlay4(im1_orig,mask), colormap gray, axis image,
    title('Image Overlay -- Select location then press ENTER to ACCEPT'),
    if tmpbut==1,
      % save and continue
    else,
      % adjust and use previous coordinates
      % up-arrow is tmpbut=30/61 and down-arrow is tmpbut=31/45
    end;
    [tmp1x,tmp1y,tmpbut]=ginput(1);
    tmprc0=[round(tmp1y) round(tmp1x)];
    if tmprc0(1)<1, tmprc0(1)=1; tmpok=1; end;
    if tmprc0(2)<1, tmprc0(2)=1; tmpok=1; end;
    if tmprc0(1)>im1sz(1), tmprc0(1)=im1sz(1); tmpok=1; end;
    if tmprc0(2)>im1sz(2), tmprc0(2)=im1sz(2); tmpok=1; end;
    if tmpok, break; end;
   
    % find min near tmprc0
    tmplmin1=min(min(im1_orig(tmprc0(1)+[-1:1],tmprc0(2)+[-1:1])));
    [tmplmin1x,tmplmin1y]=find(im1_orig(tmprc0(1)+[-1:1],tmprc0(2)+[-1:1])==tmplmin1);
    if (length(tmplmin1x)==1)&(length(tmplmin1y)==1),
      tmprc0=tmprc0+[tmplmin1x-1-1 tmplmin1y-1-1];
    end;
    
    tmpmask=zeros(im1sz);
    tmpmask(tmprc0(1),tmprc0(2))=1;
    figure(1), im_overlay4(im1_orig,tmpmask), drawnow,

    [im1,tmpix,tmpiy]=getImRegion(im1_orig,tmprc0,floor(subim1sz/2));
    tmpthr=mean(im1(:))+thrf(1)*std(im1(:));
    tmpmask=zeros(size(im1));

    for oo=1:length(ang_range);
      [tmpla,tmplb,tmplc]=getRectImGrid2(im1,[nw 1],1,floor(subim1sz/2),ang_range(oo),1);
      for nn=1:size(tmplc,1), im1ln(nn)=im1(tmplc(nn,1),tmplc(nn,2)); end; 
    
      if det_flag,
        im1lnx=[1:length(im1ln)];
        im1lnfit=polyval(polyfit([1 mean(im1lnx(floor(length(im1lnx)/2):end))],[im1ln(1) mean(im1ln(floor(length(im1lnx)/2):end))],1),im1lnx);
        im1ln=im1ln-im1lnfit+mean(im1lnfit);
      end;
    
      tmplii=find(im1ln>tmpthr(1));
      tmplii=tmplii(find(tmplii<=Nthr));
      if ~isempty(tmplii),
        tmpldi=find(diff(tmplii)>1);
        if ~isempty(tmpldi), 
          tmpli2=tmplii(1:tmpldi(1));
        else,
          tmpli2=tmplii;
        end;
     
        for nn=1:length(tmpli2), tmpmask(tmplc(tmpli2(nn),1),tmplc(tmpli2(nn),2))=1; end;
      end;
      
      if fig_flag,
        figure(2), clf,
        subplot(221), im_overlay4(im1,tmplb),
        subplot(222), im_overlay4(im1,tmpmask), 
        subplot(212), plot([1:length(im1ln)],[im1ln(:) im1lnfit(:) ones(length(im1ln),1)*tmpthr(1)],tmplii,im1ln(tmplii),'o',tmpli2,im1ln(tmpli2),'x')
        drawnow,
      end;

      clear tmpla tmplb tmplc 
      clear im1ln
    end;

    mask(tmpix,tmpiy)=mask(tmpix,tmpiy)|tmpmask;
    mask2(tmpix,tmpiy)=mask2(tmpix,tmpiy)|(im_thr2(im1,tmpthr,[2 0.5*prod(subim1sz)])>0);

    tmpcnt=tmpcnt+1;
    tmpsubmask=maskl(tmpix,tmpiy); tmpsubmask(find(tmpmask))=tmpcnt;
    tmpsubmask2=mask2l(tmpix,tmpiy); tmpsubmask2b=im_thr2(im1,tmpthr,[2 0.5*prod(subim1sz)])>0; tmpsubmask2(find(tmpsubmask2b))=tmpcnt;
    maskl(tmpix,tmpiy)=tmpsubmask;
    mask2l(tmpix,tmpiy)=tmpsubmask2;
  end;
end;

maskl_new=zeros(size(maskl));
tmpcnt=0;
for mm=1:max(maskl(:)),
  tmpii=find(maskl==mm);
  if length(tmpii)>2, tmpcnt=tmpcnt+1; maskl_new(tmpii)=tmpcnt; end;
end;

return,

% internal functions
function [y,tmpix,tmpiy]=getImRegion(im1,ctr,rad)
  im1dim=size(im1);
  tmpix=ctr(1)+[-rad(1):rad(1)]; 
  tmpiy=ctr(2)+[-rad(2):rad(2)];
  tmpix=tmpix(find((tmpix>=1)&(tmpix<=im1dim(1))));
  tmpiy=tmpiy(find((tmpiy>=1)&(tmpiy<=im1dim(2))));
  y=im1(tmpix,tmpiy);
return;

