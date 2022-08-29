function [y,yc]=myCellMask(im,parms1,parms2,imdim,maskmod,gui_flag)
% Usage ... [y,yc]=myCellMask(im,parms1,parms2,imdim,maskmod,gui_flag)
%
% parms1=[impow thrf boxf]
% pamrs2=[hfp_co pixrange_min pixrange_max]

if ~exist('parms1'), parms1=[]; end;
if ~exist('parms2'), parms2=[]; end;
if ~exist('imdim'), imdim=[]; end;
if ~exist('maskmod'), maskmod=[]; end;
if ~exist('gui_flag'), gui_flag=0; end;

if isempty(parms1), parms1=[2 0.5 0.10]; end;
if isempty(parms2), parms2=[2 2 60]; end;

impow=parms1(1);
thrf=parms1(2);
boxf=parms1(3);
hpf_co=parms2(1);
pixrange=parms2(2:end);

if length(parms2)>3, thrf=parms2(4), end;

if isempty(imdim), 
  imdim=[1 1];
else,
  hpf_co_orig=hpf_co;
  pixrange_orig=pixrange;
  df=(1./size(im)).*imdim.*(1./size(im));
  hpf_co=round(hpf_co_orig/mean(df));
  pixdim=imdim./size(im);
  pixrange=round(pixrange_orig/mean(pixdim));
end;

im_flat=homocorOIS(im,hpf_co);
im_filt=im_flat; %im_filt=abs(myfilter2(im_flat,hpf_co));
im_norm=normch(im_filt,min(im_flat(:)),max(im_flat(:))).^impow;
im_thr=mean(im_norm(:))+thrf*std(im_norm(:));
mask=im_thr2(im_norm,im_thr,pixrange);
if ~isempty(maskmod), mask=maskmod; end;

if gui_flag,
  figure(1)
  show(im)
  figure(2)
  show(mask)
  tmpok=0;
  while(~tmpok),
    tmpin=input('Add/remove areas? [0=no, 1=yes]: ','s');
    if isempty(tmpin),
      for nn=1:2,
        show(im), drawnow; pause(0.5);
        im_overlay4(im,mask>0,64); drawnow; pause(0.5);
      end;
    elseif strcmp(tmpin(1),'f')|strcmp(tmpin(1),'F'),
      for nn=1:2,
        show(im), drawnow; pause(0.5);
        im_overlay4(im,mask>0,64); drawnow; pause(0.5);
      end;
    else,
      tmpok=1;
      tmpin=str2num(tmpin);
    end;
  end;
  if tmpin,
    tmpthrf=thrf;
    done=0;
    while(~done),
      figure(2), im_overlay4(im,mask>0,64); drawnow;
      disp('Select area to add/remove...'),
      [tmppix1,tmppix2,tmpbut]=round(ginput(1)); tmppix=[tmppix2 tmppix1];
      %tmppix=round(ginput(1)); tmppix=[tmppix(2) tmppix(1)];
      if tmpbut==3,
        for nn=1:2,
          show(im), drawnow; pause(0.5);
          im_overlay4(im,mask>0,64); drawnow; pause(0.5);
        end;
      elseif mask(tmppix(1),tmppix(2))>0,
        % remove area
        tmpii=find(mask==mask(tmppix(1),tmppix(2)));
        mask(tmpii)=0;
      else,
        % add area
        tmpx=tmppix(1)+round([-1 1]*boxf*size(im,1));
        tmpy=tmppix(2)+round([-1 1]*boxf*size(im,2));
        if tmpx(1)<1, tmpx(1)=1; end;
        if tmpx(2)>size(im,1), tmpx(2)=size(im,1); end;
        if tmpy(1)<1, tmpy(1)=1; end;
        if tmpy(2)>size(im,2), tmpy(2)=size(im,2); end;
        tmpim=im_norm(tmpx(1):tmpx(2),tmpy(1):tmpy(2));
        tmpmask0=zeros(size(im)); tmpmask0(tmpx(1):tmpx(2),tmpy(1):tmpy(2))=1;
        tmpgoodthr=0;
        while(~tmpgoodthr),
          tmplocthr=mean(tmpim(:))+tmpthrf*std(tmpim(:));
          tmpmask=(im_norm>tmplocthr).*tmpmask0;
          tmpmaskbw=bwlabel(tmpmask);
          tmpmask1=zeros(size(im)); tmpmask1i=find(tmpmaskbw==tmpmaskbw(tmppix(1),tmppix(2)));
          tmpmask1(tmpmask1i)=1;
          tmpmask2=mask>0; tmpmask2=double(tmpmask2); tmpmask2(tmpmask1i)=2;
          figure(2), im_overlay4(im,tmpmask2,64); drawnow;
          tmpin=input('Action [1=Add+more, 2=ChangeThr, 3=Exit+resel, 9=Add+done, 0=Exit+done]: ');
          if tmpin==1,
            mask(tmpmask1i)=max(mask(:))+1;
            tmpgoodthr=1;
          elseif tmpin==9,
            mask(tmpmask1i)=max(mask(:))+1;
            tmpgoodthr=1;
            done=1;
          elseif tmpin==2,
            tmpthrf=input(sprintf('Thr: orig= %.3f curr= %.3f new= ',thrf,tmpthrf));
          elseif tmpin==3,
            tmpgoodthr=1;
          else,
            tmpgoodthr=1;
            done=1;
          end;
        end; 
      end;
    end;
  end;
end;


y=bwlabel(mask>0);
yc=mask==0;

