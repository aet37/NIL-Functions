function [y,yn]=myUnmix1a(ims,ch,parms)
% Usage ... ims_new=myUnmix1a(ims,ch,parms)
%
% Simple unmixing by maximal decorrelation. This function assumes that
% there is shared informaiton between the channels. Current implementation
% only considers ch channels with shared information, such that ch=[2] in
% ims with 2-ch will return a 3-ch image with 1=1-2, 2=2-1, 3=2-residual
%
% Ex. myUnmix1a(avgim_motc,2)


% say there are 3 probes ABC (Rhod/mRuby/GFP)
% ch1 has A+B
% ch2 has B+C
% we can generate a new image ABC where B is the shared information between
% ch1+2, or B=corr(1,2) then A=1-B and C=2-B
% the coefficients are importnat

do_fig=0;
if nargout==0, do_fig=1; end;

if ~exist('parms','var'), parms=[]; end;
if isempty(parms), parms=[1 0.05]; end;
if length(parms)==1, parms(2)=0.05; end;

nord=parms(1);
qrange=parms(2);

imsz=size(ims);
for mm=1:imsz(3), im_orig{mm}=ims(:,:,mm); end;
im_ref=im_orig{ch(1)};

if ch(1)==2,
  im_pfit=polyfit(im_ref(:),im_orig{1}(:),nord);
  im_fit=polyval(im_pfit,im_ref);
  im_new(:,:,1)=im_orig{1} - im_fit;
  im_new(:,:,2)=im_fit;
  
  im_new2=im_new;
  im_pfit2=polyfit(im_fit(:),im_orig{2}(:),nord);
  im_fit2=polyval(im_pfit2,im_fit);
  
  im_neg=(im_new(:,:,1)<0).*im_new(:,:,1);
  im_new2(:,:,1)=(im_new2(:,:,1)>0).*im_new2(:,:,1);
  im_new2(:,:,3)=im_orig{2} - im_fit2 - im_neg;
else
  im_pfit=polyfit(im_ref(:),im_orig{2}(:),nord);
  im_fit=polyval(im_pfit,im_ref);
  im_new(:,:,1)=im_fit;
  im_new(:,:,2)=im_orig{2} - im_fit;
  
  im_new2=im_new;
  im_pfit2=polyfit(im_fit(:),im_orig{1}(:),nord);
  im_fit2=polyval(im_pfit2,im_fit);

  im_neg=(im_new(:,:,2)<0).*im_new(:,:,2);
  im_new2(:,:,2)=(im_new2(:,:,2)>0).*im_new2(:,:,2);
  im_new2(:,:,3)=im_orig{1} - im_fit2 - im_neg;
end

qtiles=[qrange .50 1-qrange];
for mm=1:size(im_new,3),
  tmpim=im_new(:,:,mm);
  tmpqtiles=quantile(tmpim(:),qtiles,1);
  im_new_n(:,:,mm)=imwlevel(tmpim,tmpqtiles([1 3]),1);
end
for mm=1:size(im_new2,3),
  tmpim=im_new2(:,:,mm);
  tmpqtiles=quantile(tmpim(:),qtiles,1);
  im_new2_n(:,:,mm)=imwlevel(tmpim,tmpqtiles([1 3]),1);
end

y=im_new;
yn=im_new_n;

if do_fig,
  clf,
  subplot(231), show(ims),
  subplot(232), show(im_new),
  subplot(235), show(im_new_n),
  subplot(233), show(im_new2),
  subplot(236), show(im_new2_n),
  clear y
end

if nargout==1,
    %disp('  outputting struct');
    tmpy.im=ims;
    tmpy.ch=ch;
    tmpy.parms=parms;
    tmpy.pfit=im_pfit;
    tmpy.fit=im_fit;
    tmpy.im_new=im_new;
    tmpy.im_new_n=im_new_n;
    tmpy.pfit2=im_pfit2;
    tmpy.fit2=im_fit2;
    tmpy.im_new2=im_new2;
    tmpy.im_new2_n=im_new2_n;
    clear y yn
    y=tmpy;
    clear tmpy
end
