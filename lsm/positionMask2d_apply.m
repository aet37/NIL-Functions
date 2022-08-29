function ys=positionMask2D_apply(posStruct,subImRoot)
% Usage ... ys=positionMask2D_apply(posStruct,subImRoot)
%

do_save=0;
do_flip=1;

do_loadinfo=0;
if ~exist('subParms','var'), do_loadinfo=1; end;

do_dir=1; do_mat=0;
if iscell(subImRoot), do_dir=0; end;
if ~ischar(subImRoot), 
  subPos=subImRoot; 
  do_dir=0; 
  do_loadinfo=0; 
else,
  if strcmp(subImRoot(end-3:end),'.mat'),  do_mat=1; end;
end;

if do_dir,
  if do_mat,
    subfiles=dir([subImRoot]);
    tmproot=subImRoot; clear subImRoot
    for mm=1:length(subfiles),
      subImRoot{mm}=subfiles(mm).name;
      disp(sprintf('  #%d: %s ',mm,subImRoot{mm}));
    end;
  else,
    disp('  Looking for Similar Directories...');
    subfiles=dir([subImRoot(1:end-5),'*']);
    tmproot=subImRoot; clear subImRoot
    subImRoot{1}=tmproot;
    disp(sprintf('  #1: %s ',subImRoot{1}));
    tmpcnt=1;
    for mm=1:length(subfiles),
      if ~strcmp(subfiles(mm).name,subImRoot{1}(1:end-1)),
        tmpcnt=tmpcnt+1;
        subImRoot{tmpcnt}=[subfiles(mm).name,'/'];
        disp(sprintf('  #%d: %s ',tmpcnt,subImRoot{tmpcnt}));
      end;
    end;
  end;
end;


if do_loadinfo,
  disp('  Reading Info and Images...');
  if do_mat,
    for mm=1:length(subImRoot),
      eval(sprintf('load %s info data',subImRoot{mm}));
      %subParms(mm,1)=info.PV_shared.micronsPerPixel{1}*info.PV_shared.linesPerFrame/info.PV_shared.opticalZoom;
      %subParms(mm,2)=info.PV_shared.micronsPerPixel{2}*info.PV_shared.pixelsPerLine/info.PV_shared.opticalZoom;
      subParms(mm,1)=info.PV_shared.micronsPerPixel{1}*info.PV_shared.linesPerFrame;
      subParms(mm,2)=info.PV_shared.micronsPerPixel{2}*info.PV_shared.pixelsPerLine;
      subPos(mm,1)=info.PV_shared.positionCurrent{1}{1};
      subPos(mm,2)=info.PV_shared.positionCurrent{2}{1};
      tmpdatasz=size(data);
      tmpim=max(data,[],length(tmpdatasz));
      if length(tmpdatasz)==4,
        tmpim=tmpim(:,:,end);
      elseif length(tmpdatasz)==5,
        tmpim=tmpim(:,:,end,1);
      end;
      if do_flip,
        disp('  flipping subIm U-D and L-R');
        subIm{mm}=fliplr(flipud(tmpim));
      else,
        subIm{mm}=tmpim;
      end;
    end;
    clear tmp* data info
  else,
    for mm=1:length(subImRoot),
      tmpinfo=parsePrairieXML(subImRoot{mm});
      %subParms(mm,1)=tmpinfo.PV_shared.micronsPerPixel{1}*tmpinfo.PV_shared.linesPerFrame/tmpinfo.PV_shared.opticalZoom;
      %subParms(mm,2)=tmpinfo.PV_shared.micronsPerPixel{2}*tmpinfo.PV_shared.pixelsPerLine/tmpinfo.PV_shared.opticalZoom;
      subParms(mm,1)=tmpinfo.PV_shared.micronsPerPixel{1}*tmpinfo.PV_shared.linesPerFrame;
      subParms(mm,2)=tmpinfo.PV_shared.micronsPerPixel{2}*tmpinfo.PV_shared.pixelsPerLine;
      subPos(mm,1)=tmpinfo.PV_shared.positionCurrent{1}{1};
      subPos(mm,2)=tmpinfo.PV_shared.positionCurrent{2}{1};
      tmpdata=readPrairie2(subImRoot{mm});
      tmpdatasz=size(tmpdata);
      tmpim=max(tmpdata,[],length(tmpdatasz));
      if length(tmpdatasz)==4,
        tmpim=tmpim(:,:,end);
      elseif length(tmpdatasz)==5,
        tmpim=tmpim(:,:,end,1);
      end;
      if do_flip,
        disp('  flipping subIm U-D and L-R');
        subIm{mm}=fliplr(flipud(tmpim));
      else,
        subIm{mm}=tmpim;
      end;
    end;
    clear tmp*
  end;  
end;

mainIm=posStruct.mainIm;
mainParms=posStruct.mainParms;
subloc1=posStruct.subLoc(1,:);

ys.mainIm=mainIm;
ys.mainParms=mainParms;
ys.subIm=subIm;
ys.subParms=subParms;
ys.subImName=subImRoot;


for mm=1:length(subIm),
    %tmppos=subloc1+[-1 +1].*(subPos(mm,[2 1])-subPos(nn,[2 1]));    %[+1 +1]??
    tmppos=subloc1+[-1 -1].*(subPos(mm,[2 1])-subPos(1,[2 1]));
    [tmpmask1,tmpyi1]=positionMask2d(mainParms,[size(subIm{mm}) subParms(mm,:) tmppos],mainIm);
    ys.mask{mm}=tmpmask1;
    ys.mainIm_i{mm}=tmpyi1;
    ys.subLoc(mm,:)=tmppos;
end;

if do_save,
  if do_mat,
    tmpname='tmp_summ_pos.mat';
  else,
    tmpname=[subImRoot{1}(1:4),subImRoot{1}(end-5:end-1),'_pos.mat'];
  end;
  disp(sprintf('saving %s with ys',tmpname));
  eval(sprintf('save %s ys',tmpname));
end;

show_positionMask2d(ys),

