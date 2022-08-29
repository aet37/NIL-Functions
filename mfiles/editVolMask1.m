function y=editVolMask1(volmask,vol,view_type)
% Usage ... y=editVolMask1(volmask,vol,view_type)
%
% Edits 3D mask
% for now functionality limited to removing/readding regions
% will add relabel and single pixel adding

if ~exist('vol','var'), vol=[]; end;

do_overlay=1;
if isempty(vol), do_overlay=0; else, vol=squeeze(vol); end;

volmask=squeeze(volmask);
vdim=size(volmask);

volmask_orig=volmask;
vol_orig=vol;

if ~exist('view_type','var'), view_type=1; end;

if ischar(view_type),
    if strcmp(view_type,'proj'),
        view_type=1;
    elseif strcmp(view_type,'stk'),
        view_type=2;
    else,
        view_type=1;
    end
end

tmpvol12=squeeze(max(vol,[],3));
tmpvol13=squeeze(max(vol,[],2));
tmpvol23=squeeze(max(vol,[],1))';

num=round(size(volmask,3)/2);
tmpok=0;
while(~tmpok),
  do_addremove=0;
  % display current mask state
  figure(1), clf,
  if do_overlay,
    im_overlay4(vol(:,:,num),volmask(:,:,num)),
  else,
    imagesc(volmask(:,:,mm)), axis image, colormap jet,
  end;
  xlabel(sprintf('Im# %d of %d',num,vdim(3)));
  drawnow,
  
  % select option
  tmpin=input('  (a)remove/readd masks, (p)showProj, (g#)goto, (r)reset: ','s');
  if isempty(tmpin), tmpin='q'; end;
  if strcmp(tmpin(1),'a'),
    do_addremove=1;
  elseif strcmp(tmpin(1),'p'),
    figure(2), clf,
    tmpmask12=squeeze(max(volmask,[],3));
    tmpmask13=squeeze(max(volmask,[],2));
    tmpmask23=squeeze(max(volmask,[],1))';
    if do_overlay,
      subplot(221), im_overlay4(tmpvol12,tmpmask12);
      subplot(222), im_overlay4(tmpvol13,tmpmask13);
      subplot(223), im_overlay4(tmpvol23,tmpmask23);
    else,
      subplot(221), imagesc(tmpmask12), axis image, colormap jet,
      subplot(222), imagesc(tmpmask13), axis image, colormap jet,
      subplot(223), imagesc(tmpmask23), axis image, colormap jet,      
    end;
    drawnow,
  elseif strcmp(tmpin(1),'r'),
    volmask=volmask_orig;
  elseif strcmp(tmpin(1),'g'),
    num=str2num(tmpin(2:end));
  elseif strcmp(tmpin(1),'q'),
    tmpok=1;
  end;
  
  % actions
  if do_addremove,
    tmpok2=0;
    while(~tmpok2),
      tmpupdate=0;
      [tmpjj,tmpii,tmpbb]=ginput(1);
      tmpii=round(tmpii);
      tmpjj=round(tmpjj);
      disp(sprintf('  [%d,%d,%d]',tmpii,tmpjj,tmpbb));
      if isempty(tmpbb),
        tmpok2=1;
      elseif (tmpii<1)|(tmpjj<1)|(tmpii>vdim(1))|(tmpjj>vdim(2)),
        tmpok2=1;
      elseif (tmpbb==1),
        if volmask(tmpii,tmpjj,num)>0,
          disp(sprintf('  [%d,%d,%d]=%d to 0',tmpii,tmpjj,num,volmask(tmpii,tmpjj,num)));
          volmask(find(volmask==volmask(tmpii,tmpjj,num)))=0; 
          tmpupdate=1;
        elseif volmask_orig(tmpii,tmpjj,num)>0,
          disp(sprintf('  [%d,%d,%d]=0 to %d',tmpii,tmpjj,num,volmask_orig(tmpii,tmpjj,num)));
          volmask(find(volmask_orig==volmask_orig(tmpii,tmpjj,num)))=volmask_orig(tmpii,tmpjj,num);
          tmpupdate=1;
        end;
      elseif (tmpbb==29)|(tmpbb==61)|(tmpbb==30),
        num=num+1;
        if num<1, num=1; 
        elseif num>vdim(3), num=vdim(3);
        end;
        tmpupdate=1;
      elseif (tmpbb==28)|(tmpbb==45)|(tmpbb==31),
        num=num-1;
        if num<1, num=1;
        elseif num>vdim(3), num=vdim(3);
        end;
        tmpupdate=1;
      elseif (tmpbb==113),
        tmpok2=1;
      end;
      if tmpupdate==1,
        figure(1), clf,
        if do_overlay,
          im_overlay4(vol(:,:,num),volmask(:,:,num)),
        else,      
          imagesc(volmask(:,:,num)), axis image, colormap jet,
        end;
        xlabel(sprintf('Im# %d of %d',num,vdim(3)));
        drawnow,
      end;
    end;
    do_addremove=0;
  end;
  
end;

y=volmask;


