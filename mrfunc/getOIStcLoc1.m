function ys=getOIStcLoc1(fname,parms,nloc,pixdim,maskopt,strc)
% Usage ... ys=getOIStcLoc1(fname_or_data,parms,nlocs,pixdim,maskopt,struc)
%
% parms=[fps mag roirad mask_union], roirad is the radius of the 
% circular roi for the tiem series, maskunion is whether to take
% the union(1) or intersection (0=def) of all masks, nloc is the #locations,
% maskopt is the masks to choose [1 1 1] is brain-vessel-probe (def=[0 0 0])
%
% Ex. co2a=getOIStcLoc1('11111mouse_620_co2.raw',[30 2.5 200],1,'cam');
%     dyn1a=getOIStcLoc1('11111mouse_620_co2.raw',[30 2.5 200],1,'cam',[1 1 1]);
%     dyn1b=getOIStcLoc1('11111mouse_620_co22.raw',dyn1a);

if isstruct(parms),
  strc=parms;
  parms=strc.parms;
  %nloc=[];
  pixdim=strc.pixdim;
  maskopt=strc.maskopt;
end;

if ~exist('nloc','var'), nloc=[]; end;
if ~exist('pixdim','var'), pixdim=[]; end;
if ~exist('maskopt','var'), maskopt=[]; end;

if isempty(maskopt), maskopt=[0 0 0]; end;

if isempty(pixdim),
  pixdim=[13.6 15.4];     % dual-cam 
elseif ischar(pixdim),
  if strcmp(pixdim,'cam')|strcmp(pixdim,'CAM'),
    pixdim=[13.6 15.4];
  elseif strcmp(pixdim(1:2),'pm')|strcmp(pixdim(1:2),'PM')
    pixdim=[6.6 6.6];
    if length(pixdim)>2,
      tmpbin=str2num(pixdim(3:end));
      pixdim=pixdim*tmpbin;
      disp(sprintf('  applied bin factor of %d'),tmpbin);
    end;
  elseif strcmp(pixdim,'coolsnap'),
    pixdim=[6.6 6.6];
  else,
    pixdim=[13.6 15.4];
  end;
end;

if exist('strc','var'),
  mask=strc.masks.mask;
  maskV=strc.masks.maskV;
  maskP=strc.masks.maskP;
  pixdim=strc.pixdim;
  if isempty(parms), parms=strc.parms; end;
  if isempty(maskopt), maskopt=strc.maskopt; end;
end;

if ~isempty(parms),
  fps=parms(1);      %30
  mag=parms(2);      %2.5
  roirad=parms(3);   %100
  if length(parms)>3, maskflag=parms(4); else, maskflag=0; end;
end;


if exist('tmpOISlocTC1.mat','file'),
  tmpin=input('  tmp file found [1=start-over, 2=load]: ');
  if tmpin==2,
    load tmpOISlocTC1
  end;
end;


do_load=0;
if ischar(fname), do_load=1; end;

if do_load,
  dcim=readOIS3(fname);
  save tmpOISlocTC1 dcim parms pixdim fps mag roirad do_load maskopt fname
else,
  dcim=fname(:,:,1);
  save tmpOISlocTC1 dcim parms pixdim fps mag roirad do_load maskopt
end;

if maskopt(1)==1,
  if ~exist('mask','var'),
    disp('  select brain mask...');
    mask=selectMask(dcim);
  end;
else,
  mask=ones(size(dcim));  
end;
tmpmask(:,:,1)=mask;
save tmpOISlocTC1 -append mask 

if maskopt(2)==1,
  if ~exist('maskV','var'),
    disp('  select vessel mask...');
    maskV=selectMask(dcim);
  end;
else,
  maskV=ones(size(dcim));
end;
tmpmask(:,:,2)=maskV;
save tmpOISlocTC1 -append maskV

if maskopt(3)==1,
  if ~exist('maskP','var'),
    disp('  select probe mask...');
    maskP=selectMask(dcim);
  end;
else,
  maskP=ones(size(dcim));  
end;
tmpmask(:,:,3)=maskP;
save tmpOISlocTC1 -append maskP


if ~isempty(nloc),
  disp(sprintf('  select Location (%d)',nloc));
  tmpok=0;
  tmpmask=zeros(size(dcim));
  while(~tmpok),
    show(dcim);
    pixloc=round(ginput(nloc));
    tmpmask=pixtoim([pixloc(:,2) pixloc(:,1)],size(dcim));
    im_overlay4(dcim,tmpmask);
    tmpin=input('  selection ok? [0:no, 1:yes]: ');
    if isempty(tmpin),
      tmpok=1;
    elseif tmpin==1,
      tmpok=1;
    end;
  end;
else,
  disp('  using strc pixloc');
  pixloc=strc.pixloc;
  nloc=size(pixloc,1);
end;
save tmpOISlocTC1 -append pixloc

tmpmask2=mask&(~maskV)&(~maskP);
for mm=1:nloc,
  maskE(:,:,mm)=ellipse(zeros(size(dcim)),pixloc(mm,2),pixloc(mm,1),roirad*mag/pixdim(2),roirad*mag/pixdim(1),0,1);
  tmpmaskE(:,:,mm)=tmpmask2&maskE(:,:,mm);
end;
save tmpOISlocTC1 -append maskE

clf, im_overlay4(dcim,tmpmaskE), drawnow,

ys=getStkMaskTC(fname,tmpmaskE);
save tmpOISlocTC1 -append ys

tt=[1:length(ys.atc)]/fps;

if do_load,
  ys.fname=fname;
end;
ys.tt=tt;
ys.im=dcim;
ys.pixloc=pixloc;
ys.masks.mask=mask;
ys.masks.maskP=maskP;
ys.masks.maskV=maskV;
ys.masks.maskE=maskE;
ys.parms=parms;
ys.pixdim=pixdim;
ys.maskopt=maskopt;

% avgtcE=getStkMaskTC(fname,maskE);
% tmpii=find(maskE);
% for mm=1:100:9300,
%   mm-1,
%   tmpvol=readOIS(fname,[1:100]+mm-1);
%   for nn=1:100,
%     avgtcE(nn+mm-1)=mean(tmpim(tmpii));
% end;

% removing tmp file
unix('rm tmpOISlocTC1.mat');

