function [ring_ok,yy]=chkCellRing2(im1,subim1sz,rwf_range,rrw,thr,grad_flag)
% Usage ... [ring_ok,ys]=chkCellRing1(im1,subim1sz,rwf_range,rrwf,rthr,grad_flag)
%
% checks to see if there are ring-shaped objects in im1
% the ring-shapes are based on subim1s size
% subim1sz can be a fraction or actual pixel dimension
% rwf_range is the ring width fraction range
% rrwf is the ring width in pixels
% thr=[intensity-threshold Npix-distance-thr]


if ~exist('grad_flag','var'), grad_flag=0; end;

im1sz=size(im1);
if length(subim1sz)==1, subim1sz=[1 1]*subim1sz; end;
if prod(subim1sz)<1, subim1sz=round(subim1sz.*im1sz); end;

fig_flag=0;
if nargout==0, fig_flag=1; end;

if prod(size(rwf_range))==length(rwf_range),
  rwf_range=[rwf_range(:) rwf_range(:)]; 
end;

rthr=thr(1);
Nmax=thr(2);

yy.im=im1;
yy.subIm1sz=subim1sz;
yy.rwf_range=rwf_range;
yy.rrw=rrw;
yy.rthr=rthr;

if Nmax<1, tmplmaxN=floor(subim1sz(1)*Nmax); else, tmplmaxN=Nmax; end;
yy.Nmax=tmplmaxN;

[im1gx,im1gy]=gradient(im1);
im1g=sqrt(im1gx.^2+im1gy.^2);

for mm=1:size(rwf_range,1),
  tmprring=rwf_range(mm)*subim1sz;
  tmpring=ring2(subim1sz,tmprring,rrw,[0 0],0);
  if grad_flag,
    [tmpring1gx,tmpring1gy]=gradient(tmpring);
    tmpring1g=sqrt(tmpring1gx.^2+tmpring1gy.^2);
    tmpxc=xcorr2(im1g,tmpring1g);
    %tmpxc=tmpxc/(sum(im1g(:).^2)/length(im1g(:))+sum(tmpring1g(:).^2)/length(tmpring1g(:)));
    tmpxc=tmpxc/(sum(im1g(:)).^2/length(im1g(:))+sum(tmpring1g(:)).^2/length(tmpring1g(:)));
    tmpxc=tmpxc/sqrt(sum(tmpring1g(:))/length(tmpring1g(:)));
  else,
    tmpxc=xcorr2(im1,tmpring);
    %tmpxc=tmpxc/(sum(im1(:).^2)/length(im1(:))+sum(tmpring1(:).^2)/length(tmpring1(:)));
    tmpxc=tmpxc/(sum(im1(:)).^2/length(im1(:))+sum(tmpring(:)).^2/length(tmpring(:)));
    tmpxc=tmpxc/sqrt(sum(tmpring(:))/length(tmpring(:)));
  end;
  tmpxc=tmpxc(floor(subim1sz(1)/2)+[1:im1sz(1)],floor(subim1sz(2)/2)+[1:im1sz(2)]);
  
  tmplmax=imlocalmax(tmpxc,tmplmaxN);
  tmplmaxi=find(tmplmax);
  tmplmax2=zeros(im1sz);
  tmplmax2(tmplmaxi)=tmpxc(tmplmaxi);
  tmplmax2(find(tmplmax2<rthr))=0;
  tmplmax_avg=mean(tmpxc(find(tmplmax)));
  tmplmax2i=find(tmplmax2>=rthr);
  if isempty(tmplmax2i), 
      tmplmax2_avg=0; 
  else, 
      tmplmax2_avg=mean(tmpxc(tmplmax2i)); 
  end;
  [tmplmax2_ix,tmplmax2_iy]=find(tmplmax2);
  tmplmax2n=zeros(im1sz); if ~isempty(tmplmax2i), tmplmax2n(tmplmax2i)=[1:length(tmplmax2i)]; end;
  
  if fig_flag,
    clf,
    subplot(221), show(im1),
    subplot(222), show(tmpring),
    subplot(223), show(tmpxc),
    subplot(224), show(tmplmax), 
    xlabel(num2str(tmplmax_avg)),
    drawnow,
    disp(sprintf('  %d of %d (max= %.3f %.3f',mm,size(rwf_range,1),max(tmpxc(:)),tmplmax_avg));
  end;

  yy.xc_all(:,:,mm)=tmpxc;
  yy.lmaxIm_all(:,:,mm)=tmplmax;
  yy.lmaxIm2_all(:,:,mm)=tmplmax2;
  yy.lmax_ii{mm}=[tmplmax2_ix,tmplmax2_iy];
  yy.lmaxAvg_all(mm,:)=[tmplmax_avg tmplmax2_avg];
  yy.ring_all(:,:,mm)=tmpring;
  yy.rr_all(mm,:)=tmprring;

  lmaxIm2in_all(:,:,mm)=tmplmax2n;
end;

[yy.lmaxIm_avg,yy.ii]=max(yy.lmaxAvg_all);
lmaxIm2=zeros(im1sz);
lmaxIm2n=zeros(im1sz);
for mm=1:length(yy.lmax_ii), 
  if ~isempty(yy.lmax_ii{mm}), 
    for nn=1:length(yy.lmax_ii{mm}),
      if (lmaxIm2(yy.lmax_ii{mm}(nn,1),yy.lmax_ii{mm}(nn,2))==0), 
        lmaxIm2(yy.lmax_ii{mm}(nn,1),yy.lmax_ii{mm}(nn,2))=yy.lmaxIm2_all(yy.lmax_ii{mm}(nn,1),yy.lmax_ii{mm}(nn,2),mm);
        lmaxIm2n(yy.lmax_ii{mm}(nn,1),yy.lmax_ii{mm}(nn,2))=mm;
      end;
    end; 
  end;
end;
lmaxIm3=(imlocalmax(lmaxIm2,tmplmaxN).*lmaxIm2n);
lmaxIm3b=bwmorph(imdilate(lmaxIm2>0,strel('disk',3)),'shrink',Inf);

yy.lmaxIm2=lmaxIm2;
yy.lmaxIm3=lmaxIm3;
yy.lmaxIm3b=lmaxIm3b;

ring_ok=0;
if yy.lmaxIm_avg>rthr, ring_ok=1; end;
yy.ring_ok=ring_ok;

if fig_flag,
  clf,
  subplot(121), im_overlay4(im1,yy.lmaxIm3),
  subplot(122), im_overlay4(im1,yy.lmaxIm3b),
  drawnow,
end;



