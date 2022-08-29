function y=gcampCellSelect1(im,sel_parms,im_parms)
% Usage ... y=gcampCellSelect1(im,sel_parms,im_parms)
%
% sel_parms=[winf,crf,crw,stdf,cthr1,cthr2f]
% im_parms=[hcf,smw,pow]

if ~exist('sel_parms','var'), sel_parms=[0.1 1/4 2 1.5 3 0.25]; end;
if ~exist('im_parms','var'), im_parms=[4 0.6 2]; end;

fig_flag=1;

hcf=im_parms(1);
smw=im_parms(2);
pow=im_parms(3);

winf=sel_parms(1);
crf=sel_parms(2);
crw=sel_parms(3);
stdf=sel_parms(4);
cthr=sel_parms(5:6);

imdim=size(im);
mask=zeros(imdim);
tmpmask=zeros(imdim);

% prepare image
im1=im;
if hcf>0, homocorOIS(im,hcf); end;
if smw>0, im1=im_smooth(im1,smw); end;
im1=imwlevel(im1,[],1);
if pow>0, im1=im1.^pow; end;
im1=imwlevel(homocorOIS(im1,hcf),[],1);

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
    tmpin=input('  location ok? [0=no, 1=yes, 9=done, w=adj-winw]: ');
    if isempty(tmpin), tmpok1=1;
    elseif tmpin==9, tmpok1=1; tmpok=1; 
    elseif tmpin, tmpok1=1;
    else, tmpok1=0;
    end;
  end;

  if ~tmpok,
  if winf>1, winw=winf; else, winw=floor(winf*imdim); end;
  tmpix=tmpi1(1)+[-winw:winw]; 
  tmpiy=tmpi1(2)+[-winw:winw];
  tmpix=tmpix(find((tmpix>=1)&(tmpix<=imdim(1))));
  tmpiy=tmpiy(find((tmpiy>=1)&(tmpiy<=imdim(2))));
  tmpim1=im1(tmpix,tmpiy);

  % check if location is centered
  tmpim2=ellipse(size(tmpim1),ceil(size(tmpim1,1)/2),ceil(size(tmpim1,2)/2),winw(1)/4,winw(2)/4,0,1);
  %tmpxx=imMotDetect(tmpim1,tmpim2);
  %tmprc0=[ceil(size(tmpim1,1)/2+tmpxx(1)) ceil(size(tmpim1,2)/2+tmpxx(2))];
  tmpim3=xcorr2(tmpim1,tmpim2); [tmp3x,tmp3y]=find(tmpim3==max(tmpim3(:)));
  tmprc0=[ceil(size(tmpim1,1)/2)+tmp3x-size(tmpim1,1) ceil(size(tmpim1,2)/2)+tmp3y-size(tmpim1,2)];
  if (tmprc0(1)>=size(tmpim1,1)), tmprc0(1)=winw(1)+1; end;
  if (tmprc0(2)>=size(tmpim1,2)), tmprc0(2)=winw(2)+1; end;
  if (tmprc0(1)<=1), tmprc0(1)=winw(1)+1; end;
  if (tmprc0(2)<=1), tmprc0(2)=winw(2)+1; end;
  tmpim2=ellipse(size(tmpim1),tmprc0(1),tmprc0(2),winw(1)/4,winw(2)/4,0,1);

  % first pass, check if its circular or ring-shaped
  tmpim4=ring2(size(tmpim1),crf*size(tmpim1)/2,crw,size(tmpim1)-[tmp3x tmp3y]);
  [tmpim1gx,tmpim1gy]=gradient(tmpim1);
  [tmpim4gx,tmpim4gy]=gradient(tmpim4);
  tmpim1g=sqrt(tmpim1gx.^2+tmpim1gy.^2);
  tmpim4g=sqrt(tmpim4gx.^2+tmpim4gy.^2);
  tmpim5g=xcorr2(tmpim1g/sum(tmpim1g(:)),tmpim4g/sum(tmpim4g(:)));
  tmpim4gc=corr(tmpim1g(:),tmpim4g(:));
  figure(2), clf,
  subplot(221), show(tmpim1), 
  subplot(222), show(tmpim4),
  subplot(223), show(im_super(tmpim1,tmpim4,0.3)),
  subplot(224), show(tmpim5g),
  if abs(tmpim4gc)>0.2, tmpok2=1; else, tmpok2=0; end;
  tmpin=input(sprintf('  location labeled %d (%.2f) [enter=agree, 1=accept, 0=reject]: ',tmpok2,tmpim4gc));
  if isempty(tmpin), tmpok2=1;
  elseif tmpin, tmpok2=1;
  else, tmpok2=0;
  end;

  % second pass, label cell
  if tmpok2,
    if cthr(2)<1, cthr(2)=floor(cthr(2)*prod(size(tmpim1))); end;
    tmpthr=mean(tmpim1(:))+std(tmpim1(:))*stdf;
    tmpcthr=cthr;
    tmpok3=0;
    while(~tmpok3),
      tmpl=im_thr2(tmpim1,tmpthr,tmpcthr);
      figure(3), clf, im_overlay4(tmpim1,tmpl), xlabel(sprintf('thr=%.3f %d %d',tmpthr,tmpcthr(1),tmpcthr(2))), drawnow,
      tmpin=input(sprintf('  selection thr=%.3f %d %d [enter=accept, t#=thr, c#=mincthr, x#=maxcthr, e=edit, r=reject]: ',tmpthr,tmpcthr(1),tmpcthr(2)),'s');
      if isempty(tmpin), tmpok3=1;
      else
        if strcmp(tmpin(1),'t'), tmpthr=str2num(tmpin(2:end));
        elseif strcmp(tmpin(1),'c'), tmpcthr(1)=str2num(tmpin(2:end));
        elseif strcmp(tmpin(1),'x'), tmpcthr(2)=str2num(tmpin(2:end));
        elseif strcmp(tmpin(1),'e'), tmpl=editMask1(tmpl,tmpim1); tmpok3=1; 
        elseif strcmp(tmpin(1),'r'), tmpok2=0; tmpok3=1;
        end;
      end;
    end;
  end;
  
  % third pass, generate last mask
  if tmpok3,
    tmpmask3=zeros(size(tmpim1));
    tmpang=[0:2:359];
    for oo=1:length(tmpang);
      [tmpla,tmplb,tmplc]=getRectImGrid2(tmpim1,[winw(1) 1],1,tmprc0,tmpang(oo),1);
      for nn=1:size(tmplc,1), tmpim1ln(nn)=tmpim1(tmplc(nn,1),tmplc(nn,2)); end;
      tmpim1lnx=[1:length(tmpim1ln)];
      tmpim1lnfit=polyval(polyfit([1 mean(tmpim1lnx(floor(length(tmpim1lnx)/2):end))],[tmpim1ln(1) mean(tmpim1ln(floor(length(tmpim1lnx)/2):end))],1),tmpim1lnx);
      tmpim1ln=tmpim1ln-tmpim1lnfit+mean(tmpim1lnfit);
      tmplii=find(tmpim1ln>tmpthr);
      if ~isempty(tmplii),
        tmpldi=find(diff(tmplii)>1);
        if ~isempty(tmpldi), 
          tmpli2=tmplii(1:tmpldi(1));
        else,
          tmpli2=tmplii;
        end;
        for nn=1:length(tmpli2), tmpmask3(tmplc(tmpli2(nn),1),tmplc(tmpli2(nn),2))=1; end;
        figure(4), clf
        subplot(221), im_overlay4(tmpim1,tmplb),
        subplot(222), im_overlay4(tmpim1,tmpmask3), 
        subplot(212), plot([1:length(tmpim1ln)],[tmpim1ln(:) tmpim1lnfit(:) ones(length(tmpim1ln),1)*tmpthr],tmplii,tmpim1ln(tmplii),'o',tmpli2,tmpim1ln(tmpli2),'x')
        drawnow,
        clear tmpla tmplb tmplc tmpim1ln
      end;
    end;
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

y.im=im;
y.im1=im1;
y.mask=mask;
y.im_parms=im_parms;
y.sel_parms=sel_parms;
y.sel_winw=winw;

