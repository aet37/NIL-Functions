function [ii,mask2]=iiMasks1(mask,im,parms,p1)
% Usage ... [ii,mask_new]=iiMasks1(mask,im,parms,p1)
%
% makes a cell with ii values per cell for masks that are shared in common
%
% Ex. rad1ii=iiMasks1({rad1(:).mask},avgim_intc(:,:,1));
%     [rad1ii,rad1ii_mask]=iiMasks1(rad1s,avgim_intc(:,:,1),'select');
%     rr1a=iiMasks({rad1(:).mask},rad1ii,'avg',rr1);

if isstruct(mask),
  tmpmask=mask;
  clear mask
  mask={tmpmask(:).mask};
end;

if length(size(mask))==3,
  mask_orig=mask;
  mask=zeros(size(mask_orig,1),size(mask_orig,2));
  for oo=1:size(mask_orig,3), mask(find(mask_orig(:,:,oo)))=oo; end;
end;
if iscell(mask),
  mask_orig=mask;
  mask=zeros(size(mask{1},1),size(mask{1},2));
  for oo=1:length(mask_orig), mask(find(mask_orig{oo}))=oo; end;
end;
nii=max(mask(:));
  
if isempty(im), im=zeros(size(mask)); end;

if nargin<3, parms=[]; end;

do_select=0; do_avg=0;
if ischar(parms), 
  if strcmp(parms,'select'), 
      do_select=1; 
  elseif strcmp(parms,'avg'),
      do_avg=1;
  end; 
end;

if do_avg,
  mask_ii=im;
  data=p1;
  for mm=1:length(mask_ii),
    ii(:,mm)=mean(data(:,mask_ii{mm}),2);
  end;
  return,
end

if do_select,
  tmph=gcf;
  tmpmask=mask;
  imsz=size(im);
  cnt=0;
  tmpok=0;
  disp('  do_select: press enter for new group, click outside to finish');
  while(~tmpok),
    figure(tmph), clf,
    im_overlay4(im,tmpmask), drawnow,
    [tmpy,tmpx,tmpbut]=ginput(1);
    tmpy=round(tmpy); tmpx=round(tmpx);
    if (tmpy<1)|(tmpx<1)|(tmpy>imsz(2))|(tmpx>imsz(1)),
      tmpok=1;
    else,
      tmplabel=tmpmask(tmpx,tmpy);
      if isempty(tmpbut),
        if cnt>0, if ~isempty(ii{cnt}), 
          cnt=cnt+1; 
          ii{cnt}=[]; 
          disp(sprintf('  new entry (%d)',cnt)); 
        end; end;
      elseif tmplabel>0,
        if cnt==0,
          cnt=cnt+1;
          ii{cnt}=tmplabel;
        else,
          ii{cnt}=[ii{cnt} tmplabel];
        end;
        disp(sprintf('  %d: added to %d',tmplabel,cnt));
        tmpmask(find(tmpmask==tmplabel))=0;
      end;
    end;  
  end;
  
  cnt=0;
  for mm=1:length(ii), if ~isempty(ii{mm}), tmpii{mm}=ii{mm}; end; end;
  ii=tmpii;
  clear tmpii
  
else,
  tmph=gcf;
  figure(tmph), clf,
  im_overlay4(im,mask),
  cnt=0;
  for mm=1:nii,
    figure(2), clf,
    im_overlay4(im,mask==mm),
    drawnow,
    tmpin=input(sprintf('  %d: [n=new, a=addprev, iX=insertTo, s/enter=skip]: ',mm),'s');
    if isempty(tmpin), tmpin='s'; end;
    if strcmp(tmpin(1),'n'),
      cnt=cnt+1;
      ii{cnt}=mm;
      disp(sprintf('  %d: added to %d',mm,cnt));
    elseif strcmp(tmpin(1),'a'),
      ii{cnt}=[ii{cnt} mm];
      disp(sprintf('  %d: added to %d',mm,cnt));
    elseif strcmp(tmpin(1),'i'),
      if length(tmpin)==1, tmpin2=input('  enter label# to add: '); else, tmpin2=str2num(tmpin(2:end)); end;
      if ~isempty(tmpin2), ii{tmpin2}=[ii{tmpin2} mm]; end;
    end;
  end;
end;

mask2=zeros(size(mask));
for mm=1:length(ii),
  for nn=1:length(ii{mm}), mask2(mask==ii{mm}(nn))=mm; end;
end;

tmph=gcf;
figure(tmph), clf,
im_overlay4(im,mask2),
drawnow,
