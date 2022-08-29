function [y,ys]=gcampCellSelect1a(im,im_parms,sel_parms,crf_range,mask)
% Usage ... y=gcampCellSelect1a(im,im_parms,sel_parms,crf_range,mask)
%
% im_parms=[hcf,smw,pow]
% sel_parms=[winf,ringrf,stdf,cthr-min,cthr-max,rthr]
%
% runs chkCellRing2 first, then chkCellRing1b on each location
%
% Ex. mask=gcampCellSelect1a(im1,[4 0.6 2],[0.1 0.025 1.75 3 0.25 0.25 0.25],[0.05:0.02:0.20]);

mask_flag=0;
if exist('mask','var'), disp('  mask provided, going to select...'); mask_flag=1; end;
if ~exist('crf_range','var'), crf_range=[0.05:0.02:0.20]; end;
if ~exist('im_parms','var'), im_parms=[4 0.6 2]; end;
if ~exist('sel_parms','var'), sel_parms=[0.1 0.025 1.75 3 0.25 0.25 0.25]; end;

fig_flag=1;

do_image=0;
if ~isempty(im_parms),
  do_image=1;
  hcf=im_parms(1);
  smw=im_parms(2);
  pow=im_parms(3);
end;

winf=sel_parms(1);
crw=sel_parms(2);
stdf=sel_parms(3);
cthr=sel_parms(4:5);
rthr=sel_parms(6);
Nmax=sel_parms(7);

imdim=size(im);
mask=zeros(imdim);
tmpmask=zeros(imdim);

if winf>1, winw=winf; else, winw=floor(winf*imdim); end;

% prepare image
im1=im;
im1sz=size(im1);
if do_image,
  if hcf>0, homocorOIS(im,hcf); end;
  if smw>0, im1=im_smooth(im1,smw); end;
  im1=imwlevel(im1,[],1);
  if pow>0, im1=im1.^pow; end;
  im1=imwlevel(homocorOIS(im1,hcf),[],1);
end;

% Initial segmentation
if ~mask_flag,
  [tmpim1,tmpix,tmpiy]=getImRegion(im1,floor(im1sz/2),winw);
  tmp1sz=size(tmpim1);
  if crw<1, crw=crw*tmp1sz(1); end;
  [tmprok1,tmprmask1]=chkCellRing2(im1,size(tmpim1),crf_range,crw,[rthr Nmax]);
  if isempty(tmprmask1.lmaxIm3b(:)), warning('  no regions found'); return; end;
  figure(1), clf, im_overlay4(im1,tmprmask1.lmaxIm3b), drawnow,
  [tmpr1x,tmpr1y]=find(tmprmask1.lmaxIm3b);
  ys.mask1s=tmprmask1;
  
  tmprmask=zeros(im1sz);
  for mm=1:length(tmpr1x),
    tmprc0=[tmpr1x(mm) tmpr1y(mm)];
    tmpim1=getImRegion(im1,tmprc0,winw);
    tmpthr=mean(tmpim1(:))+stdf*std(tmpim1(:));
    tmprmask3=chkCellRing1b(im1,winw(1),tmprc0,[0:2:359],tmpthr);
    tmprmask=tmprmask|tmprmask3;
  end;
  figure(1), clf, im_overlay4(im1,tmprmask), drawnow,
  ys.mask=tmprmask;
  tmpin=input('  selection [enter=ok+exit, 1=manual select]: ');
  if isempty(tmpin), tmpin=0; end;
  if tmpin==0, y=tmprmask; return; end;
else,
  tmprmask=mask;
end;

% Selection portion
tmpok=0;
while(~tmpok),
  % select location
  tmpok1=0;
  while(~tmpok1),
    figure(1), clf,
    show(im1),
    tmpi1=round(ginput(1)); tmpi1=tmpi1([2 1]);
    if tmpi1(1)<1, tmpi1(1)=1; end;
    if tmpi1(1)>imdim(1), tmpi1(1)=imdim(1); end;
    if tmpi1(2)<1, tmpi1(2)=1; end;
    if tmpi1(2)>imdim(2), tmpi1(2)=imdim(2); end;
    tmplmask=zeros(imdim); tmplmask(tmpi1(1),tmpi1(2))=1;
    im_overlay4(im1,imdilate(tmplmask,ones(3,3)))
    drawnow,
    tmpin=input('  location ok? [0=no, 1=yes, 9=done]: ');
    if isempty(tmpin), tmpok1=1;
    elseif tmpin==9, tmpok1=1; tmpok=1; 
    elseif tmpin, tmpok1=1;
    else, tmpok1=0;
    end;
  end;

  if ~tmpok,
    [tmpim1,tmpix,tmpiy]=getImRegion(im1,tmpi1,winw);
    tmp1sz=size(tmpim1);
    
    % check if location is centered
    [tmpring1_ok,tmpring1]=chkCellRing1(tmpim1,crf_range,crw,[0 0],rthr);

    figure(2), clf,
    subplot(221), show(tmpim1), 
    subplot(222), show(tmpring1.ring),
    subplot(223), show(im_super(tmpim1,tmpring1.ring,0.3)),
    subplot(224), show(tmpring1.xc),
    drawnow,
    tmpok2=tmpring1_ok;   
    tmpin=input(sprintf('  location labeled %d (%.2f>%.2f) [enter=agree, 1=accept, 0=reject]: ',tmpok2,tmpring1.cc,tmpring1.rthr));
    if isempty(tmpin), tmpok2=1;
    elseif tmpin, tmpok2=1;
    else, tmpok2=0;
    end;

    % if ok, second pass, label cell
    if tmpok2,
      if cthr(2)<1, cthr(2)=floor(cthr(2)*prod(tmp1sz)); end;
      tmpthr=mean(tmpim1(:))+std(tmpim1(:))*stdf;
      tmpcthr=cthr;
      tmpl=im_thr2(tmpim1,tmpthr,tmpcthr);

      % check second pass result, adjust if necessary
      tmpok3=0;
      while(~tmpok3),
        tmpupdate=1;
        figure(3), clf, im_overlay4(tmpim1,tmpl), xlabel(sprintf('thr=%.3f %d %d',tmpthr,tmpcthr(1),tmpcthr(2))), drawnow,
        tmpin=input(sprintf('  selection thr=%.3f %d %d [enter=accept, t#=thr, c#=mincthr, x#=maxcthr, e=edit, r=reject]: ',tmpthr,tmpcthr(1),tmpcthr(2)),'s');
        if isempty(tmpin), tmpok3=1;
        else
          if strcmp(tmpin(1),'t'), tmpthr=str2num(tmpin(2:end));
          elseif strcmp(tmpin(1),'c'), tmpcthr(1)=str2num(tmpin(2:end));
          elseif strcmp(tmpin(1),'x'), tmpcthr(2)=str2num(tmpin(2:end));
          elseif strcmp(tmpin(1),'e'), tmpl=editMask1(tmpl,tmpim1); tmpok3=1; tmpupdate=0;
          elseif strcmp(tmpin(1),'r'), tmpok2=0; tmpok3=1; tmpupdate=0;
          end;
        end;
        if tmpupdate, tmpl=im_thr2(tmpim1,tmpthr,tmpcthr); end;
      end;
    end;
  
    % third pass, generate last mask
    if tmpok3,
      tmprc0=tmpring1.ctr+floor(tmp1sz/2);
      tmpmask3=chkCellRing1b(tmpim1,winw(1),tmprc0,[0:2:359],tmpthr);
      figure(4), clf, im_overlay4(tmpim1,tmpmask3),
      tmpin=input('  mask ok? [enter/1=yes, 0=edit]: ');
      if ~isempty(tmpin), if tmpin, tmpmask3=editMask1(tmpmask3,tmpim1); end; end;
    end;
  
    % add to mask
    if tmpok2&tmpok3,
      tmpmask(tmpix,tmpiy)=tmpmask(tmpix,tmpiy)|(tmpl>0)|(tmpmask3>0);
      figure(3), clf,
      im_overlay4(im1,bwlabel(tmpmask)), xlabel('Cell Mask');
      drawnow,
    end;
  end;
  
end;

mask=bwlabel(tmpmask>0);

y.im_orig=im;
y.im=im1;
y.im_parms=im_parms;
y.mask=mask;
y.sel_parms=sel_parms;
y.sel_winw=winw;

 


%
% Internal functions
%
function [y,tmpix,tmpiy]=getImRegion(im1,ctr,rad)
  im1dim=size(im1);
  tmpix=ctr(1)+[-rad(1):rad(1)]; 
  tmpiy=ctr(2)+[-rad(2):rad(2)];
  tmpix=tmpix(find((tmpix>=1)&(tmpix<=im1dim(1))));
  tmpiy=tmpiy(find((tmpiy>=1)&(tmpiy<=im1dim(2))));
  y=im1(tmpix,tmpiy);
return;

